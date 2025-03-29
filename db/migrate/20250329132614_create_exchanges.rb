class CreateExchanges < ActiveRecord::Migration[8.0]
  def change
    create_table :exchanges do |t|
      t.decimal :send_amount, precision: 30, scale: 12, null: false
      t.decimal :receive_amount, precision: 30, scale: 12, null: false
      t.decimal :exchange_rate, precision: 30, scale: 12, null: false
      t.string :aasm_state, null: false

      t.references :send_currency, foreign_key: { to_table: :currencies }
      t.references :receive_currency, foreign_key: { to_table: :currencies }

      t.timestamps
    end
  end
end
