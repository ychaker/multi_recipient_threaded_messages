require 'rails/generators'
require 'rails/generators/migration'

module MultiRecipientsThreadedMessages
  module Generators
    class RoutesGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      source_root File.join(File.dirname(__FILE__), 'templates')
      
      desc "Generate the basic routes."

      argument :user_model_name, :required => false, :default => "User", :desc => "The user model name"
      argument :message_model_name, :required => false, :default => "Message", :desc => "The message model name"
      argument :received_message_model_name, :required => false, :default => "ReceivedMessage", :desc => "The received message model name"
      argument :message_thread_model_name, :required => false, :default => "MessageThread", :desc => "The message thread model name"

      attr_reader :user_singular_camel_case, :user_plural_camel_case, :user_singular_lower_case, :user_plural_lower_case
      attr_reader :message_singular_camel_case, :message_plural_camel_case, :message_singular_lower_case, :message_plural_lower_case
      attr_reader :received_message_singular_camel_case, :received_message_plural_camel_case, :received_message_singular_lower_case, :received_message_plural_lower_case
      attr_reader :message_thread_singular_camel_case, :message_thread_plural_camel_case, :message_thread_singular_lower_case, :message_thread_plural_lower_case

      def set_attributes
        @message_plural_camel_case    = message_model_name.pluralize.camelize
        @message_plural_lower_case    = message_model_name.pluralize.underscore
        @message_singular_lower_case  = message_model_name.singularize.underscore
        @message_singular_camel_case  = message_model_name.singularize.camelize

        @received_message_plural_camel_case   = received_message_model_name.pluralize.camelize
        @received_message_plural_lower_case   = received_message_model_name.pluralize.underscore
        @received_message_singular_lower_case = received_message_model_name.singularize.underscore
        @received_message_singular_camel_case = received_message_model_name.singularize.camelize
        
        @message_thread_plural_camel_case    = message_thread_model_name.pluralize.camelize
        @message_thread_plural_lower_case    = message_thread_model_name.pluralize.underscore
        @message_thread_singular_lower_case  = message_thread_model_name.singularize.underscore
        @message_thread_singular_camel_case  = message_thread_model_name.singularize.camelize

        @user_plural_camel_case   = user_model_name.pluralize.camelize
        @user_plural_lower_case   = user_model_name.pluralize.underscore
        @user_singular_lower_case = user_model_name.singularize.underscore
        @user_singular_camel_case = user_model_name.singularize.camelize
      end

      def generate_routes
        route("
        resources :#{@user_plural_lower_case} do
          resources :#{@message_plural_lower_case} do
            collection do
              post :delete_selected
            end
          end
        end
        ")
      end
    end
  end
end