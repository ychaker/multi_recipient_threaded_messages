module MultiRecipientThreadedMessages # :nodoc:
  module ReceivedPrivateMessageExtensions
    def self.included(base) # :nodoc:
      base.extend ActMethods
    end 

    module ActMethods
      # Sets up a model to be a private message thread model.
      # 
      # The following options are available to customize the model:
      # *  <tt>:user_class</tt> - The user class that is the recipient/sender class of the messages. Defaults to 'User'
      # *  <tt>:message_class</tt> - The message class that is the sent message. Defaults to 'Message'
      # *  <tt>:message_thread_class</tt> - The message thread class. Defaults to 'MessageThread'
      # 
      # Provides the following instance methods:
      # *  <tt>messages</tt> - the messages belonging to this thread.
      # *  <tt>received_messages</tt> - all the received messages.
      # *  <tt>recipients</tt> - the recipients of the thread.
      def is_received_private_message(options = {})
        options[:user_class] ||= 'User'
        options[:message_class] ||= 'Message'
        options[:message_thread_class] ||= 'MessageThread'
        
        unless included_modules.include? InstanceMethods
          belongs_to :sent_message,
                     :class_name => options[:message_class],
                     :foreign_key => 'sent_message_id',
                     :touch => true
                     
          belongs_to :recipient,
                     :class_name => options[:user_class],
                     :foreign_key => 'recipient_id'
                     
          extend ClassMethods 
          include InstanceMethods 
        end 

        scope :already_read, :conditions => ["#{self.table_name}.read = ?", true]
        scope :unread, :conditions => ["#{self.table_name}.read = ?", false]
        # scope :by_thread, lambda { |thread|
        #   { 
        #     :joins => {:sent_message => :sent_message}, 
        #     :group => ["sent_message.thread_id = ?", thread]
        #   }
        # }
      end 
    end 

    module ClassMethods
      # Ensures the passed user is the recipient then returns the message.
      # If the reader is the recipient and the message has yet not been read, it marks the last_read_at timestamp.
      # ALways return the sent message to be consistent and because that's where the information is.
      def read(id, reader)
        message = where(["(id = ? OR sent_message_id = ?) AND recipient_id = ?", id, id, reader]).first
        if message.recipient == reader
          message.last_read_at = Time.now
          message.mark_as_read
          message.save!
        end
        message.sent_message
      end
    end

    module InstanceMethods
      # Returns true or false value based on whether the a message has been read by it's recipient.
      def read?
        self.read
      end
      
      def mark_as_read
        self.last_read_at = Time.now
        self.read = true
        self.save!
      end
      
      def mark_as_unread
        self.read = false
        self.save!
      end

      # Marks a message as deleted by either the sender or the recipient, which ever the user that was passed is.
      # Once both have marked it deleted, it is destroyed.
      def mark_deleted(user)
        # self.sent_message.mark_deleted(user) if self.sender == user
        self.recipient_deleted = true if self.recipient == user
        self.save
        self.sent_message.thread.attempt_to_delete
      end
    end 
  end
end

if defined? ActiveRecord
  ActiveRecord::Base.class_eval do
    include MultiRecipientThreadedMessages::ReceivedPrivateMessageExtensions
  end
end