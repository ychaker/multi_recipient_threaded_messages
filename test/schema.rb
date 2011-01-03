ActiveRecord::Schema.define(:version => 0) do

  create_table :message_thread_models, :force => true do |t|
    t.string   :subject
    t.datetime :created_at
    t.datetime :updated_at
  end
  
  create_table :message_models, :force => true do |t|
    t.integer  :sender_id
    t.integer  :thread_id
    t.boolean  :sender_deleted,    :default => false
    t.text     :body
    t.datetime :created_at
    t.datetime :updated_at
  end

  create_table :user_models, :force => true do |t|
    t.string   :login
    t.datetime :created_at
    t.datetime :updated_at
  end

  create_table :received_message_models, :force => true do |t|
    t.boolean  :recipient_deleted, :default => false
    t.datetime :last_read_at
    t.boolean  :read, :default => false
    t.integer  :sent_message_id
    t.integer  :recipient_id
    t.datetime :created_at
    t.datetime :updated_at
  end

end