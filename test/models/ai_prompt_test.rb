require 'test_helper'

class AiPromptTest < ActiveSupport::TestCase
  test "LotteFirstTime is a valid type" do
    assert_includes AiPrompt::TYPES, 'LotteFirstTime'
    prompt = AiPrompt.new(ai_type: 'LotteFirstTime', description: 'Welcome aboard')
    assert prompt.valid?
  end

  test "create assigns version and activates, deactivating previous active" do
    first = AiPrompt.create!(ai_type: 'LotteFirstTime', description: 'v1 message')
    second = AiPrompt.create!(ai_type: 'LotteFirstTime', description: 'v2 message')

    assert_equal 1, first.version
    assert_equal 2, second.version
    assert second.active
    first.reload
    assert_not first.active
    assert_equal second, AiPrompt.active_for_type('LotteFirstTime').take
  end

  test "rejects unknown type" do
    prompt = AiPrompt.new(ai_type: 'Wallace', description: 'nope')
    assert_not prompt.valid?
  end
end
