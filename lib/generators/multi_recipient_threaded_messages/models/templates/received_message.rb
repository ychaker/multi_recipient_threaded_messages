class <%= received_message_singular_camel_case %> < ActiveRecord::Base

  is_received_private_message :user_class => "<%= "#{user_singular_camel_case}" %>", :message_class => "<%= "#{message_singular_camel_case}" %>", :message_thread_class => "<%= "#{message_thread_singular_camel_case}" %>"
  
  # The :to accessor is used by the scaffolding,
  # uncomment it if using it or you can remove it if not
  # def to
  #   self.sent_message.to
  # end
  
end