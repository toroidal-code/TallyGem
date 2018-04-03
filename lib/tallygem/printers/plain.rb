module TallyGem::Printers
  class Plain
    class << self
      def render(tally)
        output = []
        output << tally.quest.to_s << "\n"
        tally.result.each_with_index do |(task, votes), idx|
          sb = []
          sb << "\n---------------------------------------------------\n" if idx > 0
          sb << "Task: #{task}\n" if task
          votes = votes.sort_by {|_, v| v[:posts].size}.reverse!
          votes.each do |_, vote|
            sb << Common.render_vote(vote[:vote])
            sb << "No. of Votes: #{vote[:posts].size}\n"
          end
          output << sb.join("\n")
        end
        output << "\n\n" << "Total No. of Voters: #{tally.total_voters}" << "\n\n"
      end
    end
  end
end