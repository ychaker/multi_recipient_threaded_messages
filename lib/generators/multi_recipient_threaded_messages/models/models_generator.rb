require 'rails/generators'
require 'rails/generators/migration'

module MultiRecipientsThreadedMessages
  module Generators
    class ModelsGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      source_root File.join(File.dirname(__FILE__), 'templates')
      
      desc "Creates the private message models."

      argument :user_model_name, :required => false, :default => "User", :desc => "The user model name"
      argument :message_model_name, :required => false, :default => "Message", :desc => "The message model name"
      argument :received_message_model_name, :required => false, :default => "ReceivedMessage", :desc => "The received message model name"

      attr_reader :user_singular_camel_case, :user_plural_camel_case, :user_singular_lower_case, :user_plural_lower_case
      attr_reader :message_singular_camel_case, :message_plural_camel_case, :message_singular_lower_case, :message_plural_lower_case
      attr_reader :received_message_singular_camel_case, :received_message_plural_camel_case, :received_message_singular_lower_case, :received_message_plural_lower_case

      # Implement the required interface for Rails::Generators::Migration.
      # taken from http://github.com/rails/rails/blob/master/activerecord/lib/generators/active_record.rb
      def self.next_migration_number(dirname) #:nodoc:
        if ActiveRecord::Base.timestamped_migrations
          Time.now.utc.strftime("%Y%m%d%H%M%S")
        else
          "%.3d" % (current_migration_number(dirname) + 1)
        end
      end
      
      def create_migration_files
        @message_plural_camel_case = message_model_name.pluralize.camelize
        @message_plural_lower_case = message_model_name.pluralize.underscore
        @received_message_plural_camel_case = received_message_model_name.pluralize.camelize
        @received_message_plural_lower_case = received_message_model_name.pluralize.underscore
        migration_template 'message_migration.rb', "db/migrate/create_#{message_plural_lower_case}", :assigns => {
          :migration_name => "Create#{message_plural_camel_case}"
        }
        migration_template 'received_message_migration.rb', "db/migrate/create_#{received_message_plural_lower_case}", :assigns => {
          :migration_name => "Create#{received_message_plural_camel_case}"
        }
      end
      
      def create_model_file
        @message_singular_lower_case = message_model_name.singularize.underscore
        @received_message_singular_lower_case = received_message_model_name.singularize.underscore
        @user_singular_camel_case = user_model_name.singularize.camelize
        @message_singular_camel_case = message_model_name.singularize.camelize
        @received_message_singular_camel_case = received_message_model_name.singularize.camelize
        #directory "app/models"
        template "message.rb", "app/models/#{message_singular_lower_case}.rb"
        template "received_message.rb", "app/models/#{received_message_singular_lower_case}.rb"
      end
    end
  end
end