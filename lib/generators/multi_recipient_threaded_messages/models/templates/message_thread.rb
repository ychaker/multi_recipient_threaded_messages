class <%= message_thread_singular_camel_case %> < ActiveRecord::Base

  is_private_message_thread :user_class => "<%= "#{user_singular_camel_case}" %>", :message_class => "<%= "#{message_singular_camel_case}" %>", :received_message_class => "<%= "#{received_message_singular_camel_case}" %>"
  
end