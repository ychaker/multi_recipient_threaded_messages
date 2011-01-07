require 'test_helper'

class MessageThreadModelTest < Test::Unit::TestCase

  def setup
    @jerry = create_test_user(:login => "jerry")
    @george = create_test_user(:login => "george")
    @message_thread = create_test_message_thread
    @message = create_test_message :thread => @message_thread, :sender => @george, :recipient => @jerry
  end
  
  def teardown
    UserModel.delete_all
    MessageModel.delete_all
    ReceivedMessageModel.delete_all
    MessageThreadModel.delete_all
  end

  def test_create_message_thread
    @message_thread = MessageThreadModel.create_new_thread({
      :sender => @george,
      :recipients => @jerry,
      :subject => "Frolf, Jerry!",
      :body => "Frolf, Jerry! Frisbee golf!"
    })
    assert_equal @message_thread.subject, "Frolf, Jerry!"
    assert @message_thread.original_message
    assert_equal @message_thread.original_sender, @george
    assert_equal @message_thread.messages.first.body, "Frolf, Jerry! Frisbee golf!"
    assert_equal @message_thread.recipients.count, 1
    assert_equal @message_thread.recipients.first, @jerry
    assert_equal @message_thread.participants.count, 2
  end

  def test_read_returns_message_thread
    assert_equal @message_thread, MessageThreadModel.read(@message_thread, @george)
    assert_equal @message_thread, MessageThreadModel.read(@message_thread, @jerry)
  end
  
  def test_read_records_timestamp
    @message_thread = MessageThreadModel.read(@message_thread, @jerry)
    assert !@message_thread.received_messages.first.last_read_at.nil?
    assert @message_thread.received_messages.first.read?
  end
  
  def test_mark_as_read_and_mark_as_unread
    @message_thread.mark_as_read(@jerry)
    assert @message_thread.received_messages.first.read?
    assert @message_thread.read?(@jerry)
    @message_thread.mark_as_unread(@jerry)
    assert !@message_thread.received_messages.first.read?
    assert !@message_thread.read?(@jerry)
  end
  
  def test_mark_deleted_sender
    @message_thread.mark_deleted(@george)
    @message_thread.reload
    assert @message_thread.messages.first.sender_deleted
  end
  
  def test_mark_deleted_both
    id = @message_thread.id
    @message_thread.mark_deleted(@george)
    @message_thread.mark_deleted(@jerry)
    assert !MessageThreadModel.exists?(id)
  end

  def test_mark_deleted_recipient
    @message_thread.mark_deleted(@jerry)
    @message_thread.reload
    assert @message_thread.received_messages.first.recipient_deleted
  end
  
  def test_reply_to_thread
    @reply = @message_thread.reply_to_thread(:sender => @jerry, :body => "This is my reply")
    assert_equal @reply, @message_thread
    assert_equal @reply.messages.count, 2
    assert_equal @reply.last_message.body, "This is my reply"
    assert_equal @reply.last_sender, @jerry
    assert_equal @reply.participants.count, 2
  end
  
  def test_with_participant_scope
    threads = MessageThreadModel.with_participant @george
    assert_equal threads.count, 1
    assert_equal threads.first, @message_thread
  end
  
  def test_unread_for_participant_scope
    threads = MessageThreadModel.unread_for_participant @jerry
    assert_equal threads.count, 1
    assert_equal threads.first, @message_thread
  end
  
  def test_read_for_participant_scope
    threads = MessageThreadModel.read_for_participant @george
    assert_equal threads.count, 1
    assert_equal threads.first, @message_thread
    threads = MessageThreadModel.read_for_participant @jerry
    assert_equal threads.count, 0
    MessageThreadModel.read(@message_thread, @jerry)
    threads = MessageThreadModel.read_for_participant @jerry
    assert_equal threads.count, 1
    assert_equal threads.first, @message_thread
  end
  
  def test_sent_by_scope
    threads = MessageThreadModel.sent_by @george
    assert_equal threads.count, 1
    assert_equal threads.first, @message_thread
    threads = MessageThreadModel.sent_by @jerry
    assert_equal threads.count, 0
  end
  
  def test_received_by_scope
    threads = MessageThreadModel.received_by @jerry
    assert_equal threads.count, 1
    assert_equal threads.first, @message_thread
    threads = MessageThreadModel.received_by @george
    assert_equal threads.count, 0
  end
end