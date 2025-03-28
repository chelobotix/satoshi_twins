class CreateWallets < ActiveRecord::Migration[8.0]
  def change
    create_table :wallets do |t|
      t.decimal :amount, precision: 30, scale: 12, default: 0.0, null: false
      t.boolean :active, default: true, null: false

      t.references :user, null: false, foreign_key: true
      t.references :currency, null: false, foreign_key: true

      t.timestamps
    end
  end
end
