require 'singleton'
require 'parslet'

module TallyGem
  class PostParser < Parslet::Parser
    include Singleton

    rule(:eof) { any.absent? }
    rule(:ws?) { str(' ').repeat.ignore }

    rule(:cr)        { str("\n").ignore }
    rule(:eol)       { eof | cr }
    rule(:line_body) { (eol.absent? >> any).repeat(1) }
    rule(:line)      { cr | line_body >> eol }

    rule(:selection) { str('[') >> (str('x') | str('X') | str('✓') | str('✔')) >> str(']') }
    rule(:rank)      { str('[') >> match('[1-9]').repeat(1).as(:rank) >> str(']') }

    rule(:task)      { str('[') >> (str(']').absent? >> any).repeat(1).as(:task) >> str(']') }

    rule(:vote_body) { ws? >> task.maybe >> line_body.as(:vote_text) >> eol }

    def plan_vote(depth)
      dashes = (ws? >> str('-')).repeat(depth).capture(:dashes)
      dashes >> selection >> vote_body >> dynamic do |_, ctx|
        dash_count = ctx.captures[:dashes].size
        plan_vote(dash_count + 1).repeat.as(:subvotes)
      end
    end

    rule(:ranked_vote) { rank >> vote_body }

    rule(:vote) { ranked_vote | plan_vote(0) }

    rule(:tally) { line.repeat >> str('#####') >> line.repeat }

    # there can still be some lines that *look* like votes but aren't
    # so we need the `line.ignore` fallback to not fail parsing them.
    rule(:post) { tally.ignore | (vote | line.ignore).repeat }
    root(:post)

    ###############
    # Helpers
    ###############

    def parse(str)
      str = str.each_line
               .collect(&:strip) # strip leading whitespace
               .reject { |s| s[0] != '-' && s[0] != '[' } # filter non-votes out
               .join("\n")

      # Fail fast
      return [] if str.empty?

      # parse the vote content
      result = root.parse(str)
      result = [] if result.nil? || result.empty?
      convert(result)
      result
    end

    def convert(tree)
      tree.each do |hm|
        hm[:task] = hm[:task].to_s if hm.key?(:task)
        hm[:rank] = Integer(hm[:rank]) if hm.key?(:rank)
        hm[:vote_text] = hm[:vote_text].to_s if hm.key?(:vote_text)
        hm[:subvotes] = convert(hm[:subvotes]) if hm.key?(:subvotes) && hm[:subvotes].is_a?(Array)
      end
    end
  end
end
