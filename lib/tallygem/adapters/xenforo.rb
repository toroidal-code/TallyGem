require 'open-uri'
require 'nokogiri'

require_relative '../posts/post'

module TallyGem::Adapters
  class Xenforo
    POSTS_PER_PAGE = 25

    def initialize(url, start_num: 1, end_num: nil, last_threadmark: false)
      @url             = url
      @start_num       = start_num
      @end_num         = end_num
      @last_threadmark = last_threadmark
      @thread_url      = base_thread_url(@url)
    end

    def posts
      start_page_num = start_page_num()
      first_page     = Nokogiri::XML(open("#{@thread_url}/page-#{start_page_num}"))

      # 'Page x of y' => Int(y)
      end_page_num =
        if @end_num.nil?
          first_page.css('.pageNavHeader').text.split.last.to_i
        else
          page_num(@end_num)
        end

      page_urls = (start_page_num..end_page_num).collect {|page_num| "#{@thread_url}/page-#{page_num}"}

      page_posts = page_urls.collect do |url|
        page = Nokogiri::XML(open(url))
        page.css('.messageList .message').collect do |message|
          # replace imgs with alt-text
          message.css('img').each {|img| img.replace((img['alt']).to_s)}
          # remove quotes
          message.css('.bbCodeQuote').remove
          # remove spoilers
          message.css('.bbCodeSpoilerContainer').remove

          number = message.css('.postNumber').text.delete('#').to_i
          next if number < @start_num || number > (@end_num || end_page_num * POSTS_PER_PAGE)

          id_str = message['id']
          id     = id_str =~ /post-([0-9]+)/ ? $~.captures.first.to_i : id_str
          author = message['data-author']
          text   = message.css('.messageContent article .messageText').text.strip
          TallyGem::Post.new(id, number, author, text)
        end
      end

      # flatten array of page-arrays of posts down to just an array of valid posts
      posts = page_posts.flatten.reject(&:nil?)

      # set the end_num if it's nil
      @end_num ||= posts.last.number

      posts
    end

    def to_s
      title = Nokogiri::XML(open(@url)).css('title').text
      "#{title}, Posts: #{@start_num}-#{@end_num}"
    end

    private

    def start_page_num
      if @last_threadmark
        begin
          feed     = Nokogiri::XML(open("#{@thread_url}/threadmarks.rss"))
          post_url = feed.xpath('//item[1]/link/text()').to_s

          # extract the post's thread-specific number
          post_num = Nokogiri::XML(open(post_url)).css('#' + post_url.split('#').last + ' .postNumber').text[1..-1].to_i
          @start_num = post_num + 1

          post_match = post_url.match(/page-([0-9]+)/)
          return post_match.captures.first.to_i unless post_match.nil?

        rescue OpenURI::HTTPError => e
          puts e
          exit(-1)
          # failure, recover
        end
      end
      page_num(@start_num)
    end

    def page_num(post_num)
      posts_per_page = 25
      ((post_num - 1) / posts_per_page) + 1
    end

    def base_thread_url(url)
      idx = url.split('/').find_index('threads')
      url.split('/')[0..idx + 1].join('/')
    end
  end
end
