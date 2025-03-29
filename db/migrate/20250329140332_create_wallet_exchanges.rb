class CreateWalletExchanges < ActiveRecord::Migration[8.0]
  def change
    create_table :wallet_exchanges do |t|
      t.decimal :source_wallet_amount_before, precision: 30, scale: 12, null: false
      t.decimal :source_wallet_amount_after, precision: 30, scale: 12, null: false
      t.decimal :target_wallet_amount_before, precision: 30, scale: 12, null: false
      t.decimal :target_wallet_amount_after, precision: 30, scale: 12, null: false


      t.references :exchange, null: false, foreign_key: true
      t.references :source_wallet, null: false, foreign_key: { to_table: :wallets }
      t.references :target_wallet, null: false, foreign_key: { to_table: :wallets }

      t.timestamps
    end

    add_index :wallet_exchanges, [ :exchange_id, :source_wallet_id, :target_wallet_id ], unique: true, name: 'idx_wallet_exchanges_unique'
  end
end
