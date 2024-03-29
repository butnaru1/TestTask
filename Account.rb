require 'json'

# Class Accounts
class Accounts
  attr_accessor :name, :currency, :nature, :transactions, :balance

  def initialize(name, balance, currency, nature, transactions)
    @name = name
    @balance = balance
    @currency = currency
    @nature = nature
    @transactions = transactions
  end

  # Methods for objects representation in JSON.
  def as_json(options={})
    {
        name: @name,
        balance: @balance,
        currency: @currency,
        nature: @nature,
        transactions: @transactions
    }
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end
end
