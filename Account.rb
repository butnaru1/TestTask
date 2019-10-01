require 'json'
require 'Transactions'

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
  def to_json(*args) 
    {
        Accounts => 'accounts:',
        'name' => name,
        'balance' => balance,
        'currency' => currency,
        'nature' => nature,
        'transactions' => transactions
    }.to_json(*args)
  end

  def self.json_create(h)
    new(h['name'], h['balance'], h['currency'], h['nature'], h['transactions'])
  end
end
