module AiPromptDiffHelper
  def description_diff(old_desc, new_desc)
    old_words = old_desc.to_s.split(/\s+/)
    new_words = new_desc.to_s.split(/\s+/)

    lcs = lcs_matrix(old_words, new_words)
    i, j = old_words.length, new_words.length
    result = +""

    while i > 0 || j > 0
      if i > 0 && j > 0 && old_words[i - 1] == new_words[j - 1]
        result.prepend(" #{ERB::Util.h(old_words[i - 1])}")
        i -= 1
        j -= 1
      elsif j > 0 && (i == 0 || lcs[i][j - 1] >= lcs[i - 1][j])
        result.prepend(" <ins class='diff-add'>#{ERB::Util.h(new_words[j - 1])}</ins>")
        j -= 1
      else
        result.prepend(" <del class='diff-remove'>#{ERB::Util.h(old_words[i - 1])}</del>")
        i -= 1
      end
    end

    result.html_safe
  end

  private

  def lcs_matrix(a, b)
    m = a.length
    n = b.length
    dp = Array.new(m + 1) { Array.new(n + 1, 0) }
    (1..m).each do |i|
      (1..n).each do |j|
        dp[i][j] = a[i - 1] == b[j - 1] ? dp[i - 1][j - 1] + 1 : [dp[i - 1][j], dp[i][j - 1]].max
      end
    end
    dp
  end
end
