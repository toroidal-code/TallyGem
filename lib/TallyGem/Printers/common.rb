module TallyGem::Printers
  class Common
    class << self
      def render_vote(vote, depth = 0)
        depth = vote[:depth] if vote.key? :depth

        rv = '-' * depth
        rv << '[X]'
        rv << "[#{vote[:task]}]" if vote.key?(:task)
        rv << vote[:vote_text]
        vote[:subvotes].each { |sv| rv << "\n" + render_vote(sv, depth + 1) } if vote.key? :subvotes
        rv
      end
    end
  end
end
