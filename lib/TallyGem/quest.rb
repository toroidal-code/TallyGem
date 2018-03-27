require 'uri'
require 'English'


module TallyGem
  class Quest
    PAGE_NUMBER_REGEX = Regexp.new '^(?<base>.+?)(&?page[-=]?\d+)?(&p=?\d+)?(#[^/]*)?(unread)?$'
    DISPLAY_NAME_REGEX = Regexp.new '(?<display_name>[^/]+)(/|#[^/]*)?$'
    NEW_THREAD_ENTRY = 'https://forums.sufficientvelocity.com/threads/fake-thread.00000'

    attr_reader :thread_name, :thread_uri
    attr_accessor :forum_type, :forum_adapter
    attr_reader :start_post, :end_post
    attr_accessor :check_for_last_threadmark, :use_rss_threadmarks
    attr_writer :posts_per_page
    attr_accessor :partition_mode, :whitespace_and_punctuation_is_significant,
                  :forbid_vote_label_plan_names, :disable_proxy_votes,
                  :force_pinned_proxy_votes, :ignore_spoilers, :trim_extended_text

    def initialize
      @display_name = ''
      self.thread_name = NEW_THREAD_ENTRY
      @posts_per_page = 0
      @start_post = 1
      @end_post = 0
      @check_for_last_threadmark = true

      @partition_mode = :none
      @whitespace_and_punctuation_is_significant = false
      @forbid_vote_label_plan_names = false
      @disable_proxy_votes = false
      @force_pinned_proxy_votes = false
      @ignore_spoilers = false
      @trim_extended_text = false
    end

    def thread_name=(url)
      raise(ArgumentError, 'URL cannot be nil or empty.') if url.nil? || url.strip.empty?
      uri = URI.parse(URI.unescape(cleanup_thread_name(url)))
      raise(ArgumentError, 'URL is not absolute location.') unless uri.absolute?
      raise(ArgumentError, 'URL is not a valid http/https location.') unless uri.scheme =~ /^http[s]?$/

      clean_value = URI.unescape(cleanup_thread_name(url))
      new_uri = URI.parse(clean_value)

      if @thread_uri.nil? || @thread_uri.host != new_uri.host
        @forum_type = :unknown
        @forum_adapter = nil
      end

      old_thread_name = @thread_name

      @thread_name = clean_value
      @thread_uri = new_uri

      if @display_name.nil? || @display_name.strip.empty?
        display_name
      elsif @display_name == get_display_name_from_url(old_thread_name)
        self.display_name = ''
      elsif @display_name == get_display_name_from_url(thread_name)
        @display_name = ''
      end
    end

    def display_name
      if @display_name.nil? || @display_name.empty?
        get_display_name_from_url(@thread_name)
      else
        @display_name
      end
    end

    def display_name=(name)
      if name.nil? || name.empty?
        @display_name = name
      else
        @display_name = name.gsub(/[\p{C}&&[^\r\n]]/, '')
      end
    end

    def start_post=(num)
      raise(ArgumentError, 'Starting post number must be at least 1.') if num < 1
      @start_post = num
    end

    def end_post=(num)
      raise(ArgumentError, 'Ending post number must be at least 0.') if num < 0
      @end_post = num
    end

    def read_to_end_of_thread; @end_post == 0; end

    def posts_per_page
      if @posts_per_page == 0 && !@forum_adapter.nil?
        @posts_per_page = @forum_adapter.default_posts_per_page
      end
      @posts_per_page
    end

    def get_page_number_of(postnum)
      ((postnum - 1) / posts_per_page) + 1
    end

    def to_s
      self.display_name
    end

    private
    def cleanup_thread_name(url)
      url.gsub!(/[\p{C}&&[^\r\n]]/, '')
      $LAST_MATCH_INFO[:base] if url =~ PAGE_NUMBER_REGEX
    end

    def get_display_name_from_url(url)
      return '' if url.nil? || url.strip.empty?
      if url =~ DISPLAY_NAME_REGEX
        $LAST_MATCH_INFO[:display_name]
      else
        url
      end
    end
  end
end
