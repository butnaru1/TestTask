require 'rspec'
require_relative 'VictoriaBank'

describe 'VictoriaBank' do
  it 'parse_accounts return value an array' do
    victoriabank = VictoriaBank.new
    expect(victoriabank.parse_accounts("#{File.open('Cards and accounts.html').read}")).to be_an_instance_of(Array)
  end

  it 'parse_accounts should be show account data' do
    victoriabank = VictoriaBank.new
    puts JSON.pretty_generate victoriabank.parse_accounts("#{File.open('Cards and accounts.html').read}")
  end

  it 'parse_transactions return value an array' do
    victoriabank = VictoriaBank.new
    account = 'MD22VI225931303201646102'
    expect(victoriabank.parse_transactions(account, "#{File.open('Operations history.html').read}")).to be_an_instance_of(Array)
  end

  it 'parse_transactions should be show transaction data' do
    victoriabank = VictoriaBank.new
    account = 'MD22VI225931303201646102'
    puts JSON.pretty_generate victoriabank.parse_transactions(account, "#{File.open('Operations history.html').read}")
  end
end