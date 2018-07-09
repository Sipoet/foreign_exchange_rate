class ExchangeRateMovementsController < ApplicationController

  def create
    exchange_rate = create_exchange_rate_if_not_exists(from_currency_code: params[:from_currency],
                                                       to_currency_code: params[:to_currency])
    if exchange_rate.present?
      exchange_rate_movement = ExchangeRateMovement.find_or_initialize_by(exchange_rate: exchange_rate,
                                                                       effective_date: params[:effective_date])
      exchange_rate_movement.rate = params[:rate].try(:to_f)
      if exchange_rate_movement.new_record?
        exchange_rate_movement.code = SecureRandom.uuid
      end
      if exchange_rate_movement.save
        render_json_api_success message: 'Exchange rate success created'
      else
        render_json_api_error errors: exchange_rate_movement.errors
      end
    else
      render_json_api_not_found message: 'Exchange rate not found'
    end
  end
  
  def search
    exchange_rate_report = ExchangeRateMovementReport.new(effective_date: params[:effective_date])
    if exchange_rate_report.valid?
      render_json_api_success results: exchange_rate_report.data_results
    else
      render_json_api_error errors: exchange_rate_report.errors
    end
  end

  private

  def create_exchange_rate_if_not_exists(from_currency_code:, to_currency_code: )
    from_currency = create_currency_if_not_exists(from_currency_code)
    to_currency = create_currency_if_not_exists(to_currency_code)
    exchange_rate = ::ExchangeRate.find_or_initialize_by(from_currency: from_currency,
                                                         to_currency: to_currency)
    if exchange_rate.new_record?
      exchange_rate.code = SecureRandom.uuid
      exchange_rate.save!
    end
    exchange_rate
  end

  def create_currency_if_not_exists(currency_code)
    currency = ::Currency.find_or_initialize_by(code: currency_code.upcase)
    currency.save! if currency.new_record?
    currency
  end
end