require 'watir'
require 'webdrivers'
require 'nokogiri'


url = "https://web.vb24.md/wb/#login"
login = "myusername"
psw = "mypassword"
browser = Watir::Browser.new :chrome
browser.goto(url)
browser.text_field(name: 'login').set login
browser.text_field(name: 'password').set psw
browser.button(type: 'submit').click


sleep(2)


browser.link(href: '#menu/MAIN_215.CP_HISTORY').click
sleep(2)


browser.div(class: 'chosen-container chosen-container-single contract-select chosen-container-single-nosearch').click
browser.span(text: 'MD22VI225931303201646102').click
browser.input(name: 'from').click
for i in 1..5 do
  (browser.a(title: '< Prev').click)
end
browser.a(text: '1').click

sleep(10)

transactionsArr = Array.new

TransactionStr = Struct.new :date, :discription, :amount, :currency, :account_name
#Fetch and parse HTML document
doc = Nokogiri::HTML(browser.html)

@account_name = 'MD22VI225931303201646102'
doc.xpath('//div[@class="operations"]').each do |div|
  div.search('div[@class="month-delimiter"]').each do |month_div|
    @month_year = month_div.text.strip
    div.search('div[@class="day-operations"]').each do |span|
      span.search('div[@class="day-header"]').each do |day|
        @day = (day.text.strip).gsub(/[^\d]/, "")
      end
      span.search('ul[@class="operations-list"]/li').each do |list|
        list.search('span').each do |cell|
          @time = cell.text.strip if cell.attr('class') == ('history-item-time')
          @date = "#@day " + "#@month_year " + "#@time"
          @discription = cell.text.strip if cell.attr('class') == ('history-item-description')
          if (cell.attr('class') == ('history-item-amount transaction ') || cell.attr('class') == ('history-item-amount transaction income'))
            money = cell.text.strip
            @amount = money.to_s.scan(/\+?\d+\.\d+/)
            @currency = money.to_s.scan(/[A-Z]+/)
            transactionsArr.push(TransactionStr.new(@date, @discription, @amount, @currency, @account_name))
          end
        end
      end
    end
  end
end


puts transactionsArr
sleep(9)


browser.close
