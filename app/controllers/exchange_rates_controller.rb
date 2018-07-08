class ExchangeRatesController < ApplicationController

  def create
    from_currency = create_currency_if_not_exists(params[:from_currency])
    to_currency = create_currency_if_not_exists(params[:to_currency])
    exchange_rate = ExchangeRate.find_or_initialize_by(from_currency: from_currency,
                                                       to_currency: to_currency)
    exchange_rate.code = SecureRandom.uuid
    if exchange_rate.save
      render_json_api_success message: 'Exchange rate success created'
    else
      render_json_api_error errors: exchange_rate.errors
    end
  end

  def destroy
    exchange_rate = ExchangeRate.find_by(exchange_rate_params)
    if exchange_rate_report.present?
      if exchange_rate.destroy
        render_json_api_success message: 'Exchange rate success destroyed'
      else
        render_json_api_error message: 'Exchange rate failed destroyed'
      end
    else
      render_json_api_not_found message: 'Exchange rate not found'
    end
  end

  private

  def create_currency_if_not_exists(currency_code)
    currency = ::Currency.find_or_initialize_by(code: currency_code.upcase)
    currency.save! if currency.new_record?
    currency
  end

  def exchange_rate_report_params
    params.permit(:effective_date)
  end
end