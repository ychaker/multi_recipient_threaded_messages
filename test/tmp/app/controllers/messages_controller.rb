class MessagesController < ApplicationController
  # This assumes you have some sort of authentication in place whith a require_user method in the ApplicationController
  # and with a current_user method that initializes the @current_user object and return the logged in user
  before_filter :require_user
  
  def index
    if params[:mailbox] == "sent"
      @message_threads = MessageThread.sent_by(current_user)
    else
      @message_threads = MessageThread.received_by(current_user)
    end
  end
  
  def show
    @message_thread = MessageThread.read(params[:id], current_user)
  end
  
  def new
    @message_thread = MessageThread.new
  end
  
  def create
    if params[:reply]
      @message_thread = MessageThread.find(params[:reply][:thread_id])
      @message_thread.reply_to_thread(params[:reply].merge(:sender => current_user))
    else
      recipients = User.where('id IN ?', params[:message][:recipients_ids])
      @message_thread= MessageThread.create_new_thread(params[:message].merge(:sender => current_user, :recipients => recipients))
    end
    if @message_thread.save
      flash[:notice] = "Message sent"
      redirect_to user_messages_path(current_user)
    else
      render :action => :new
    end
  end
  
  def delete_selected
    if request.post?
      if params[:delete]
        if params[:delete].length == 1
          @message_threads =  MessageThread.with_participant(current_user).where("message_threads.id = ?", params[:delete])
        else
          @message_threads =  MessageThread.with_participant(current_user).where("message_threads.id IN ?", params[:delete])
        end
        @message_threads.each { |thread|
          thread.mark_deleted(current_user)
        }
        flash[:notice] = "Messages deleted"
      end
      redirect_to user_messages_path(current_user)
    end
  end
end