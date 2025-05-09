require 'test_helper'

class DeletionTest < ActiveSupport::TestCase
  test "should belong to a deletable object" do
    user = User.create(name: "Test User")
    post = Post.create(title: "Test Post", user: user)

    deletion = Deletion.new(deletable: post, user: user)

    assert deletion.valid?
  end

  test "should belong to a user" do
    user = User.create(name: "Test User")
    post = Post.create(title: "Test Post", user: user)

    deletion = Deletion.new(deletable: post, user: user)

    assert deletion.valid?
  end

  test "should require presence of deletable" do
    user = User.create(name: "Test User")

    deletion = Deletion.new(user: user)

    assert_not deletion.valid?
    assert_includes deletion.errors[:deletable], "must exist"
  end

  test "should require presence of user" do
    post = Post.create(title: "Test Post")

    deletion = Deletion.new(deletable: post)

    assert_not deletion.valid?
    assert_includes deletion.errors[:user], "must exist"
  end
end
