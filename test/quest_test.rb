require 'minitest/autorun'
require 'NetTally/quest'

class TestQuest < Minitest::Test
  Quest = NetTally::Quest
  def setup
    @quest = Quest.new
  end

  def test_construction
    assert_equal Quest::NEW_THREAD_ENTRY, @quest.thread_name
    assert_equal 'fake-thread.00000', @quest.display_name
    assert_equal Quest::NEW_THREAD_ENTRY, @quest.thread_uri.to_s
    assert_nil @quest.forum_adapter

    assert_equal 0, @quest.posts_per_page
    assert_equal 1, @quest.start_post
    assert_equal 0, @quest.end_post
    assert_equal true, @quest.read_to_end_of_thread
    assert_equal true, @quest.check_for_last_threadmark

    assert_equal :none, @quest.partition_mode

    assert_equal@quest.display_name, @quest.to_s
  end

  def test_thread_name_invalid
    assert_raises(ArgumentError) { @quest.thread_name = nil }
  end

  def test_thread_name_invalid_no_change
    assert_raises(ArgumentError) { @quest.thread_name = nil }
    assert_equal Quest::NEW_THREAD_ENTRY, @quest.thread_name
  end

  def test_thread_name_invalid_blank
    assert_raises(ArgumentError) { @quest.thread_name = '' }
  end

  def test_thread_name_invalid_empty
    assert_raises(ArgumentError) { @quest.thread_name = '  ' }
  end

  def test_thread_name_invalid_host
    assert_raises ArgumentError do
      @quest.thread_name = '/forums.sufficientvelocity.com/'
      assert_equal '/forums.sufficientvelocity.com/', @quest.thread_name
    end
  end

  def test_thread_name_valid_host
    @quest.thread_name = 'https://forums.sufficientvelocity.com/'
    assert_equal 'https://forums.sufficientvelocity.com/', @quest.thread_name
  end

  def test_thread_name_with_thread
    url = 'http://forums.sufficientvelocity.com/threads/renascence-a-homura-quest.10402/'
    @quest.thread_name = url
    assert_equal url, @quest.thread_name
  end

  def test_thread_name_with_page
    baseurl = 'http://forums.sufficientvelocity.com/threads/renascence-a-homura-quest.10402/'
    @quest.thread_name = baseurl + 'page-221'
    assert_equal baseurl, @quest.thread_name
  end

  def test_thread_name_with_post
    baseurl = 'http://forums.sufficientvelocity.com/threads/renascence-a-homura-quest.10402/'
    @quest.thread_name = baseurl + 'page221#post-19942121'
    assert_equal baseurl, @quest.thread_name

    baseurl = 'http://www.fandompost.com/oldforums/showthread.php?39239-Yurikuma-Arashi-Discussion-Thread'
    @quest.thread_name = baseurl + '&p=288335#post288335'
    assert_equal baseurl, @quest.thread_name
  end

  def test_thread_name_remove_invalid_unicode
    @quest.thread_name = "http://forums.sufficientvelocity.com/threads/renascence-a-\u200bhomura-quest.10402/page-221#post-19942121"
    assert_equal 'http://forums.sufficientvelocity.com/threads/renascence-a-homura-quest.10402/', @quest.thread_name
  end
end