class TermCheckerService
  attr_reader :content, :banned_terms

  def initialize(content, banned_terms)
    @content = content
    @banned_terms = banned_terms
  end

  def content_contains_banned_term
    content_words = split_content_into_words(sanitize_content(content))
    banned_terms_words = sanitize_banned_terms(banned_terms)
    banned_phrases = extract_banned_phrases(banned_terms)

    found_term = find_catched_term(content_words, banned_terms_words)
    found_phrase = find_catched_phrase(sanitize_content(content), banned_phrases)
    return nil if found_term.blank? && found_phrase.blank?

    found_term || found_phrase
  end

  private

  def sanitize_content(content)
    ActionController::Base.helpers.strip_tags(content).gsub(/[^a-zA-Z\s]/, ' ')
  end

  def split_content_into_words(content)
    content.split
  end

  def sanitize_banned_terms(terms)
    terms.gsub(/"[^"]+"|[^a-zA-Z\s]/) {|match| match.start_with?('"') ? match : ' '}
        .scan(/(?:[^"\s]+|"[^"]+")+/)
  end

  def extract_banned_phrases(terms)
    terms.scan(/"(.*?)"/).flatten
  end

  def find_catched_term(content_words, banned_terms_words)
    banned_terms_words.find {|term| content_words.include?(term)}
  end

  def find_catched_phrase(content, banned_phrases)
    banned_phrases.find {|phrase| content.include?(phrase)}
  end
end
