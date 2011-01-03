class <%= message_plural_camel_case %>Controller < ApplicationController
  
  before_filter :set_user
  
  def index
    if params[:mailbox] == "sent"
      @<%= message_plural_lower_case %> = @<%= user_singular_lower_case %>.sent_messages
    else
      @<%= message_plural_lower_case %> = @<%= user_singular_lower_case %>.received_messages
    end
  end
  
  def show
    @<%= message_singular_lower_case %> = <%= message_singular_camel_case %>.read(params[:id], current_user)
  end
  
  def new
    @<%= message_singular_lower_case %> = <%= message_singular_camel_case %>.new

    if params[:reply_to]
      @reply_to = @<%= user_singular_lower_case %>.received_messages.find(params[:reply_to])
      unless @reply_to.nil?
        @<%= message_singular_lower_case %>.to = @reply_to.sender.login
        @<%= message_singular_lower_case %>.subject = "Re: #{@reply_to.subject}"
        @<%= message_singular_lower_case %>.body = "\n\n*Original message*\n\n #{@reply_to.body}"
      end
    end
  end
  
  def create
    @<%= message_singular_lower_case %> = <%= message_singular_camel_case %>.new(params[:<%= message_singular_lower_case %>])
    @<%= message_singular_lower_case %>.sender = @<%= user_singular_lower_case %>
    @<%= message_singular_lower_case %>.recipient = <%= user_singular_camel_case %>.find_by_login(params[:<%= message_singular_lower_case %>][:to])

    if @<%= message_singular_lower_case %>.save
      flash[:notice] = "Message sent"
      redirect_to user_<%= message_plural_lower_case %>_path(@<%= user_singular_lower_case %>)
    else
      render :action => :new
    end
  end
  
  def delete_selected
    if request.post?
      if params[:delete]
        params[:delete].each { |id|
          @<%= message_singular_lower_case %> = <%= message_singular_camel_case %>.find(:first, :conditions => ["<%= message_plural_lower_case %>.id = ? AND (sender_id = ? OR recipient_id = ?)", id, @<%= user_singular_lower_case %>, @<%= user_singular_lower_case %>])
          @<%= message_singular_lower_case %>.mark_deleted(@<%= user_singular_lower_case %>) unless @<%= message_singular_lower_case %>.nil?
        }
        flash[:notice] = "Messages deleted"
      end
      redirect_to user_<%= message_singular_lower_case %>_path(@<%= user_singular_lower_case %>, @<%= message_plural_lower_case %>)
    end
  end
  
  private
    def set_user
      @<%= user_singular_lower_case %> = User.find(params[:<%= user_singular_lower_case %>_id])
    end
end