class CreateExchangeRates < ActiveRecord::Migration[5.2]
  def change
    create_table :exchange_rates do |t|
      t.string :code, null: false
      t.integer :from_currency_id, null: false
      t.integer :to_currency_id, null: false
      t.timestamps
    end
    add_foreign_key :exchange_rates, :currencies, column: :from_currency_id
    add_foreign_key :exchange_rates, :currencies, column: :to_currency_id

    add_index :exchange_rates, :code, unique: true
    add_index :exchange_rates, [:from_currency_id, :to_currency_id], unique: true, name: 'exchange_rate_uniq_index'
  end
end
