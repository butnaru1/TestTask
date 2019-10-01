require 'watir'
require 'webdrivers'
require 'nokogiri'
require 'Accounts'
require 'Transactions'

# Get username and password.
puts 'Enter your username:'
login = gets.chomp.to_s
puts 'Enter your password:'
psw = gets.chomp.to_s

# Open browser and login on page.
browser = Watir::Browser.new :chrome
browser.goto('https://web.vb24.md/wb/#login')
browser.text_field(name: 'login').set login
browser.text_field(name: 'password').set psw
browser.button(type: 'submit').click

# Wait for page charging.
sleep(2)

# Fetch and parse HTML document
doc = Nokogiri::HTML(browser.html)
# Collect information about accounts
accounts_arr = []
nature, name, currency, nature = ''
doc.css('//div[@class="contracts"]/div/div').each do |div|
  nature = div.text.strip if div.attr('class') == 'section-title h-small'
  div.search('div').each do |second_div|
    name = second_div.search('a.name').text.strip
    second_div.search('div/div').each do |third_div|
      currency = third_div.text.strip if third_div.attr('class') == 'currency-icon'
      third_div.search('span').each do |span|
        if span.attr('class') == 'amount'
          balance = span.text.strip
          accounts_arr.push(Array.new([name, balance, currency, nature]))
        end
      end
    end
  end
end

# Go to transaction page
browser.link(href: '#menu/MAIN_215.CP_HISTORY').click
sleep(2)
browser.input(name: 'from').click
# Set period from two month early
(1..2).each { |i| browser.a(title: '< Prev').click }
# Get current date
puts current_date = Time.now.strftime('%-d')
browser.a(text: current_date).click
full_account_array = []
# Search transaction for each account
(0...accounts_arr.size).each do |i|
  iban = accounts_arr[i][0]
  transaction_arr = []
  browser.div(class: 'chosen-container chosen-container-single contract-select chosen-container-single-nosearch').click
  browser.span(text: iban).click

  # Wait for page charging.
  sleep(10)
  # Initializing variables.
  day_, date, description, amount, currency = ''
  # Fetch and parse HTML document
  doc = Nokogiri::HTML(browser.html)
  doc.css('//div[@class="operations"]').each do |div|
    div.search('div[@class="month-delimiter"]').each do |month_div|
      month_year = month_div.text.strip
      div.search('div[@class="day-operations"]').each do |span|
        span.search('div[@class="day-header"]').each do |day|
          day_ = day.text.strip.gsub(/[^\d]/, '')
        end
        span.search('ul[@class="operations-list"]/li').each do |list|
          list.search('span').each do |cell|
            time = cell.text.strip if cell.attr('class') == 'history-item-time'
            date = "#{day_} " + "#{month_year}" + "#{time}"
            description = cell.text.strip if cell.attr('class') == 'history-item-description'
            next unless cell.attr('class') == 'history-item-amount transaction ' ||
                cell.attr('class') == 'history-item-amount transaction income'

            money = cell.text.strip
            amount = money.to_s.scan(/\+?\d+\.\d+/)
            currency = money.to_s.scan(/[A-Z]+/)
            transaction_arr.push(Transactions.new(date, description, amount, currency, iban))
          end
        end
      end
    end
  end
  full_account_array.push(Accounts.new((accounts_arr[i][0]).to_s,
                                       (accounts_arr[i][1]).to_s,
                                       (accounts_arr[i][2]).to_s,
                                       (accounts_arr[i][3]).to_s,
                                       transaction_arr))
end
# Show the result.
full_account_array.each do |account|
  puts JSON.pretty_generate account
end

browser.close