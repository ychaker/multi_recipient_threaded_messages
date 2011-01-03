class MessageThreadModel < ActiveRecord::Base
  is_private_message_thread :user_class => 'UserModel', :message_class => 'MessageModel', :received_message_class => 'ReceivedMessageModel'
end