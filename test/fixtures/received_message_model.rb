class ReceivedMessageModel < ActiveRecord::Base
  is_received_private_message :user_class => 'UserModel', :message_class => 'MessageModel'
end