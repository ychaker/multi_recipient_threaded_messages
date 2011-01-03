module MultiRecipientThreadedMessages #:nodoc:
  module HasPrivateMessagesExtensions #:nodoc:
    def self.included(base) #:nodoc:
      base.extend ActMethods
    end 

    module ActMethods
      # Sets up a model to have private messages.
      # 
      # The following options are available to customize the model:
      # *  <tt>:message_class</tt> - The message class that is the sent message. Defaults to 'Message'
      # *  <tt>:received_message_class</tt> - The received message class. Defaults to 'ReceivedMessage'
      # *  <tt>:message_thread_class</tt> - The message thread class. Defaults to 'MessageThread'
      # 
      # Provides the following instance methods:
      # *  <tt>sender</tt> - the messages belonging to this thread.
      # *  <tt>received_messages</tt> - all the received messages.
      # *  <tt>recipients</tt> - the recipients of the thread.
      def has_private_messages(options = {})
        options[:message_class] ||= 'Message'
        options[:received_message_class] ||= 'ReceivedMessage'
        options[:message_thread_class] ||= 'MeesageThread'
        
        unless included_modules.include? InstanceMethods
          class_inheritable_accessor :options
          
          table_name = options[:message_class].constantize.table_name
          received_table_name = options[:received_message_class].constantize.table_name
          
          has_many :sent_messages,
                   :class_name => options[:message_class],
                   :foreign_key => 'sender_id',
                   :order => "#{table_name}.created_at DESC",
                   :conditions => ["#{table_name}.sender_deleted = ?", false]

          has_many :received_messages,
                   :class_name => options[:received_message_class],
                   :foreign_key => 'recipient_id',
                   :order => "#{received_table_name}.created_at DESC",
                   :conditions => ["#{received_table_name}.recipient_deleted = ?", false],
                   :dependent => :destroy

          extend ClassMethods 
          include InstanceMethods 
        end 
        self.options = options
        
        scope :recipients_in_thread, lambda { |thread|
          joins(:received_messages)\
          .joins("INNER JOIN `#{options[:message_class].constantize.table_name}` ON 
           `#{options[:received_message_class].constantize.table_name}`.`sent_message_id` =
           `#{options[:message_class].constantize.table_name}`.`id`")\
          .where(["#{options[:message_class].constantize.table_name}.thread_id = ?", thread.id])\
          .uniq
        }
        scope :senders_in_thread, lambda { |thread|
          joins(:sent_messages)\
          .where(["#{options[:message_class].constantize.table_name}.thread_id = ?", thread.id])\
          .uniq
        }
        scope :in_thread, lambda { |thread|
          users = []
          users << self.recipients_in_thread(thread)
          users << self.senders_in_thread(thread)
          users.flatten.uniq
        }
      end 
    end 

    module ClassMethods #:nodoc:
      # None yet...
    end

    module InstanceMethods
      # Returns true or false based on if this user has any unread messages
      def unread_messages?
        unread_message_count > 0 ? true : false
      end
      
      # Returns the number of unread messages for this user
      def unread_message_count
        received_messages.unread.count
      end
    end 
  end
end

if defined? ActiveRecord
  ActiveRecord::Base.class_eval do
    include MultiRecipientThreadedMessages::HasPrivateMessagesExtensions
  end
end