module GibberishHelper
  require 'set'

  class GibberishDetector
    def initialize
      @dictionary = Set.new(File.readlines('words.txt').map(&:chomp))
    end

    def gibberish?(text)
      words = text.split(/\W+/)
      valid_word_count = words.count { |word| @dictionary.include?(word.downcase) }
      gibberish_ratio = 1.0 - valid_word_count.to_f / words.size
      gibberish_ratio > 0.5  
    end
  end

  def gibberish?(text)
    detector = GibberishDetector.new
    detector.gibberish?(text)
  end
end
