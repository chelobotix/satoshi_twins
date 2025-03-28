class CreateCurrencies < ActiveRecord::Migration[8.0]
  def change
    create_table :currencies do |t|
      t.string :name
      t.string :symbol

      t.timestamps
    end

    # Agrega índices únicos para name y symbol
    add_index :currencies, :name, unique: true
    add_index :currencies, :symbol, unique: true
  end
end
