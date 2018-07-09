class ExchangeRateMovementReport < ApplicationReport

  INSUFICIENT_DATA = 'insuficient data'

  attr_reader :effective_date

  validates :effective_date, presence: true

  def initialize(effective_date:)
    @effective_date = Date.parse(effective_date)
  rescue
    @effective_date = nil
  end

  def data_results
    week_before_effective_date = effective_date - 6.days
    query_sql = "
      SELECT
        currency_query.from_currency_id,
        currency_query.from_currency_code,
        currency_query.to_currency_id,
        currency_query.to_currency_code,
        effective_rate_query.rate,
        avg_rate_query.seven_day_avg
      FROM (
        SELECT
          er.id AS exchange_rate_id,
          fc.id AS from_currency_id,
          fc.code AS from_currency_code,
          tc.id AS to_currency_id,
          tc.code AS to_currency_code
        FROM exchange_rates er
        INNER JOIN currencies fc
        ON
          fc.id = er.from_currency_id
        INNER JOIN currencies tc
        ON
          tc.id = er.to_currency_id
      ) currency_query
      LEFT OUTER JOIN (
        SELECT
          exchange_rate_id,
          rate
        FROM exchange_rate_movements
        WHERE
          effective_date = '#{effective_date.to_formatted_s(:db)}'
      ) effective_rate_query
      ON
        effective_rate_query.exchange_rate_id = currency_query.exchange_rate_id
      LEFT OUTER JOIN (
        SELECT
          exchange_rate_id,
          AVG(rate) AS seven_day_avg
        FROM exchange_rate_movements
        WHERE
          effective_date BETWEEN '#{week_before_effective_date.to_formatted_s(:db)}' AND '#{effective_date.to_formatted_s(:db)}'
        GROUP BY
          exchange_rate_id
        HAVING
          COUNT(*) = 7
      ) avg_rate_query
      ON
        avg_rate_query.exchange_rate_id = currency_query.exchange_rate_id
    "
    query_result = base_connection.execute(query_sql)
    query_result.map {|row| decorate_row_result(row)}
  end

  private

  def decorate_row_result(row)
    if row['rate'].present? && row['seven_day_avg'].present?
      rate = row['rate']
      seven_day_avg = row['seven_day_avg']
    else
      rate = INSUFICIENT_DATA
      seven_day_avg = nil
    end
    {
      from_currency_id: row['from_currency_id'].to_i,
      from_currency_code: row['from_currency_code'],
      to_currency_id: row['to_currency_id'].to_i,
      to_currency_code: row['to_currency_code'],
      rate: rate,
      seven_day_avg: seven_day_avg
    }
  end

  def base_connection
    ActiveRecord::Base.connection
  end
end