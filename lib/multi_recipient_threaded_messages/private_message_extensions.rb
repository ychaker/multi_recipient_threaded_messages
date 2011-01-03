module MultiRecipientThreadedMessages # :nodoc:
  module PrivateMessageExtensions
    def self.included(base) # :nodoc:
      base.extend ActMethods
    end 

    module ActMethods
      # Sets up a model to be a private message model.
      # 
      # The following options are available to customize the model:
      # *  <tt>:user_class</tt> - The user class that is the recipient/sender class of the messages. Defaults to 'User'
      # *  <tt>:received_message_class</tt> - The received message class. Defaults to 'ReceivedMessage'
      # *  <tt>:message_thread_class</tt> - The message thread class. Defaults to 'MessageThread'
      # 
      # Provides the following instance methods:
      # *  <tt>sender</tt> - the messages belonging to this thread.
      # *  <tt>received_messages</tt> - all the received messages.
      # *  <tt>recipients</tt> - the recipients of the thread.
      def is_private_message(options = {})
        options[:user_class] ||= 'User'
        options[:received_message_class] ||= 'ReceivedMessage'
        options[:message_thread_class] ||= 'MessageThread'
        
        unless included_modules.include? InstanceMethods
          class_inheritable_accessor :options
          
          belongs_to :thread,
                     :class_name => options[:message_thread_class],
                     :foreign_key => 'thread_id'
                     
          belongs_to :sender,
                     :class_name => options[:user_class],
                     :foreign_key => 'sender_id'
                     
          has_many :received_messages,
                   :class_name => options[:received_message_class],
                   :foreign_key => 'sent_message_id',
                   :dependent => :destroy
                   
          has_many :recipients, :through => :received_messages
          
          extend ClassMethods 
          include InstanceMethods 
          
          self.options = options
        end
      end 
    end 

    module ClassMethods # :nodoc:
      # Ensures the passed user is either the sender or the recipient then returns the message.
      # If the reader is the recipient and the message has yet not been read, it marks the last_read_at timestamp.
      def read(id, reader)
        message = where(["id = ? AND sender_id = ?", id, reader]).first || options[:received_message_class].constantize.send(:read, id, reader)
      end
    end

    module InstanceMethods # :nodoc:
      # Marks a message as deleted by either the sender or the recipient, which ever the user that was passed is.
      # Once both have marked it deleted, it is destroyed.
      def mark_deleted(user)
        self.sender_deleted = true if self.sender == user
        self.received_messages.find(:first, ["recipient_id = ? ", user]).mark_deleted(user) if self.recipients.include?(user)
        self.save
        self.thread.attempt_to_delete
      end
      
      def ready_to_delete?
        self.sender_deleted && self.all_received_messages_marked_deleted?
      end
      
      def all_received_messages_marked_deleted?
        self.received_messages.blank? || self.received_messages.find(:all, :conditions => ["recipient_deleted = ?", false]).empty?
      end
      
      # Returns true or false value based on whether the a message has been read by the recipient.
      def read? reader
        self.received_messages.find(:first, ["recipient_id = ? ", reader]).read?
      end
    end 
  end
end

if defined? ActiveRecord
  ActiveRecord::Base.class_eval do
    include MultiRecipientThreadedMessages::PrivateMessageExtensions
  end
end