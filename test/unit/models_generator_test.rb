require 'test_helper'
require 'rails/generators'
require 'rails/generators/migration'
require 'generators/multi_recipient_threaded_messages/models/models_generator'

class ModelsGeneratorTest < Rails::Generators::TestCase
  tests MultiRecipientsThreadedMessages::Generators::ModelsGenerator
  destination File.expand_path("../tmp", File.dirname(__FILE__))
  setup :prepare_destination
 
  def test_generates_correct_file_name
    run_generator
    assert_file "app/models/message.rb"
    assert_file "app/models/received_message.rb"
    assert_migration "db/migrate/create_messages.rb"
    assert_migration "db/migrate/create_received_messages.rb"
  end
end