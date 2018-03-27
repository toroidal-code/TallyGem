require 'parslet'

class PostParser < Parslet::Parser
  rule(:eof) { any.absent? }
  rule(:ws)  { str(' ').repeat.ignore }

  rule(:cr)        { str("\n").ignore }
  rule(:eol)       { eof | cr }
  rule(:line_body) { (eol.absent? >> any).repeat(1) }
  rule(:line)      { cr | line_body >> eol }

  rule(:selection) { str('[') >> (str('x') | str('X') | str('✓') | str('✔')) >> str(']') }
  rule(:rank)      { str('[') >> match('[0-9]').repeat(1).as(:rank) >> str(']') }

  rule(:task)      { str('[') >> (str(']').absent? >> any).repeat(1).as(:task) >> str(']') }

  rule(:vote_body) { selection >> ws >> task.maybe >> line_body.as(:vote_text) >> eol }
  rule(:vote_line) { cr | vote_body }

  def subvote(depth)
    dashes = (ws >> str('-')).repeat(depth)
    dash_count = dashes.min

    dashes >> vote_body >>
    dynamic do |src,ctxt|
      (subvote(dash_count + 1) |
        (str('-').absent? >> selection.absent? >> line.ignore)).repeat.as(:subvotes)
    end
  end

  rule(:plan)        { vote_body >> subvote(1).repeat.as(:subvotes) }
  rule(:ranked_vote) { rank >> task.maybe >> line_body.as(:vote_text) }

  rule(:vote) { ranked_vote | plan }
  rule(:post) { vote.repeat }
  root(:post)

  ###############
  # Helpers
  ###############

  def parse(str)
    str = str.each_line
      .collect(&:strip) # strip leading whitespace
      .reject { |s| s[0] != '-' && s[0] != '[' } # filter non-votes out
      .join("\n")

    # parse the vote
    result = root.parse(str)
    result = [] if result.empty?
    convert(result)
    result
  end

  def convert(tree)
    tree.each do |hm|
      hm[:task] = hm[:task].to_s if hm.has_key?(:task)
      hm[:rank] = Integer(hm[:rank]) if hm.has_key?(:rank)
      hm[:vote_text] = hm[:vote_text].to_s if hm.has_key?(:vote_text)
      hm[:subvotes] = convert(hm[:subvotes]) if hm.has_key?(:subvotes) && hm[:subvotes].is_a?(Array)
    end
  end
end
