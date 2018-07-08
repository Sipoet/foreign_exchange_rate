class ExchangeRateMovement < ApplicationRecord

  belongs_to :exchange_rate

  validates :code, presence: true
  validates :exchange_rate, presence: true
  validates :effective_date, presence: true,
                             timeliness: {type: :date}
  validates :rate, presence: true,
                   numericality: {greater_than: 0}
end
