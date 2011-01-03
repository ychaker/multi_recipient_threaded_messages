require 'test_helper'

class MessageModelTest < Test::Unit::TestCase

  def setup
    @jerry = create_test_user(:login => "jerry")
    @george = create_test_user(:login => "george")
    @message = create_test_message :sender => @george, :recipient => @jerry
  end
  
  def teardown
    UserModel.delete_all
    MessageModel.delete_all
    ReceivedMessageModel.delete_all
    MessageThreadModel.delete_all
  end

  def test_create_message
    assert_equal @message.sender, @george
    assert_equal @message.thread.subject, "Frolf, Jerry!"
    assert_equal @message.body, "Frolf, Jerry! Frisbee golf!"
  end

  def test_read_returns_message
    assert_equal @message, MessageModel.read(@message, @george)
  end

  def test_read_records_timestamp
    assert !@message.nil?
  end
  
  def test_mark_deleted_sender
    @message.mark_deleted(@george)
    @message.reload
    assert @message.sender_deleted
  end

  def test_mark_deleted_both
    id = @message.id
    @message.mark_deleted(@george)
    @message.mark_deleted(@jerry)
    assert !MessageModel.exists?(id)
  end


  def test_read
    message = MessageModel.read(@message, @jerry)
    assert_equal message, @message
  end

  def test_read?
    @received_message = MessageModel.read(@message, @jerry)
    assert @message.read?(@jerry)
  end
  
  def test_mark_deleted_recipient
    @received_message = @message.received_messages.where(:recipient_id => @jerry.id).first
    @message.mark_deleted(@jerry)
    @received_message.reload
    assert @received_message.recipient_deleted
  end
  
  def test_same_recipient_and_sender_create
    @message = create_test_message :sender => @george, :recipient => @george
    assert_equal @message.sender, @george
    assert_equal @message.thread.subject, "Frolf, Jerry!"
    assert_equal @message.body, "Frolf, Jerry! Frisbee golf!"
    assert_equal @george.received_messages.first, @message.received_messages.first
  end
  
  def test_same_recipient_and_sender_read
    @message = create_test_message :sender => @george, :recipient => @george
    assert_equal @message, MessageModel.read(@message, @george)
    assert_equal @message, ReceivedMessageModel.read(@message, @george)
  end
  
  def test_same_recipient_and_sender_mark_delete
    @message = create_test_message :sender => @george, :recipient => @george
    id = @message.id
    @message.mark_deleted(@george)
    assert !MessageModel.exists?(id)
  end
end