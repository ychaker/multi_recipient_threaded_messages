require 'test_helper'
require 'rails/generators'
require 'rails/generators/migration'
require 'generators/multi_recipient_threaded_messages/scaffold/scaffold_generator'

class ScaffoldGeneratorTest < Rails::Generators::TestCase
  tests MultiRecipientsThreadedMessages::Generators::ScaffoldGenerator
  destination File.expand_path("../tmp", File.dirname(__FILE__))
  setup :prepare_destination
 
  def test_generates_correct_file_name
    run_generator
    assert_file "app/controllers/messages_controller.rb"
    assert_file "app/views/messages/index.html.erb"
    assert_file "app/views/messages/_inbox.html.erb"
    assert_file "app/views/messages/_sent.html.erb"
    assert_file "app/views/messages/show.html.erb"
    assert_file "app/views/messages/new.html.erb"
  end
end