class Accounts
  attr_accessor :name, :currency, :nature, :balance, :transactions

  def initialize(name, balance, currency, nature, transactions)
    @name = name
    @balance = balance
    @currency = currency
    @nature = nature
    @transactions = transactions
  end


end