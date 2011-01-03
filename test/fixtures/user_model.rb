class UserModel < ActiveRecord::Base
  has_private_messages :message_class => 'MessageModel', :received_message_class => 'ReceivedMessageModel'
end
