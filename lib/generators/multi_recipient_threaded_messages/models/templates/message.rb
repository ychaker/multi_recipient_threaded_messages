class <%= message_singular_camel_case %> < ActiveRecord::Base

  is_private_message # :user_class => "<%= "#{user_singular_camel_case}" %>", :received_message_class => "<%= "#{received_message_singular_camel_case}" %>", :message_thread_class => "<%= "#{message_thread_singular_camel_case}" %>" # uncomment the class names if not using the defaults
  
end
