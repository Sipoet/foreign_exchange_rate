require "test_helper"

class ExchangeRateIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @usd = ::Currency.new(code: 'USD')
    @usd.save!
    @gbp = ::Currency.new(code: 'GBP')
    @gbp.save!
    @idr = ::Currency.new(code: 'IDR')
    @idr.save!
    @jpy = ::Currency.new(code: 'JPY')
    @jpy.save!
  end

  test 'create exchange rate list' do
    params = {
      from_currency: @usd.code, 
      to_currency: @gbp.code
    }
    post exchange_rates_url, params: params, xhr: true
    assert_response :success
    exchange_rate = ::ExchangeRate.first
    assert_equal(exchange_rate.present?, true)
    assert_equal(@usd.id, exchange_rate.from_currency_id)
    assert_equal(@gbp.id, exchange_rate.to_currency_id)
  end

  test 'destroy exhange rate list' do
    exchange_rate = ::ExchangeRate.new(code: 'ER001',
                                       from_currency: @usd, 
                                       to_currency: @gbp)
    exchange_rate.save!
    params = {
      from_currency: @usd.code, 
      to_currency: @gbp.code
    }
    delete exchange_rates_url, params: params, xhr: true
    number_row_of_exchange_rate = ::ExchangeRate.all.count
    assert_equal(number_row_of_exchange_rate, 0)
  end


end