class <%= "Create#{received_message_plural_camel_case}" %> < ActiveRecord::Migration
  def self.up
    create_table :<%= received_message_plural_lower_case %> do |t|
      t.integer   :recipient_id
      t.integer   :sent_message_id
      t.boolean   :recipient_deleted, :default => false
      t.datetime  :last_read_at
      t.boolean   :read, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :<%= received_message_plural_lower_case %>
  end
end