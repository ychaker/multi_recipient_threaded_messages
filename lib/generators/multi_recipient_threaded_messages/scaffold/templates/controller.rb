class <%= message_plural_camel_case %>Controller < ApplicationController
  # This assumes you have some sort of authentication in place whith a require_user method in the ApplicationController
  # and with a current_user method that initializes the @current_user object and return the logged in user
  before_filter :require_user
  
  def index
    if params[:mailbox] == "sent"
      @<%= message_thread_plural_lower_case %> = <%= message_thread_singular_camel_case %>.sent_by(current_user)
    else
      @<%= message_thread_plural_lower_case %> = <%= message_thread_singular_camel_case %>.received_by(current_user)
    end
  end
  
  def show
    @<%= message_thread_singular_lower_case %> = <%= message_thread_singular_camel_case %>.read(params[:id], current_user)
  end
  
  def new
    @<%= message_thread_singular_lower_case %> = <%= message_thread_singular_camel_case %>.new
  end
  
  def create
    if params[:reply]
      @<%= message_thread_singular_lower_case %> = <%= message_thread_singular_camel_case %>.find(params[:reply][:thread_id])
      @<%= message_thread_singular_lower_case %>.reply_to_thread(params[:reply].merge(:sender => current_user))
    else
      recipients = <%= user_singular_camel_case %>.where('id IN ?', params[:message][:recipients_ids])
      @<%= message_thread_singular_lower_case %>= <%= message_thread_singular_camel_case %>.create_new_thread(params[:message].merge(:sender => current_user, :recipients => recipients))
    end
    if @<%= message_thread_singular_lower_case %>.save
      flash[:notice] = "Message sent"
      redirect_to <%= user_singular_lower_case %>_<%= message_plural_lower_case %>_path(current_user)
    else
      render :action => :new
    end
  end
  
  def delete_selected
    if request.post?
      if params[:delete]
        if params[:delete].length == 1
          @<%= message_thread_plural_lower_case %> =  <%= message_thread_singular_camel_case %>.with_participant(current_user).where("<%= message_thread_singular_camel_case.constantize.table_name %>.id = ?", params[:delete])
        else
          @<%= message_thread_plural_lower_case %> =  <%= message_thread_singular_camel_case %>.with_participant(current_user).where("<%= message_thread_singular_camel_case.constantize.table_name %>.id IN ?", params[:delete])
        end
        @<%= message_thread_plural_lower_case %>.each { |thread|
          thread.mark_deleted(current_user)
        }
        flash[:notice] = "Messages deleted"
      end
      redirect_to <%= user_singular_lower_case %>_<%= message_plural_lower_case %>_path(current_user)
    end
  end
end