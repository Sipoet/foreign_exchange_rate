require "test_helper"

class ExchangeRateMovementIntegrationTest < ActionDispatch::IntegrationTest
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

  test 'insert daily exchange rate data' do
    params = {
      from_currency: @usd.code, 
      to_currency: @gbp.code,
      effective_date: '2018-07-05',
      rate: 0.75709
    }
    post exchange_rate_movements_url, params: params, xhr: true
    assert_response :success
    exchange_rate_movement = ::ExchangeRateMovement.first
    assert_equal(exchange_rate_movement.present?, true)
    assert_equal(params[:rate], exchange_rate_movement.rate)
    assert_equal(params[:effective_date], exchange_rate_movement.effective_date.try(:iso8601))
    exchange_rate = exchange_rate_movement.exchange_rate
    assert_equal(@usd.id, exchange_rate.from_currency_id)
    assert_equal(@gbp.id, exchange_rate.to_currency_id)
  end

  test 'insert daily exchange rate data - from currency can not equal with to currency' do
    params = {
      from_currency: @usd.code, 
      to_currency: @usd.code,
      effective_date: '2018-07-05',
      rate: 0.75709
    }
    post exchange_rate_movements_url, params: params, xhr: true
    assert_response 422
  end

  test 'get exchange rate report' do
    gbp_to_usd = create_exchange_rate(from_currency: @gbp, to_currency: @usd)
    usd_to_gbp = create_exchange_rate(from_currency: @usd, to_currency: @gbp)
    usd_to_idr = create_exchange_rate(from_currency: @usd, to_currency: @idr)
    jpy_to_idr = create_exchange_rate(from_currency: @jpy, to_currency: @idr)
    create_exchange_rate_movement(exchange_rate: gbp_to_usd, rate: 1.314233, effective_date: '2018-07-02')
    create_exchange_rate_movement(exchange_rate: gbp_to_usd, rate: 1.304095, effective_date: '2018-07-01')
    create_exchange_rate_movement(exchange_rate: gbp_to_usd, rate: 1.3, effective_date: '2018-06-30')
    create_exchange_rate_movement(exchange_rate: gbp_to_usd, rate: 1.4, effective_date: '2018-06-29')
    create_exchange_rate_movement(exchange_rate: gbp_to_usd, rate: 1.5, effective_date: '2018-06-28')
    create_exchange_rate_movement(exchange_rate: gbp_to_usd, rate: 1, effective_date: '2018-06-27')
    create_exchange_rate_movement(exchange_rate: gbp_to_usd, rate: 1.4, effective_date: '2018-06-26')
    create_exchange_rate_movement(exchange_rate: gbp_to_usd, rate: 1.346, effective_date: '2018-06-25')
    
    create_exchange_rate_movement(exchange_rate: usd_to_gbp, rate: 1.346, effective_date: '2018-07-03')
    create_exchange_rate_movement(exchange_rate: usd_to_gbp, rate: 0.7609, effective_date: '2018-07-02')
    create_exchange_rate_movement(exchange_rate: usd_to_gbp, rate: 1.2391, effective_date: '2018-07-01')
    create_exchange_rate_movement(exchange_rate: usd_to_gbp, rate: 1.1, effective_date: '2018-06-30')
    create_exchange_rate_movement(exchange_rate: usd_to_gbp, rate: 1.2, effective_date: '2018-06-29')
    create_exchange_rate_movement(exchange_rate: usd_to_gbp, rate: 0.9, effective_date: '2018-06-28')
    create_exchange_rate_movement(exchange_rate: usd_to_gbp, rate: 0.8, effective_date: '2018-06-27')
    create_exchange_rate_movement(exchange_rate: usd_to_gbp, rate: 1, effective_date: '2018-06-26')
    
    create_exchange_rate_movement(exchange_rate: usd_to_idr, rate: 14347, effective_date: '2018-07-02')
    create_exchange_rate_movement(exchange_rate: usd_to_idr, rate: 13653, effective_date: '2018-07-01')
    create_exchange_rate_movement(exchange_rate: usd_to_idr, rate: 13500, effective_date: '2018-06-30')
    create_exchange_rate_movement(exchange_rate: usd_to_idr, rate: 13000, effective_date: '2018-06-29')
    create_exchange_rate_movement(exchange_rate: usd_to_idr, rate: 12500, effective_date: '2018-06-28')
    create_exchange_rate_movement(exchange_rate: usd_to_idr, rate: 12200, effective_date: '2018-06-27')
    create_exchange_rate_movement(exchange_rate: usd_to_idr, rate: 11800, effective_date: '2018-06-26')

    create_exchange_rate_movement(exchange_rate: jpy_to_idr, rate: 128, effective_date: '2018-07-01')

    params = {
      effective_date: '2018-07-02'
    }
    response = get search_exchange_rate_movements_url, params: params, xhr: true
    assert_response :success
    response_body = JSON.parse(@response.body, symbolize_names: true)
    results = response_body[:results]
    expected_results = [
      {
        from_currency_code: @gbp.code,
        to_currency_code: @usd.code,
        rate: '1.314233',
        seven_day_avg: '1.316904'
      },
      {
        from_currency_code: @usd.code,
        to_currency_code: @gbp.code,
        rate: '0.7609',
        seven_day_avg: '1.0'
      },
      {
        from_currency_code: @usd.code,
        to_currency_code: @idr.code,
        rate: '14347.0',
        seven_day_avg: '13000.0'
      },
      {
        from_currency_code: @jpy.code,
        to_currency_code: @idr.code,
        rate: ::ExchangeRateMovementReport::INSUFICIENT_DATA,
        seven_day_avg: nil
      }
    ]
    assert_exchange_rate_movement_report_results(expected_results, results)
  end

  test 'if daily data is missing, it will give feedback insufficient data' do
    gbp_to_usd = create_exchange_rate(from_currency: @gbp, to_currency: @usd)
    create_exchange_rate_movement(exchange_rate: gbp_to_usd, rate: 1.314233, effective_date: '2018-07-02')
    params = {
      effective_date: '2018-07-02'
    }
    response = get search_exchange_rate_movements_url, params: params, xhr: true
    assert_response :success
    response_body = JSON.parse(@response.body, symbolize_names: true)
    results = response_body[:results]
    expected_results = [
      {
        from_currency_code: @gbp.code,
        to_currency_code: @usd.code,
        rate: ::ExchangeRateMovementReport::INSUFICIENT_DATA,
        seven_day_avg: nil
      }
    ]
    assert_exchange_rate_movement_report_results(expected_results, results)
    create_exchange_rate_movement(exchange_rate: gbp_to_usd, rate: 1.304095, effective_date: '2018-07-01')
    create_exchange_rate_movement(exchange_rate: gbp_to_usd, rate: 1.3, effective_date: '2018-06-30')
    create_exchange_rate_movement(exchange_rate: gbp_to_usd, rate: 1.4, effective_date: '2018-06-29')
    create_exchange_rate_movement(exchange_rate: gbp_to_usd, rate: 1.5, effective_date: '2018-06-28')
    create_exchange_rate_movement(exchange_rate: gbp_to_usd, rate: 1, effective_date: '2018-06-27')
    response = get search_exchange_rate_movements_url, params: params, xhr: true
    assert_response :success
    response_body = JSON.parse(@response.body, symbolize_names: true)
    results = response_body[:results]
    expected_results = [
      {
        from_currency_code: @gbp.code,
        to_currency_code: @usd.code,
        rate: ::ExchangeRateMovementReport::INSUFICIENT_DATA,
        seven_day_avg: nil
      }
    ]
    assert_exchange_rate_movement_report_results(expected_results, results)
    create_exchange_rate_movement(exchange_rate: gbp_to_usd, rate: 1.4, effective_date: '2018-06-26')
    response = get search_exchange_rate_movements_url, params: params, xhr: true
    assert_response :success
    response_body = JSON.parse(@response.body, symbolize_names: true)
    results = response_body[:results]
    expected_results = [
      {
        from_currency_code: @gbp.code,
        to_currency_code: @usd.code,
        rate: '1.314233',
        seven_day_avg: '1.316904'
      }
    ]
    assert_exchange_rate_movement_report_results(expected_results, results)
    create_exchange_rate_movement(exchange_rate: gbp_to_usd, rate: 1.346, effective_date: '2018-06-25')
    response = get search_exchange_rate_movements_url, params: params, xhr: true
    assert_response :success
    response_body = JSON.parse(@response.body, symbolize_names: true)
    results = response_body[:results]
    expected_results = [
      {
        from_currency_code: @gbp.code,
        to_currency_code: @usd.code,
        rate: '1.314233',
        seven_day_avg: '1.316904'
      }
    ]
    assert_exchange_rate_movement_report_results(expected_results, results)
  end

  private

  def assert_exchange_rate_movement_report_results(expected_results, results)
    assert_equal(expected_results.length, results.length)
    expected_results.each_with_index do |expected_result, index|
      result = results[index]
      assert_equal(expected_result[:from_currency_code], result[:from_currency_code], "row #{index+1} from_currency_code")
      assert_equal(expected_result[:to_currency_code], result[:to_currency_code], "row #{index+1} to_currency_code")
      assert_equal(expected_result[:rate], result[:rate], "row #{index+1} rate")
      if expected_result[:seven_day_avg].nil?
        assert_nil(result[:seven_day_avg], "row #{index+1} seven day avg")
      else
        assert_equal(expected_result[:seven_day_avg], result[:seven_day_avg], "row #{index+1} seven day avg")
      end
      
    end
  end

  def create_exchange_rate_movement(exchange_rate:, rate:, effective_date:)
    exchange_rate_movement = ExchangeRateMovement.new(exchange_rate: exchange_rate, 
                                                      rate: rate,
                                                      code: SecureRandom.uuid,
                                                      effective_date: effective_date)
    exchange_rate_movement.save!
    exchange_rate_movement
  end 

  def create_exchange_rate(from_currency:, to_currency:)
    exchange_rate = ExchangeRate.new(from_currency: from_currency, 
                                     to_currency: to_currency, 
                                     code: SecureRandom.uuid)
    exchange_rate.save!
    exchange_rate
  end

end