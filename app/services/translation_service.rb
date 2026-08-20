class TranslationService
  LANGUAGES = {
    'es' => 'Spanish',
    'fr' => 'French',
    'de' => 'German',
    'pt' => 'Portuguese',
    'it' => 'Italian',
    'nl' => 'Dutch',
    'ru' => 'Russian',
    'zh' => 'Chinese',
    'ja' => 'Japanese',
    'ko' => 'Korean',
    'ar' => 'Arabic',
    'hi' => 'Hindi',
    'tr' => 'Turkish',
    'pl' => 'Polish',
    'sv' => 'Swedish',
    'da' => 'Danish',
    'fi' => 'Finnish',
    'nb' => 'Norwegian',
    'uk' => 'Ukrainian',
    'cs' => 'Czech',
    'el' => 'Greek',
    'he' => 'Hebrew',
    'th' => 'Thai',
    'vi' => 'Vietnamese',
    'id' => 'Indonesian',
    'ur' => 'Urdu'
  }.freeze

  ASSISTANT_URL = ENV.fetch('ASSISTANT_URL', 'http://localhost:3002').freeze

  def initialize(source_lang: 'auto', target_lang:)
    @source_lang = source_lang
    @target_lang = target_lang
  end

  def translate_text(text)
    translate_texts([text])[text] || text
  end

  def translate_texts(texts)
    result = {}
    unique = texts.compact.map(&:to_s).map(&:strip).reject(&:empty?).uniq
    return result if unique.empty?

    pending = unique
    3.times do
      break if pending.empty?
      result.merge!(translate_via_assistant(pending))
      pending = pending.reject { |t| result[t].present? && result[t].strip != t }
    end
    result
  end

  private

  def translate_via_assistant(texts)
    return {} if texts.blank?

    source = @source_lang == 'auto' ? 'en' : @source_lang
    payload = {
      texts: texts,
      target_lang: @target_lang,
      source_lang: source
    }.to_json

    response = RestClient.post(
      "#{ASSISTANT_URL}/api/translate",
      payload,
      content_type: :json,
      accept: :json,
      timeout: 30
    )

    parsed = JSON.parse(response.body)
    translations = parsed['translations'] || {}
    translations.transform_keys(&:to_s)
  rescue => e
    Rails.logger.error("Lotte translate error: #{e.message}")
    {}
  end
end
