require 'watir'
require 'webdrivers'
require 'nokogiri'
require 'C:\Users\olegb\RubymineProjects\untitled\accounts'
require 'C:\Users\olegb\RubymineProjects\untitled\transactions'


login = 'myusername'
psw = 'mypassword'
browser = Watir::Browser.new :chrome
browser.goto('https://web.vb24.md/wb/#login')
browser.text_field(name: 'login').set login
browser.text_field(name: 'password').set psw
browser.button(type: 'submit').click


sleep(2)
acountsArr = []

# Fetch and parse HTML document
doc = Nokogiri::HTML(browser.html)
# Collect information about accounts
doc.xpath('//div[@class="contracts"]/div/div').each do |div|
  @nature = div.text.strip if div.attr('class') == ("section-title h-small")
  div.search('div').each do |second_div|
    @name = second_div.search('a.name').text.strip
    second_div.search('div/div').each do |third_div|
      @currency = third_div.text.strip if third_div.attr('class') == ("currency-icon")
      third_div.search('span').each do |span|
        if span.attr('class') == 'amount'
          @ballance = span.text.strip
          acountsArr.push(Array.new [@name, @ballance, @currency, @nature])
        end
      end
    end
  end
end


sleep(2)
# Go to transaction page
browser.link(href: '#menu/MAIN_215.CP_HISTORY').click
sleep(2)
browser.input(name: 'from').click
# Set period from two month early
(1..2).each { |i| browser.a(title: '< Prev').click }
browser.a(text: Time.now.strftime("%d")).click
fullAccountArray = []
# Search transaction for each account
(0...acountsArr.size).each do |i|
  @iban = acountsArr[i][0]
  transactionArr = []
  browser.div(class: 'chosen-container chosen-container-single contract-select chosen-container-single-nosearch').click
  browser.span(text: @iban).click

# Wait for page charging 
  sleep(10)

# Fetch and parse HTML document
  doc = Nokogiri::HTML(browser.html)
  doc.xpath('//div[@class="operations"]').each do |div|
    div.search('div[@class="month-delimiter"]').each do |month_div|
      month_year = month_div.text.strip
      div.search('div[@class="day-operations"]').each do |span|
        span.search('div[@class="day-header"]').each do |day|
          @day_ = day.text.strip.gsub(/[^\d]/, '')
        end
        span.search('ul[@class="operations-list"]/li').each do |list|
          list.search('span').each do |cell|
            time = cell.text.strip if cell.attr('class') == ('history-item-time')
            @date = "#{@day_} " + "#{month_year}" + "#{time}"
            @discription = cell.text.strip if cell.attr('class') == ('history-item-description')
            next unless cell.attr('class') == ('history-item-amount transaction ') ||
                cell.attr('class') == ('history-item-amount transaction income')
            money = cell.text.strip
            @amount = money.to_s.scan(/\+?\d+\.\d+/)
            @currency = money.to_s.scan(/[A-Z]+/)
            transactionArr.push(Transactions.new(@date, @discription, @amount, @currency, @iban))
          end
        end
      end
    end
  end
  fullAccountArray.push(Accounts.new((acountsArr[i][0]).to_s, (acountsArr[i][1]).to_s,
                                     (acountsArr[i][2]).to_s, (acountsArr[i][3]).to_s,
                                     transactionArr))
end
#Show results
fullAccountArray.each do |account|
  puts JSON.pretty_generate account

end

sleep(9)

browser.close