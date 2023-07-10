class TermCheckerService
  attr_reader :found_term

  def content_contains_banned_term?(content, banned_terms)
    clean_content = ActionController::Base.helpers.strip_tags(content).gsub(/[^a-zA-Z\s]/, ' ')
    content_words = clean_content.split
    banned_terms_words = banned_terms.gsub(/"[^"]+"|[^a-zA-Z\s]/) {|match| match.start_with?('"') ? match : ' '}
    banned_terms_words = banned_terms_words.scan(/(?:[^"\s]+|"[^"]+")+/)
    banned_phrases = banned_terms.scan(/"(.*?)"/).flatten
    found_term = banned_terms_words.find {|term| content_words.include?(term)}
    if found_term
      @found_term = found_term
      banned_terms_words.any? {|term| content_words.include?(term)}
    else
      @found_term = banned_phrases.find {|phrase| clean_content.include?(phrase)}
      banned_phrases.any? {|phrase| clean_content.include?(phrase)}
    end
  end
end
