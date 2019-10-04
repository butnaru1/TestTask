require 'rspec'
require_relative 'VictoriaBank'

describe 'VictoriaBank' do
  it 'parse_accounts return value an array' do
    victoriabank = VictoriaBank.new
    expect(victoriabank.parse_accounts("#{File.open('Cards and accounts.html').read}")).to be_an_instance_of(Array)
  end

  it 'parse_transactions return value an array' do
    victoriabank = VictoriaBank.new
    account = 'MD22VI225931303201646102'
    expect(victoriabank.parse_transactions(account, "#{File.open('Operations history.html').read}")).to be_an_instance_of(Array)
  end
end