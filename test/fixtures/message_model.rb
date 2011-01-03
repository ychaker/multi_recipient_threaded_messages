class MessageModel < ActiveRecord::Base
  is_private_message :user_class => 'UserModel', :received_message_class => 'ReceivedMessageModel', :message_thread_class => 'MessageThreadModel'
end