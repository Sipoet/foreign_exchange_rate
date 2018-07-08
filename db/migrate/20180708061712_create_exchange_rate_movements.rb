class CreateExchangeRateMovements < ActiveRecord::Migration[5.2]
  def change
    create_table :exchange_rate_movements do |t|
      t.string :code, null: false
      t.integer :exchange_rate_id, null: false
      t.date :effective_date, null: false
      t.float :rate, null: false, precision: 20, scale: 6
      t.timestamps
    end
    add_foreign_key :exchange_rate_movements, :exchange_rates, column: :exchange_rate_id

    add_index :exchange_rate_movements, :code, unique: true
    add_index :exchange_rate_movements, [:exchange_rate_id, :effective_date], unique: true, name: 'exchange_rate_movement_uniq_index'
  end
end
