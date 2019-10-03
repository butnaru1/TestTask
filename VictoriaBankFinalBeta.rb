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
sleep 2

# Fetch and parse HTML document
doc = Nokogiri::HTML(browser.html)
# Collect information about accounts
accounts_arr = []
account_struct = Struct.new(:name, :balance, :currency, :nature)
nature, name, currency, nature = ''
doc.css('div.contracts div.contracts-section div').each do |div|
  nature = div.text.strip if div.attr('class') == 'section-title h-small'
  div.css('div.main-info').each do |second_div|
    name = second_div.css('a.name').text.strip
    currency = second_div.css('div.icon div.currency-icon').text.strip
    balance = second_div.css('span.amount').text.strip.to_f
    accounts_arr << account_struct.new(name, balance, currency, nature)
  end
end

# Go to transaction page
browser.link(href: '#menu/MAIN_215.CP_HISTORY').click
sleep 2
browser.input(name: 'from').click
# Set period from two month early
(1..2).each { |i| browser.a(title: '< Prev').click }
# Get current date
current_date = Time.now.strftime('%-d')
browser.a(text: current_date).click
full_account_array = []
# Search transaction for each account
(0...accounts_arr.size).each do |i|
  iban = accounts_arr[i].name
  transaction_arr = []
  browser.div(class: 'chosen-container chosen-container-single contract-select chosen-container-single-nosearch').click
  browser.span(text: iban).click

  # Wait for page charging.
  sleep 5
  # Initializing variables.
  day_, date, description, amount, currency = ''
  # Fetch and parse HTML document
  doc = Nokogiri::HTML(browser.html)
  doc.css('div.operations').each do |div|
    div.css('div.month-delimiter').each do |month_div|
      month_year = month_div.text.strip
      year = month_year.scan(/[\d]/).join('')
      month = Date::MONTHNAMES.index("#{month_year.scan(/[A-z]+/).join('')}")
      div.css('div.day-operations').each do |span|
        span.css('div.day-header').each do |day|
          day_ = day.text.strip.gsub(/[^\d]/, '')
        end
        span.css('ul.operations-list li').each do |list|
          time = list.css('span.history-item-time').text.strip
          date = "#{year}" + '-' + "#{month}" + '-' + "#{day_}" + ' ' "#{time}"
          description = list.css('span.history-item-description').text.strip
          sign = if list.css('span.amount-sign').text.strip != ''
                   list.css('span.amount-sign').text.strip
                 else
                   '-'
                 end
          amount = list.css('span.amount').text.strip
          sign_amount = (sign + amount).to_f
          currency = list.css('span.amount.currency').text.strip
          transaction_arr << Transactions.new(date, description, sign_amount, currency, iban)
          # end
        end
      end
    end
  end

  full_account_array << Accounts.new(accounts_arr[i].name,
                                     accounts_arr[i].balance,
                                     accounts_arr[i].currency,
                                     accounts_arr[i].nature,
                                     transaction_arr)
end
# Show the result.
full_account_array.each do |account|
  puts JSON.pretty_generate account
end
browser.close