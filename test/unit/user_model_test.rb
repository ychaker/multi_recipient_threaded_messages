require 'test_helper'

class UserModelTest < Test::Unit::TestCase
  
  def setup
    @jerry = create_test_user(:login => "jerry")
    @message = create_test_message :recipient => @jerry
  end
  
  def teardown
    UserModel.delete_all
    MessageModel.delete_all
    ReceivedMessageModel.delete_all
    MessageThreadModel.delete_all
  end

  def test_unread_messages?
    assert @jerry.unread_messages?
  end

  def test_unread_message_count
    assert_equal @jerry.unread_message_count, 1
  end
end