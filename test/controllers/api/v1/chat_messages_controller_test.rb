require 'test_helper'

class Api::V1::ChatMessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @thread = @user.chat_threads.create!(
      thread_id: 'draft-thread',
      title: 'Draft thread',
      assistant_name: 'Lotte'
    )
  end

  def auth_headers
    { 'Authorization' => @user.uuid }
  end

  test 'persists metadata-only assistant message and round-trips it' do
    draft = { 'title' => 'Mow the lawn', 'description' => 'Front yard', 'hours' => 2 }

    assert_difference '@thread.chat_messages.count', 1 do
      post '/api/v1/chat_messages',
           params: {
             thread_id: 'draft-thread',
             messages: [{ role: 'assistant', content: '', metadata: { taskDraft: draft } }]
           },
           headers: auth_headers, as: :json
    end
    assert_response :created

    stored = @thread.chat_messages.last
    assert_equal draft, stored.metadata['taskDraft']

    get '/api/v1/chat_messages?thread_id=draft-thread', headers: auth_headers
    assert_response :success
    body = JSON.parse(response.body)
    round_tripped = body['messages'].find { |m| m['metadata'].present? }
    assert round_tripped, 'expected a message with metadata in index response'
    assert_equal draft, round_tripped['metadata']['taskDraft']
  end

  test 'still rejects content-less rows without metadata' do
    assert_no_difference '@thread.chat_messages.count' do
      post '/api/v1/chat_messages',
           params: {
             thread_id: 'draft-thread',
             messages: [{ role: 'assistant', content: '' }]
           },
           headers: auth_headers, as: :json
    end
    assert_response :unprocessable_entity
  end

  test 'rejects request without token' do
    post '/api/v1/chat_messages',
         params: { thread_id: 'draft-thread', messages: [{ role: 'user', content: 'hi' }] },
         as: :json
    assert_response :unauthorized
  end
end
