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
  
  # def new
  #   @<%= message_singular_lower_case %> = <%= message_singular_camel_case %>.new
  # 
  #   if params[:reply_to]
  #     @reply_to = @<%= user_singular_lower_case %>.received_messages.find(params[:reply_to])
  #     unless @reply_to.nil?
  #       @<%= message_singular_lower_case %>.to = @reply_to.sender.login
  #       @<%= message_singular_lower_case %>.subject = "Re: #{@reply_to.subject}"
  #       @<%= message_singular_lower_case %>.body = "\n\n*Original message*\n\n #{@reply_to.body}"
  #     end
  #   end
  # end
  
  def new
    @<%= message_thread_singular_lower_case %> = <%= message_thread_singular_camel_case %>.new
  end
  
  def create
    if params[:reply]
      @<%= message_singular_lower_case %> = <%= message_thread_singular_camel_case %>.find(params[:reply][:thread_id])
      @<%= message_singular_lower_case %>.reply_to_thread(params[:reply].merge(:sender => current_user))
    else
      recipients = <%= user_singular_camel_case %>.where('id IN ?', params[:message][:recipients_ids])
      @<%= message_singular_lower_case %>.creat_new_thread(params[:message].merge(:sender => current_user, :recipients => recipients))
    end
    if @<%= message_singular_lower_case %>.save
      flash[:notice] = "Message sent"
      redirect_to user_<%= message_plural_lower_case %>_path(current_user)
    else
      render :action => :new
    end
  end
  
  # def create
  #   @<%= message_singular_lower_case %> = <%= message_singular_camel_case %>.new(params[:<%= message_singular_lower_case %>])
  #   @<%= message_singular_lower_case %>.sender = @<%= user_singular_lower_case %>
  #   @<%= message_singular_lower_case %>.recipient = <%= user_singular_camel_case %>.find_by_login(params[:<%= message_singular_lower_case %>][:to])
  # 
  #   if @<%= message_singular_lower_case %>.save
  #     flash[:notice] = "Message sent"
  #     redirect_to user_<%= message_plural_lower_case %>_path(@<%= user_singular_lower_case %>)
  #   else
  #     render :action => :new
  #   end
  # end
  
  def delete_selected
    if request.post?
      if params[:delete]
        @<%= message_thread_plural_lower_case %> =  <%= message_thread_singular_camel_case %>.with_participant(current_user).where("#{message_thread_singular_camel_case.table_name}.id IN ?", params[:delete])
        @<%= message_thread_plural_lower_case %>.each { |thread|
          thread.mark_deleted(current_user)
        }
        flash[:notice] = "Messages deleted"
      end
      redirect_to user_<%= message_plural_lower_case %>_path(current_user)
    end
  end
end