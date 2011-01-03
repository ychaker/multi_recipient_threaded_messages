require 'test_helper'

class ReceivedMessageModelTest < Test::Unit::TestCase
  
  def setup
    @jerry = create_test_user(:login => "jerry")
    @george = create_test_user(:login => "george")
    @message = create_test_message :sender => @george, :recipient => @jerry
    @received_message = @message.received_messages.where(:recipient_id => @jerry.id).first
  end
  
  def teardown
    UserModel.delete_all
    MessageModel.delete_all
    ReceivedMessageModel.delete_all
    MessageThreadModel.delete_all
  end
  
  def test_create_message
    @message = create_test_message :sender => @george, :recipient => @jerry
    @received_message = @jerry.received_messages.find(:first, :conditions => ["sent_message_id = ?", @message])
    assert_equal @received_message.sent_message.sender, @george
    assert_equal @received_message.sent_message.thread.subject, "Frolf, Jerry!"
    assert_equal @received_message.sent_message.body, "Frolf, Jerry! Frisbee golf!"
    assert @received_message.last_read_at.nil?
    assert_equal @received_message.recipient, @jerry
  end
  
  def test_read
    @received_message = ReceivedMessageModel.read(@received_message, @jerry)
    assert_equal @message, @received_message
  end

  def test_read?
    ReceivedMessageModel.read(@received_message, @jerry)
    message = @jerry.received_messages.first
    assert_equal message, @received_message
    assert message.read?
  end
  
  def test_mark_deleted_recipient
    @received_message.mark_deleted(@jerry)
    @received_message.reload
    assert @received_message.recipient_deleted
  end
end