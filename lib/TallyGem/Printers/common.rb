module TallyGem::Printers
  class Common
    class << self
      def render_vote(vote, depth = 0)
        rv = '-' * depth
        rv << '[X]'
        rv << "[#{vote[:task]}]" if vote.key?(:task)
        rv << vote[:vote_text]
        vote[:subvotes].each {|sv| rv << render_vote(sv, depth + 1)} if vote.key?(:subvotes)
        rv
      end
    end
  end
end