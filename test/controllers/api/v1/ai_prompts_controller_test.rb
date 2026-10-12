require 'test_helper'

class Api::V1::AiPromptsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @previous_token = ENV['AI_PROMPT_TOKEN']
    ENV['AI_PROMPT_TOKEN'] = 'prompt-secret'
    @prompt = AiPrompt.create!(ai_type: 'LotteFirstTime', description: 'First time here message')
  end

  teardown do
    AiPrompt.where(ai_type: 'LotteFirstTime').delete_all
    ENV['AI_PROMPT_TOKEN'] = @previous_token
  end

  test "rejects missing token" do
    get '/api/v1/ai_prompt', params: { ai_type: 'LotteFirstTime' }
    assert_response :unauthorized
  end

  test "rejects wrong token" do
    get '/api/v1/ai_prompt', params: { ai_type: 'LotteFirstTime', token: 'wrong' }
    assert_response :unauthorized
  end

  test "returns active LotteFirstTime message" do
    get '/api/v1/ai_prompt', params: { ai_type: 'LotteFirstTime', token: 'prompt-secret' }
    assert_response :success
    assert_equal 'First time here message', JSON.parse(response.body)['prompt']
  end

  test "returns newest active version after update" do
    AiPrompt.create!(ai_type: 'LotteFirstTime', description: 'Edited message')
    get '/api/v1/ai_prompt', params: { ai_type: 'LotteFirstTime', token: 'prompt-secret' }
    assert_response :success
    assert_equal 'Edited message', JSON.parse(response.body)['prompt']
  end
end
