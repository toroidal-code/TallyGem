module TallyGem
  class Tally
    def initialize(quest)
      @quest        = quest
      @tally        = nil
      @total_voters = 0
    end

    def run
      return @tally unless @tally.nil?

      posts = @quest.posts.reject { |p| p.votes.empty? }

      posts = posts.each_with_object({}) do |post, author_map|
        if !author_map.key?(post.author) || post.id > author_map[post.author].id
          author_map[post.author] = post
        end
        @total_voters = author_map.size
      end.values

      @tally = posts.each_with_object({}) do |post, counts|
        post.votes.each do |vote|
          nws               = squash_and_clean(vote)
          task              = vote[:task]
          counts[task]      ||= {}
          counts[task][nws] ||= { vote: vote, posts: [] }
          counts[task][nws][:posts] << post
        end
      end
    end

    def render
      output = []
      output << @quest.to_s << "\n"
      @tally.each_with_index do |(task, votes), idx|
        sb = []
        sb << "\n---------------------------------------------------\n" if idx > 0
        sb << "Task: #{task}\n" if task
        votes = votes.sort_by {|_, v| v[:posts].size}.reverse!
        votes.each do |_, vote|
          sb << render_vote(vote[:vote]) +
                "No. of Votes: #{vote[:posts].size}\n"
        end
        output << sb.join("\n")
      end
      output << "\n\n" << "Total No. of Voters: #{@total_voters}" << "\n\n"
    end

    private

    def squash_and_clean(tree)
      return if tree.empty?
      tree             = tree.clone
      tree[:vote_text] = tree[:vote_text].clone.gsub(/[^\w]/, '').downcase if tree.key?(:vote_text)
      tree[:subvotes]  = tree[:subvotes].collect { |sv| squash_and_clean(sv) } if tree.key?(:subvotes) && tree[:subvotes].is_a?(Array)
      tree
    end

    def render_vote(vote, depth = 0)
      rv = '-' * depth
      rv << '[X]'
      rv << "[#{vote[:task]}]" if vote.key?(:task)
      rv << vote[:vote_text] << "\n"
      vote[:subvotes].each {|sv| rv << render_vote(sv, depth + 1)} if vote.key?(:subvotes)
      rv
    end
  end
end