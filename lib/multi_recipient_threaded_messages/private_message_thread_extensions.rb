module MultiRecipientThreadedMessages # :nodoc:
  module PrivateMessageThreadExtensions
    def self.included(base) # :nodoc:
      base.extend ActMethods
    end 

    module ActMethods
      # Sets up a model to be a private message thread model.
      # 
      # The following options are available to customize the model:
      # *  <tt>:user_class</tt> - The user class that is the recipient/sender class of the messages. Defaults to 'User'
      # *  <tt>:message_class</tt> - The message class that is the sent message. Defaults to 'Message'
      # *  <tt>:received_message_class</tt> - The received message class. Defaults to 'ReceivedMessage'
      # 
      # Provides the following instance methods:
      # *  <tt>messages</tt> - the messages belonging to this thread.
      # *  <tt>received_messages</tt> - all the received messages.
      # *  <tt>recipients</tt> - the recipients of the thread.
      def is_private_message_thread(options = {})
        options[:user_class] ||= 'User'
        options[:message_class] ||= 'Message'
        options[:received_message_class] ||= 'ReceivedMessage'
        
        unless included_modules.include? InstanceMethods
          class_inheritable_accessor :options
          
          has_many :messages,
                   :class_name => options[:message_class],
                   :foreign_key => 'thread_id',
                   :dependent => :destroy,
                   :order => "#{options[:message_class].constantize.table_name}.created_at ASC"
          
          has_many :received_messages, :through => :messages, :source => :received_messages, :uniq => true
          
          extend ClassMethods 
          include InstanceMethods 
          
          self.options = options
          
          scope :with_participant, lambda { |user|
            joins(:messages)\
            .joins("INNER JOIN #{options[:received_message_class].constantize.table_name} ON 
             #{options[:received_message_class].constantize.table_name}.sent_message_id =
             #{options[:message_class].constantize.table_name}.id")\
            .where(["#{options[:message_class].constantize.table_name}.sender_id = ? OR 
            #{options[:received_message_class].constantize.table_name}.recipient_id = ?", user.id, user.id])
          }
          
          scope :sent_by, lambda { |user|
            joins(:messages)\
            .where(["#{options[:message_class].constantize.table_name}.sender_id = ?", user.id])
          }
          
          scope :received_by, lambda { |user|
            joins(:messages)\
            .joins("INNER JOIN #{options[:received_message_class].constantize.table_name} ON 
             #{options[:received_message_class].constantize.table_name}.sent_message_id =
             #{options[:message_class].constantize.table_name}.id")\
            .where(["#{options[:received_message_class].constantize.table_name}.recipient_id = ?", user.id])
          }
          
          scope :unread_for_participant, lambda { |user|
            joins(:messages)\
            .joins("INNER JOIN #{options[:received_message_class].constantize.table_name} ON 
             #{options[:received_message_class].constantize.table_name}.sent_message_id =
             #{options[:message_class].constantize.table_name}.id")\
            .where(["#{options[:received_message_class].constantize.table_name}.recipient_id = ?
            AND #{options[:received_message_class].constantize.table_name}.read = ?", user.id, false])
          }
          
          scope :read_for_participant, lambda { |user|
            joins(:messages)\
            .joins("INNER JOIN #{options[:received_message_class].constantize.table_name} ON 
             #{options[:received_message_class].constantize.table_name}.sent_message_id =
             #{options[:message_class].constantize.table_name}.id")\
            .where(["#{options[:message_class].constantize.table_name}.sender_id = ? OR 
            (#{options[:received_message_class].constantize.table_name}.recipient_id = ?
            AND #{options[:received_message_class].constantize.table_name}.read = ?)", user.id, user.id, true])
          }
        end
      end 
    end 

    module ClassMethods # :nodoc:
      # Ensures the passed user is either the sender or the recipient then returns the message thread.
      # Mark thread as read.
      def read(id, reader)
        thread = where(["id = ?", id]).first
        unless thread.blank? || !thread.participants.include?(reader)
          thread.mark_as_read reader
        end
        thread
      end
      
      # create a new thread with the options passed in including the subject, body, sender and recipients
      def create_new_thread(params = {})
        thread = self.create(:subject => params[:subject])
        message = options[:message_class].constantize.create({
          :thread => thread,
          :sender => params[:sender],
          :body => params[:body]
        })
        recipients = (params[:recipients].is_a? Array) ? params[:recipients] : [params[:recipients]]
        recipients.each do |recipient|
          received_message = options[:received_message_class].constantize.create({
            :sent_message => message, 
            :recipient => recipient
          })
        end
        thread
      end
    end

    module InstanceMethods # :nodoc:
      # Original sender of the conversation.
      def original_sender
        @original_sender ||= self.original_message.sender
        @original_sender
      end

      # First message of the conversation.
      def original_message
        @original_message ||= self.messages.first
        @original_message
      end

      # Sender of the last message.
      def last_sender
        @last_sender = self.last_message.sender
        @last_sender
      end

      # Last message in the conversation.
      def last_message
        @last_message = self.messages.last
        @last_message
      end
      
      # Get all the recipients in the converstaion.
      def recipients
        options[:user_class].constantize.recipients_in_message_thread(self).uniq
      end
      
      # All users involved in the conversation.
      def participants
        if @participants.nil?
          @participants = self.recipients.clone
          @participants << self.original_sender unless @participants.include?(self.original_sender) 
        end
        @participants
      end
      
      # Marks a message as deleted by either the sender or the recipient, which ever the user that was passed is.
      # Once both have marked it deleted, it is destroyed.
      def mark_deleted(user)
        self.messages.each { |each| each.mark_deleted(user) }
        self.attempt_to_delete
      end
      
      # Attempt to permanently delete the thread if everyone has marked it to be deleted
      def attempt_to_delete
        self.ready_to_delete? ? self.destroy : save!
      end
      
      # Check if the thread is ready to be deleted
      def ready_to_delete?
        self.messages.each { |each| return false if !each.ready_to_delete? }
        true
      end
      
      # Mark all received messages as read
      def mark_as_read reader
        self.received_messages.where(["recipient_id = ? ", reader]).each { |each| each.mark_as_read }
      end
      
      # Mark all received message as unread
      def mark_as_unread reader
        self.received_messages.where(["recipient_id = ? ", reader]).each { |each| each.mark_as_unread }
      end
      
      # Returns true or false value based on whether all the messages have been read by the recipient.
      def read? reader
        self.received_messages.find(:all, :conditions => ["recipient_id = ? ", reader]).each { |each| return false unless each.read? }
        return true
      end
      
      # Reply to current thread with the options passed in including the body and sender
      def reply_to_thread(params = {})
        message = options[:message_class].constantize.create({
          :thread => self,
          :sender => params[:sender],
          :body => params[:body]
        })
        recipients = self.participants - [params[:sender]]
        recipients.each do |recipient|
          received_message = options[:received_message_class].constantize.create({
            :sent_message => message, 
            :recipient => recipient
          })
        end
        return self
      end
    end 
  end
end

if defined? ActiveRecord
  ActiveRecord::Base.class_eval do
    include MultiRecipientThreadedMessages::PrivateMessageThreadExtensions
  end
end