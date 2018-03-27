# PORTED FROM ORIGINAL NETTALLY
# TODO: cleanup this stuff

require 'contracts'
require '../Votes/vote_string'

module TallyGem
  class PostComponents
    include Contracts::Core
    include Contracts::Builtin

#    TALLY_REGEX = /^#####/
#    VOTE_LINE_REGEX = /^[-\s]*\[\s*[xX✓✔1-9]\s*\]/
#    NOMINATION_LINE_REGEX = %r{\[url="[^"]+?/members/\d+/"\](?<username>@[^\[]+)\[/url\]\s*$}

    attr_reader :author, :number,
                :id, :text, :id_value,
                :vote_strings, :base_plans,
                :rank_lines, :working_vote
    attr_accessor :processed, :force_process

    # Does this post have a vote?
    def vote?
      !vote_strings.nil? && vote_strings.size >  0
    end

    Contract String, String, String, Nat, Maybe[Quest] => PostComponents
    def initialize(author, id, text, number=0, quest=nil)
      @text = text
      @author = author
      @id = id
      @number = number
      @id_value = id.to_i
      return if self.is_tally_post?(text)

      lines = text.lines
      vote_lines = lines.select { |a| VoteString.remove_bbcode(a) =~ (VOTE_LINE_REGEX) }

      if !vote_lines.empty?
        collected = vote_lines.collect {|a| VoteString.clean_vote_line_bbcode(a) }
        collected = collected.collect{|a| VoteString.modify_lines_read(a)} if !quest.nil? && quest.trim_extended_text
        @vote_strings = collected.collect{|a| VoteString.clean_vote_line_bbcode(a)}
        PostComponents.separate_vote_strings(@vote_strings)
      elsif lines.all? {|a| a =~ NOMINATION_LINE_REGEX }
        @vote_strings = lines.collect{|a| '[X] ' + a.trim}
        PostComponents.separate_vote_strings(@vote_strings)
      end

    end
  end

  def self.is_tally_post?(post_text)
    clean_text = VoteString.remove_bbcode(post_text)
    cleantext =~ TALLY_REGEX ? true : false
  end
end
