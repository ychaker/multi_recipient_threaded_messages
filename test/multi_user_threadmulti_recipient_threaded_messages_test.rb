require 'test_helper'

class MultiRecipientThreadedMessagesTest < ActiveSupport::TestCase
  load_schema
  
  def test_schema_has_loaded_correctly
    assert_equal [], MessageModel.all
    assert_equal [], UserModel.all
  end
end
