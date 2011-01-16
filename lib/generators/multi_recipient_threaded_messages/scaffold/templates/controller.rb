class <%= message_plural_camel_case %>Controller < ApplicationController
  # This assumes you have some sort of authentication in place whith a require_user method in the ApplicationController
  # and with a current_user method that initializes the @current_user object and return the logged in user
  before_filter :require_user
  
  def index
    if params[:mailbox] == "sent"
      @<%= message_thread_plural_lower_case %> = <%= message_thread_singular_camel_case %>.sent_by(current_user).uniq
    else
      @<%= message_thread_plural_lower_case %> = <%= message_thread_singular_camel_case %>.received_by(current_user).uniq
    end
  end
  
  def show
    @<%= message_thread_singular_lower_case %> = <%= message_thread_singular_camel_case %>.read(params[:id], current_user)
  end
  
  def new
    @<%= message_thread_singular_lower_case %> = <%= message_thread_singular_camel_case %>.new
  end
  
  def create
    @user_input = {}
    @user_input.merge!(params[:message]) unless params[:message].blank?
    @user_input.merge!(params[:reply]) unless params[:reply].blank?
    @recipients = get_message_recipients params
    @errors = validate_message params
    if params[:reply]
      unless @errors.blank?
        flash[:error] = "Message Body can not be blank."
        redirect_to :action => :show, :id => params[:reply][:thread_id]
        return
      end
      @<%= message_thread_singular_lower_case %> = <%= message_thread_singular_camel_case %>.find(params[:reply][:thread_id])
      @<%= message_thread_singular_lower_case %>.reply_to_thread(params[:reply].merge(:sender => current_user))
    else
      unless @errors.blank?
        flash[:error] = "Error sending message! Please check all the fields and try again."
        render :action => :new
        return
      end
      @<%= message_thread_singular_lower_case %> = <%= message_thread_singular_camel_case %>.create_new_thread(params[:message].merge(:sender => current_user, :recipients => @recipients))
    end
    if !@<%= message_thread_singular_lower_case %>.blank?
      flash[:notice] = "Message sent."
      redirect_to <%= user_singular_lower_case %>_<%= message_plural_lower_case %>_path(current_user)
    else
      flash[:error] = "Error sending message! Please check all the fields and try again."
      render :action => :new
      return
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

private
  def get_message_recipients params
    recipients = []
    unless params[:message].blank? || (params[:message][:recipients_ids].blank? && params[:message][:to].blank?)
      ids =  params[:message][:recipients_ids].to_a.is_a?(Array) ?  params[:message][:recipients_ids].to_a : [ params[:message][:recipients_ids].to_a]
      ids = ids.map { |each| each.to_i }
      ids = ids + params[:message][:to].split(',')
      if ids.length == 1
        recipients = <%= user_singular_camel_case %>.find(ids)
      elsif ids.length > 1
        recipients = <%= user_singular_camel_case %>.where('id IN (?)', ids).all
      end
    end
    return recipients
  end

  def validate_message params
    @errors = {}
    body = params[:message].blank? ? params[:reply][:body] : params[:message][:body]
    if body.blank?
      @errors[:body] = "Message Body can not be blank."
    end
    unless params[:reply]
      if @recipients.blank?
        @errors[:to] = "Must add recipients to message."
      end
    end
    @errors
  end
end