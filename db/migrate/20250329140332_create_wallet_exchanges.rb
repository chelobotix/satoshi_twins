class CreateWalletExchanges < ActiveRecord::Migration[8.0]
  def change
    create_table :wallet_exchanges do |t|
      t.decimal :wallet_amount_before, precision: 30, scale: 12, null: false
      t.decimal :wallet_amount_after, precision: 30, scale: 12, null: false

      t.references :exchange, null: false, foreign_key: true
      t.references :wallet, null: false, foreign_key: true

      t.timestamps
    end
  end
end
