class CreateConversations < ActiveRecord::Migration[7.2]
  def change
    create_table :conversations do |t|
      t.jsonb :messages, default: [], null: false

      t.timestamps
    end
  end
end
