require 'json'

# Account without Transaction
class SimpleAccount
  attr_accessor :name, :currency, :nature, :balance

  def initialize(name, balance, currency, nature)
    @name = name
    @balance = balance
    @currency = currency
    @nature = nature
  end
  # Methods for objects representation in JSON.
  def as_json(options={})
    {
        name: @name,
        balance: @balance,
        currency: @currency,
        nature: @nature,
    }
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end
end