
module TallyGem
  module SplitBy
    class Block
      def self.split(forest)
        forest
      end
    end

    class Recursive
      def self.split(forest, recursive = true, depth = 1, task = nil)
        set = Set.new

        forest.each do |tree|
          # get the current task
          task = tree[:task] if tree.key? :task

          if tree.key?(:subvotes) && !tree[:subvotes].empty?
            tree[:subvotes].each do |sv|
              sv[:task]  ||= task unless task.nil?
              sv[:depth] ||= depth
            end

            set.merge split(tree[:subvotes], recursive, depth + 1, task)

            tree[:subvotes].clear unless recursive
          end

          # add the parent vote
          set.add tree
        end
        set
      end
    end

    class Line
      def self.split(forest)
        Recursive.split(forest, false)
      end
    end
  end

  class Tally
    attr_reader :quest, :result, :total_voters

    def initialize(quest, partitioner = Partitions::Block)
      @quest        = quest
      @result       = nil
      @total_voters = 0
      @partitioner  = partitioner
    end

    # TODO: Plans and nominations
    def run
      return @result unless @result.nil?

      # remove any posts that don't have votes
      posts = @quest.posts.reject { |p| p.votes.empty? }

      # filter so that only the latest vote post by the author exists
      author_map = {}
      posts.each do |post|
        if !author_map.key?(post.author) || post.id > author_map[post.author].id
          author_map[post.author] = post
        end
      end
      @total_voters = author_map.size

      posts = author_map.values

      @result = posts.each_with_object({}) do |post, counts|
        @partitioner.split(post.votes).each do |vote|
          nws               = squash_and_clean(vote)
          task              = vote[:task]
          counts[task]      ||= {}
          counts[task][nws] ||= { vote: vote, posts: [] }
          counts[task][nws][:posts] << post
        end
      end
    end

    private

    def squash_and_clean(tree)
      return if tree.empty?
      tree             = tree.clone
      tree[:vote_text] = tree[:vote_text].clone.gsub(/[^\w]/, '').downcase if tree.key?(:vote_text)
      tree[:subvotes]  = tree[:subvotes].collect { |sv| squash_and_clean(sv) } if tree.key?(:subvotes)
      tree
    end
  end
end
