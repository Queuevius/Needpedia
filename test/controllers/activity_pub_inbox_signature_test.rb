require 'test_helper'
require 'minitest/mock'

# Inbound ActivityPub HTTP-signature verification (fail-closed).
# See ActivityPub::ActorsController#verify_signature!
class ActivityPubInboxSignatureTest < ActionDispatch::IntegrationTest
  ACTOR = 'https://remote.test/actor/alice'.freeze
  SIGNED_HEADERS = ['(request-target)', 'host', 'date', 'digest'].freeze

  setup do
    @user = users(:one)
    @alice_key = OpenSSL::PKey::RSA.new(2048)
    @rogue_key = OpenSSL::PKey::RSA.new(2048)
    @alice_pem = @alice_key.public_key.to_pem
  end

  test 'valid signature processes follow' do
    body = follow_body
    headers = sign(body, key_id: "#{ACTOR}#main-key", key: @alice_key)

    stub_rest_client do
      stub_request_service do
        assert_difference 'RemoteFollow.count', 1 do
          post inbox_path, params: body, headers: headers
        end
      end
    end

    assert_response :accepted
    follow = RemoteFollow.find_by(actor_id: ACTOR)
    assert follow, 'RemoteFollow should be created'
    assert_equal @user, follow.user
    assert_equal RemoteFollow::ACCEPTED, follow.status
  end

  test 'missing signature header is rejected without network calls' do
    post inbox_path,
         params: follow_body,
         headers: { 'CONTENT_TYPE' => 'application/activity+json' }

    assert_response :unauthorized
  end

  test 'stale date is rejected before any key fetch' do
    body = follow_body
    headers = sign(body,
                   key_id: "#{ACTOR}#main-key",
                   key: @alice_key,
                   date: 2.hours.ago.httpdate)

    post inbox_path, params: body, headers: headers

    assert_response :unauthorized
  end

  test 'keyId not matching activity actor is rejected' do
    body = follow_body
    headers = sign(body,
                   key_id: 'https://remote.test/actor/mallory#main-key',
                   key: @alice_key)

    post inbox_path, params: body, headers: headers

    assert_response :unauthorized
  end

  test 'signature made with a different key is rejected' do
    body = follow_body
    headers = sign(body, key_id: "#{ACTOR}#main-key", key: @rogue_key)

    stub_rest_client do
      post inbox_path, params: body, headers: headers
    end

    assert_response :unauthorized
  end

  test 'tampered body is rejected by digest check' do
    body = follow_body
    headers = sign(body, key_id: "#{ACTOR}#main-key", key: @alice_key)
    tampered = follow_body(object: 'https://www.example.com/activity_pub/actors/999999')

    stub_rest_client do
      post inbox_path, params: tampered, headers: headers
    end

    assert_response :unauthorized
  end

  test 'garbage signature header is rejected' do
    post inbox_path,
         params: follow_body,
         headers: { 'CONTENT_TYPE' => 'application/activity+json',
                    'Signature' => 'keyId="x",bogus="1"' }

    assert_response :unauthorized
  end

  private

  def inbox_path
    inbox_activity_pub_actor_path(@user)
  end

  def follow_body(actor: ACTOR, object: nil)
    object ||= "https://www.example.com/activity_pub/actors/#{@user.id}"
    { '@context' => 'https://www.w3.org/ns/activitystreams',
      'id' => "#{actor}/follows/1",
      'type' => 'Follow',
      'actor' => actor,
      'object' => object }.to_json
  end

  # Signs a synthetic Net::HTTP request the way remote servers do.
  def sign(body, key_id:, key:, date: Time.now.httpdate)
    digest = "SHA-256=#{Base64.strict_encode64(Digest::SHA256.digest(body))}"
    msg = Net::HTTP::Post.new(inbox_path)
    msg['Host'] = 'www.example.com'
    msg['Date'] = date
    msg['Digest'] = digest

    HttpSignatures::Context.new(
      keys: { key_id => { private_key: key.to_pem } },
      algorithm: 'rsa-sha256',
      headers: SIGNED_HEADERS
    ).signer.sign(msg)

    { 'Signature' => msg['Signature'],
      'Date' => msg['Date'],
      'Digest' => msg['Digest'],
      'CONTENT_TYPE' => 'application/activity+json' }
  end

  # Any actor document fetched by the controller is served from memory,
  # always publishing alice's real public key (owner == requested URL).
  def stub_rest_client
    response = Struct.new(:body)
    responder = ->(url, *_) { response.new(actor_doc(url)) }
    RestClient.stub(:get, responder) { yield }
  end

  def actor_doc(url)
    { 'id' => url,
      'inbox' => "#{url}/inbox",
      'publicKey' => { 'id' => "#{url}#main-key",
                       'owner' => url,
                       'publicKeyPem' => @alice_pem } }.to_json
  end

  # Accept-activity delivery is out of scope here.
  def stub_request_service
    fake = Object.new
    def fake.send_accept_follow(_activity)
      true
    end
    ActivityPub::RequestService.stub(:new, fake) { yield }
  end
end
