class Transactions

  attr_accessor :amount, :account_name, :description, :currency, :date

  def initialize(date, description, amount, currency, account_name)
    @date = date
    @description = description
    @amount = amount
    @currency = currency
    @account_name = account_name
  end

end