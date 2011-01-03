class <%= message_singular_camel_case %> < ActiveRecord::Base

  is_private_message<% unless user_singular_camel_case == "User" %> :class_name => "<%= "#{user_singular_camel_case}" %>"<% end %>
  
  # The :to accessor is used by the scaffolding,
  # uncomment it if using it or you can remove it if not
  #attr_accessor :to
  
end