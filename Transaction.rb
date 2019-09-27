require 'json'
class Transactions

  attr_accessor :amount, :account_name, :description, :currency, :date

  def initialize(date, description, amount, currency, account_name)
    @date = date
    @description = description
    @amount = amount
    @currency = currency
    @account_name = account_name
  end

  def to_json(*args)
    {
        JSON.create_id => "transactions",
        'date' => date,
        'description' => description,
        'amount' => amount,
        'currency' => currency,
        'account_name' => account_name
    }.to_json(*args)
  end

  def self.json_create(h)
    new(h['date'], h['description'], h['amount'], h['currency'], h['account_name'])
  end

end