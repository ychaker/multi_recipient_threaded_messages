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
  
  def message_input_field name, type, input, errors
    display = ""
    value = input.blank? ? "" : input[name] || input[name.to_sym]
    css_class = (!errors.blank? && !errors[name.to_sym].blank?) ? 'formError' : ''
    if type == 'text_field'
      display << text_field_tag("message[#{name}]", value, :class => css_class)
    elsif type == 'text_area'
      display << text_area_tag("message[#{name}]", value, :class => css_class)
    end
    if (!errors.blank? && !errors[name.to_sym].blank?)
      display << "<div class='formErrorMessage'>#{errors[name.to_sym]}</div>"
    end
    raw(display)
  end
end
