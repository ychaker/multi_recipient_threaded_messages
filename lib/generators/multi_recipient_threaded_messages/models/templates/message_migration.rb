class <%= "Create#{message_plural_camel_case}" %> < ActiveRecord::Migration
  def self.up
    create_table :<%= message_plural_lower_case %> do |t|
      t.integer :thread_id
      t.integer :sender_id
      t.boolean :sender_deleted, :default => false
      t.text :body
      t.timestamps
    end
  end

  def self.down
    drop_table :<%= message_plural_lower_case %>
  end
end