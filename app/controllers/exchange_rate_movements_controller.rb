class ExchangeRateMovementsController < ApplicationController

  def create
    exchange_rate = ExchangeRate.find_by(exchange_rate_params)
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
    exchange_rate_report = ExchangeRateMovementReport.new(exchange_rate_report_params)
    if exchange_rate_report.valid?
      result = exchange_rate_report.data_result
      render json: {result: result}, status: :success
    else
      render_json_api_error errors: exchange_rate_report.errors
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