require_relative '../version'
require_relative 'common'

module TallyGem::Printers
  class BBCode
    class << self

      def render(tally, compact: false)
        output = []
        output << tally.quest.to_s
        output << invisitext("##### TallyGem v#{TallyGem::VERSION}")
        tally.result.each_with_index do |(task, votes), idx|
          sb = []
          sb << horizontal_rule('---------------------------------------------------') + "\n" if idx > 0
          sb << bold("Task: #{task}") + "\n" if task
          votes = votes.sort_by { |_, v| v[:posts].size }.reverse!
          votes.each do |_, vote|
            sb << Common.render_vote(vote[:vote])
            sb << bold("Number of voters: #{vote[:posts].size}")
            sb << vote[:posts].collect { |p| post_link(p.author, p.id) }.join(', ') unless compact
            sb.last << "\n"
          end
          output << sb.join("\n")
        end
        output << "\n" + "Total number of voters: #{tally.total_voters}"
        output.join "\n"
      end

      private

      def bold(str)
        "[b]#{str}[/b]"
      end

      def italic(str)
        "[i]#{str}[/i]"
      end

      def horizontal_rule(str)
        "[hr]#{str}[/hr]"
      end

      def spoiler(str, name = nil)
        if name.nil?
          "[spoiler]\n#{str}\n[/spoiler]"
        else
          "[spoiler=\"#{name}\"]\n#{str}\n[/spoiler]"
        end
      end

      def url(str, link)
        "[url=\"#{link}\"]#{str}[/url]"
      end

      def post_link(str, id)
        "[post=#{id}]#{str}[/post]"
      end

      def invisitext(str)
        "[color=transparent]#{str}[/color]"
      end
    end
  end
end
