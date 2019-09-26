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

acountsArr = Array.new
AcountStr = Struct.new :name, :currency, :ballance, :nature

#Fetch and parse HTML document
doc = Nokogiri::HTML(browser.html)


doc.xpath('//div[@class="contracts"]/div/div').each do |div|
  @nature = div.text.strip if div.attr('class') == ('section-title h-small')

  div.search('div').each do |subdiv1|
    @name = subdiv1.search('a.name').text.strip
    subdiv1.search('div/div').each do |subdiv2|
      @currency = subdiv2.text.strip if subdiv2.attr('class') == ('currency-icon')
      subdiv2.search('span').each do |span|
        if span.attr('class') == ('amount')
          @ballance = span.text.strip
          acountsArr.push(AcountStr.new(@name, @currency, @ballance, @nature))
        end
      end
    end
  end

end

puts acountsArr
sleep(10)

browser.close
