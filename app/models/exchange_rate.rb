class ExchangeRate < ApplicationRecord

  has_many :exchange_rate_movements, dependent: :destroy
  belongs_to :from_currency, class_name: 'Currency'
  belongs_to :to_currency, class_name: 'Currency'

  validates :code, presence: true
  validates :from_currency, presence: true
  validates :to_currency, presence: true

  validate :from_currency_should_not_equal_with_to_currency
  validate :from_currency_and_to_currency_combination_should_unique

  private

  def from_currency_should_not_equal_with_to_currency
    if from_currency.blank? && to_currency.blank?
      return
    end
    if from_currency_id == to_currency_id
      errors.add(:from_currency, 'must not same with to currency')
      errors.add(:to_currency, 'must not same with from currency')
    end
  end

  def from_currency_and_to_currency_combination_should_unique
    exchange_rates = ExchangeRate.where(from_currency: from_currency,
                                        to_currency: to_currency)
    if exchange_rates.present?
      errors.add(:base, 'combination already exists')
    end
  end
end
