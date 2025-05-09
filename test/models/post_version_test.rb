# test/models/post_version_test.rb

require 'test_helper'

class PostVersionTest < ActiveSupport::TestCase
  test "should belong to a post" do
    post = Post.create(title: "Test Post")
    user = User.create(name: "Test User")
    post_version = PostVersion.new(post: post, user: user, content: ActionText::Content.new("Content"))

    assert post_version.valid?
  end

  test "should belong to a user" do
    post = Post.create(title: "Test Post")
    user = User.create(name: "Test User")
    post_version = PostVersion.new(post: post, user: user, content: ActionText::Content.new("Content"))

    assert post_version.valid?
  end

  test "should have many flags with dependent destroy" do
    post = Post.create(title: "Test Post")
    user = User.create(name: "Test User")
    post_version = PostVersion.create(post: post, user: user, content: ActionText::Content.new("Content"))
    flag1 = Flag.create(flagable: post_version, user: user, reason: "Flag 1")
    flag2 = Flag.create(flagable: post_version, user: user, reason: "Flag 2")

    assert_includes post_version.flags, flag1
    assert_includes post_version.flags, flag2

    assert_difference 'Flag.count', -2 do
      post_version.destroy
    end
  end

  test "should have many deletion requests with dependent destroy" do
    post = Post.create(title: "Test Post")
    user = User.create(name: "Test User")
    post_version = PostVersion.create(post: post, user: user, content: ActionText::Content.new("Content"))
    deletion_request1 = DeletionRequest.create(post_version: post_version, user: user, reason: ActionText::Content.new("Deletion Reason 1"))
    deletion_request2 = DeletionRequest.create(post_version: post_version, user: user, reason: ActionText::Content.new("Deletion Reason 2"))

    assert_includes post_version.deletion_requests, deletion_request1
    assert_includes post_version.deletion_requests, deletion_request2

    assert_difference 'DeletionRequest.count', -2 do
      post_version.destroy
    end
  end

  test "should have rich text content" do
    post = Post.create(title: "Test Post")
    user = User.create(name: "Test User")
    post_version = PostVersion.new(post: post, user: user)

    assert post_version.valid?
  end

  test "should update post content and mark last version as active on destroy" do
    post = Post.create(title: "Test Post")
    user = User.create(name: "Test User")
    post_version1 = PostVersion.create(post: post, user: user, content: ActionText::Content.new("Version 1"))
    post_version2 = PostVersion.create(post: post, user: user, content: ActionText::Content.new("Version 2"))

    post_version1.destroy

    post.reload
    post_version2.reload

    assert_equal "Version 2", post.content.to_plain_text
    assert post_version2.active
  end

  test "should delete post if there are no more versions" do
    post = Post.create(title: "Test Post")
    user = User.create(name: "Test User")
    post_version = PostVersion.create(post: post, user: user, content: ActionText::Content.new("Version 1"))

    post_version.destroy

    assert_raises(ActiveRecord::RecordNotFound) { post.reload }
  end
end
