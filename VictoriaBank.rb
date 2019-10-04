require 'watir'
require 'webdrivers'
require 'nokogiri'
require_relative 'Accounts'
require_relative 'Transactions'
require_relative 'simple_account'

# Class VictoriaBank
class VictoriaBank
  def connect
    # Get username and password.
    puts 'Enter your username:'
    login = gets.chomp.to_s
    puts 'Enter your password:'
    psw = gets.chomp.to_s
    # Open browser and login on page.
    @browser = Watir::Browser.new :chrome
    @browser.goto('https://web.vb24.md/wb/#login')
    @browser.text_field(name: 'login').set login
    @browser.text_field(name: 'password').set psw
    @browser.button(type: 'submit').click
  end

  # Fetch and parse HTML document
  def fetch_accounts
    sleep 2
    @accounts = []
    @accounts = parse_accounts(@browser.html)
  end

  # Go to transaction page
  def nav_to_transactions
    @browser.link(href: '#menu/MAIN_215.CP_HISTORY').click
    sleep 2
    @browser.input(name: 'from').click
    # Set period from two month early
    (1..2).each { |i| @browser.a(title: '< Prev').click }
    # Get current date
    current_date = Time.now.strftime('%-d')
    @browser.a(text: current_date).click
  end

  def fetch_transactions
    sleep 3
    # Search transaction for each account
    @full_account_array = []
    @accounts.each do |account_item|
      iban = account_item.name
      @browser.div(class: 'chosen-container chosen-container-single contract-select chosen-container-single-nosearch').click
      @browser.span(text: iban).click
      # Wait for page charging.
      sleep 5
      # Fetch and parse HTML document
      transaction_arr = parse_transactions(iban, @browser.html)
      @full_account_array << Accounts.new(account_item.name,
                                          account_item.balance,
                                          account_item.currency,
                                          account_item.nature,
                                          transaction_arr)
    end
  end

  def show
    # Show the result.
    @full_account_array.each do |account|
      puts JSON.pretty_generate account
    end
  end

  def parse_accounts(html)
    doc = Nokogiri::HTML(html)
    accounts_arr = []
    nature = ''
    doc.css('div.contracts div.contracts-section div').each do |div|
      nature = div.text.strip if div.attr('class') == 'section-title h-small'
      div.css('div.main-info').each do |second_div|
        name = second_div.css('a.name').text.strip
        currency = second_div.css('div.icon div.currency-icon').text.strip
        balance = second_div.css('span.amount').text.strip.to_f
        accounts_arr << SimpleAccount.new(name, balance, currency, nature)
      end
    end
    accounts_arr
  end

  def parse_transactions(iban, html)
    transaction_arr = []
    # Fetch and parse HTML document
    doc = Nokogiri::HTML(html)
    doc.css('div.operations').each do |div|
      div.css('div.month-delimiter').each do |month_div|
        month_year = month_div.text.strip
        year = month_year.scan(/[\d]/).join('')
        month = Date::MONTHNAMES.index("#{month_year.scan(/[A-z]+/).join('')}")
        div.css('div.day-operations').each do |span|
          day_ = span.css('div.day-header').text.strip.gsub(/[^\d]/, '')
          span.css('ul.operations-list li').each do |list|
            date = "#{year}" + '-' + "#{month}" + '-' + "#{day_}"
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
          end
        end
      end
    end
    transaction_arr
  end

  def execute
    connect
    fetch_accounts
    nav_to_transactions
    fetch_transactions
    show
  end

end

