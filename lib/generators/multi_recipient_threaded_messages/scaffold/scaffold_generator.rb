require 'rails/generators'
require 'rails/generators/migration'

module MultiRecipientsThreadedMessages
  module Generators
    class ScaffoldGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      source_root File.join(File.dirname(__FILE__), 'templates')
      
      desc "Creates a basic controller and a set of views."

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

      def generate_controllers
        #directory "app/controllers"
        template "controller.rb", "app/controllers/#{@message_plural_lower_case}_controller.rb"
      end
      
      def generate_helpers
        #directory "app/helpers"
        template "helper.rb", "app/helpers/#{@message_plural_lower_case}_helper.rb"
      end
      
      def generate_views
        #directory "app/views"
        #directory "app/views/#{@message_plural_lower_case}"
        template "view_index.html.erb", "app/views/#{@message_plural_lower_case}/index.html.erb"
        template "view_index_inbox.html.erb", "app/views/#{@message_plural_lower_case}/_inbox.html.erb"
        template "view_index_sent.html.erb", "app/views/#{@message_plural_lower_case}/_sent.html.erb"
        template "view_show.html.erb", "app/views/#{@message_plural_lower_case}/show.html.erb"
        template "view_new.html.erb", "app/views/#{@message_plural_lower_case}/new.html.erb"
      end
    end
  end
end