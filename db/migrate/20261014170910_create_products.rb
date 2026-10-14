class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :price, null: false
      t.integer :status, default: 1, null: false # 1 = in_stock

      t.timestamps
    end

    # Index the slug for fast O(1) lookups by the LLM tool
    add_index :products, :slug, unique: true
  end
end