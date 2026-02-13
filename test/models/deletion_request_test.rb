require 'test_helper'

class DeletionRequestTest < ActiveSupport::TestCase
  test "should belong to a post_version" do
    post_version = PostVersion.create(title: "Test Post Version")
    deletion_request = DeletionRequest.new(post_version: post_version, user: User.new, reason: "Requesting deletion")

    assert deletion_request.valid?
  end

  test "should belong to a user" do
    user = User.create(name: "Test User")
    deletion_request = DeletionRequest.new(post_version: PostVersion.new, user: user, reason: "Requesting deletion")

    assert deletion_request.valid?
  end

  test "should have rich text content for reason" do
    deletion_request = DeletionRequest.new(post_version: PostVersion.new, user: User.new)
    deletion_request.reason = ActionText::Content.new("Requesting deletion")

    assert deletion_request.valid?
  end

  test "should require presence of post_version" do
    deletion_request = DeletionRequest.new(user: User.new, reason: "Requesting deletion")

    assert_not deletion_request.valid?
    assert_includes deletion_request.errors[:post_version], "can't be blank"
  end

  test "should require presence of user" do
    deletion_request = DeletionRequest.new(post_version: PostVersion.new, reason: "Requesting deletion")

    assert_not deletion_request.valid?
    assert_includes deletion_request.errors[:user], "can't be blank"
  end

  test "should require presence of reason" do
    deletion_request = DeletionRequest.new(post_version: PostVersion.new, user: User.new)

    assert_not deletion_request.valid?
    assert_includes deletion_request.errors[:reason], "can't be blank"
  end
end
