require 'rspec'
require_relative 'VictoriaBank'

describe 'VictoriaBank' do
  it 'parse_accounts return value an array' do
    victoriabank = VictoriaBank.new
    expect(victoriabank.parse_accounts("#{File.open('accounts.html').read}")).to be_an_instance_of(Array)
  end

  it 'parse_accounts should be equal to account data' do
    victoriabank = VictoriaBank.new
    accounts = victoriabank.parse_accounts("#{File.open('accounts.html').read}")
    result = accounts[0].as_json
    expect(result).to eq(
                          :name => 'MD22VI225931303201646102',
                          :balance => 173.67,
                          :currency => 'EUR',
                          :nature => 'Card Accounts'
                      )
  end


  it 'parse_transactions return value an array' do
    victoriabank = VictoriaBank.new
    account = 'MD22VI225931303201646102'
    expect(victoriabank.parse_transactions(account, "#{File.open('transactions.html').read}")).to be_an_instance_of(Array)
  end

  it 'parse_transactions should be show transaction data' do
    victoriabank = VictoriaBank.new
    account = 'MD22VI225931303201646102'
    transactions = victoriabank.parse_transactions(account, "#{File.open('transactions.html').read}")
    result = transactions[0].as_json
    expect(result).to eq(
                          :date => '2019-10-1',
                          :description => 'Debit Account  : Client Account --> Client Account -> Cl Deposit',
                          :amount => 3.88,
                          :currency => 'MDL',
                          :account_name => 'MD22VI225931303201646102'
                      )
  end
end