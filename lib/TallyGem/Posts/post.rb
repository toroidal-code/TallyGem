require_relative 'parser'

module TallyGem
  class Post
    @@post_parser = PostParser.new
    attr_accessor :votes, :text, :author, :id, :number
    def initialize(id, number, author, text)
      @id, @number, @author, @text = id, number, author, text
      @votes = @@post_parser.parse(text).to_a
    end
  end
end
