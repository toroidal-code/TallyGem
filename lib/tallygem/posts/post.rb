require_relative 'parser'

module TallyGem
  class Post
    attr_accessor :votes, :text, :author, :id, :number
    def initialize(id, number, author, text)
      @id = id
      @number = number
      @author = author
      @text = text
      @votes = TallyGem::PostParser.instance.parse(text).to_a
    end
  end
end
