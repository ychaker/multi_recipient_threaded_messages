class MessagesController < ApplicationController
  
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
  
  # def new
  #   @message = Message.new
  # 
  #   if params[:reply_to]
  #     @reply_to = @user.received_messages.find(params[:reply_to])
  #     unless @reply_to.nil?
  #       @message.to = @reply_to.sender.login
  #       @message.subject = "Re: #{@reply_to.subject}"
  #       @message.body = "\n\n*Original message*\n\n #{@reply_to.body}"
  #     end
  #   end
  # end
  
  def new
    @message_thread = MessageThread.new
  end
  
  def create
    if params[:reply]
      @message = MessageThread.find(params[:reply][:thread_id])
      @message.reply_to_thread(params[:reply].merge(:sender => current_user))
    else
      recipients = User.where('id IN ?', params[:message][:recipients_ids])
      @message.creat_new_thread(params[:message].merge(:sender => current_user, :recipients => recipients))
    end
    if @message.save
      flash[:notice] = "Message sent"
      redirect_to user_messages_path(current_user)
    else
      render :action => :new
    end
  end
  
  # def create
  #   @message = Message.new(params[:message])
  #   @message.sender = @user
  #   @message.recipient = User.find_by_login(params[:message][:to])
  # 
  #   if @message.save
  #     flash[:notice] = "Message sent"
  #     redirect_to user_messages_path(@user)
  #   else
  #     render :action => :new
  #   end
  # end
  
  def delete_selected
    if request.post?
      if params[:delete]
        @message_threads =  MessageThread.with_participant(current_user).where("#{message_thread_singular_camel_case.table_name}.id IN ?", params[:delete])
        @message_threads.each { |thread|
          thread.mark_deleted(current_user)
        }
        flash[:notice] = "Messages deleted"
      end
      redirect_to user_messages_path(current_user)
    end
  end
end