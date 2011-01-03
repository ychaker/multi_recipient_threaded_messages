ENV['RAILS_ENV'] = 'test'
ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '/../../../..'
 
require 'test/unit'
require File.expand_path(File.join(ENV['RAILS_ROOT'], 'config/environment.rb'))

ActiveSupport::Dependencies.autoload_paths << File.dirname(__FILE__) + '/fixtures/'

def load_schema
  config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
  ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
 
  db_adapter = ENV['DB']
 
  # no db passed, try one of these fine config-free DBs before bombing.
  db_adapter ||=
    begin
      require 'rubygems'
      require 'sqlite'
      'sqlite'
    rescue MissingSourceFile
      begin
        require 'sqlite3'
        'sqlite3'
      rescue MissingSourceFile
      end
    end
 
  if db_adapter.nil?
    raise "No DB Adapter selected. Pass the DB= option to pick one, or install Sqlite or Sqlite3."
  end
 
  ActiveRecord::Base.establish_connection(config[db_adapter])
  load(File.dirname(__FILE__) + "/schema.rb")
  require File.dirname(__FILE__) + '/../init'
end

def create_test_message_thread(options = {})
  return MessageThreadModel.create(:subject => "Frolf, Jerry!")
end

def create_test_user(options = {})
  return UserModel.create({:login => "dolores"}.merge(options))
end

def create_test_message(options = {})
  message = MessageModel.create({
    :thread => options[:thread] || create_test_message_thread(:subject => "Frolf, Jerry!"),
    :sender => options[:sender] || create_test_user(:login => "george"),
    :body => "Frolf, Jerry! Frisbee golf!"
  })
  received_message = ReceivedMessageModel.create({
    :sent_message => message, 
    :recipient => options[:recipient] || create_test_user(:login => "jerry")
  })
  return message
end