module <%= message_plural_camel_case %>Helper
  def display_thread_participants thread
    display_thread_users thread.participants
  end
  
  def display_thread_recipients thread
    display_thread_users thread.recipients
  end
  
  def display_thread_users users
    display = ""
    users.each do |user|
      display << ", " unless display.blank?
      display << link_to_user_profile(user)
    end
    raw(display)
  end
end
