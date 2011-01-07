class <%= "Create#{message_thread_plural_camel_case}" %> < ActiveRecord::Migration
  def self.up
    create_table :<%= message_thread_plural_lower_case %> do |t|
      t.string :subject
      t.timestamps
    end
  end

  def self.down
    drop_table :<%= message_thread_plural_lower_case %>
  end
end