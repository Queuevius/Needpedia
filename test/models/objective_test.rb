# test/models/objective_test.rb

require 'test_helper'

class ObjectiveTest < ActiveSupport::TestCase
  test "should belong to a parent (optional)" do
    parent = Objective.create
    objective = Objective.new(parent: parent, post: Post.new, user: User.new, body: "Objective")

    assert objective.valid?
  end

  test "should have many replies with dependent destroy" do
    parent = Objective.create
    objective1 = Objective.create(parent: parent, post: Post.new, user: User.new, body: "Reply 1")
    objective2 = Objective.create(parent: parent, post: Post.new, user: User.new, body: "Reply 2")

    assert_includes parent.replies, objective1
    assert_includes parent.replies, objective2

    assert_difference 'Objective.count', -3 do
      parent.destroy
    end
  end

  test "should belong to a post" do
    post = Post.create(title: "Test Post")
    objective = Objective.new(post: post, user: User.new, body: "Objective")

    assert objective.valid?
  end

  test "should belong to a user" do
    user = User.create(name: "Test User")
    objective = Objective.new(user: user, post: Post.new, body: "Objective")

    assert objective.valid?
  end

  test "should have a maximum body length of 350 characters" do
    objective = Objective.new(body: "a" * 350)

    assert objective.valid?

    objective.body = "a" * 351
    assert_not objective.valid?
    assert_includes objective.errors[:body], "is too long (maximum is 350 characters)"
  end
end
