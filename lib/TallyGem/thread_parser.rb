require 'open-uri'
require 'nokogiri'

require_relative 'Posts/parser'
require_relative 'Posts/post'


def page_num(post_num)
  posts_per_page = 25
  ((post_num - 1) / posts_per_page) + 1
end

def base_thread_url(url)
  idx = url.split('/').find_index('threads')
  url.split('/')[0..idx + 1].join('/')
end

def render_vote(vote, depth=0)
  rv = "-" * depth
  rv << "[X]"
  rv << "[#{vote[:task]}]" if vote.has_key?(:task)
  rv << vote[:vote_text] << "\n"
  vote[:subvotes].each { |sv| rv << render_vote(sv, depth+1) } if vote.has_key?(:subvotes)
  rv
end

url = "https://forums.sufficientvelocity.com/threads/beyond-our-reach-the-stars-did-form.45755/page-9#post-10407233"
start_num = 205
posts_per_page = 25

thread_url = base_thread_url(url)
start_page_num = page_num(start_num)
firstpage = Nokogiri::XML(open("#{thread_url}/page-#{start_page_num}"))

end_num = nil
# 'Page x of y' => Int(y)
end_page_num = !end_num.nil? ? page_num(end_num) : firstpage.css('.pageNavHeader').text.split.last.to_i

posts = (start_page_num..end_page_num).collect do |page_num|
  page = Nokogiri::XML(open("#{thread_url}/page-#{page_num}"))
  page.css('.messageList .message').collect do |message|
    # replace imgs with alttext
    message.css('img').each { |img| img.replace("#{img['alt']}") }
    # remove quotes
    message.css('.bbCodeQuote').remove
    # remove spoilers
    message.css('.bbCodeSpoilerContainer').remove

    number = message.css('.postNumber').text.gsub(/#/,'').to_i
    next if number < start_num || number > (end_num || end_page_num * posts_per_page)

    id = message['id']
    author = message['data-author']
    text = message.css('.messageContent article .messageText').text.strip
    Post.new(id, number, author, text)
  end
end.flatten.reject { |p| p.nil? || p.votes.empty? }

def squash_and_clean(tree)
  return if tree.empty?
  tree = tree.clone
  tree[:vote_text] = tree[:vote_text].clone.gsub(/[^\w]/, '').downcase if tree.has_key?(:vote_text)
  tree[:subvotes] = tree[:subvotes].collect(&:squash_and_clean) if tree.has_key?(:subvotes) && tree[:subvotes].is_a?(Array)
  tree
end

total_voters = 0

posts = posts.each_with_object({}) do |post, author_map|
  if !author_map.has_key?(post.author) || post.id > author_map[post.author].id
    author_map[post.author] = post
  end
  total_voters = author_map.size
end.values

tally = posts.each_with_object({}) do |post, counts|
  post.votes.each do |vote|
    nws = squash_and_clean(vote)
    task = vote[:task]
    counts[task] ||= {}
    counts[task][nws] ||= {vote: vote, posts: []}
    counts[task][nws][:posts] << post
  end
end

output = []
output << firstpage.css('title').text << "\n"
tally.each_with_index do |(task,votes),idx|
  sb = []
  sb << "\n---------------------------------------------------\n" if idx > 0
  sb << "Task: #{task}\n" if task
  votes = votes.sort_by { |_,v| v[:posts].size }.reverse!
  votes.each do |_,vote|
    sb << render_vote(vote[:vote]) +
      "No. of Votes: #{vote[:posts].size}\n"
  end
  output << sb.join("\n")
end

output << "\n\n" << "Total No. of Voters: #{total_voters}" << "\n\n"
puts output

