# test/models/post_token_test.rb

require 'test_helper'

class PostTokenTest < ActiveSupport::TestCase
  test "should belong to a user" do
    user = User.create(name: "Test User")
    post_token = PostToken.new(user: user, post: Post.new, content: ActionText::Content.new("Content"))

    assert post_token.valid?
  end

  test "should belong to a post" do
    post = Post.create(title: "Test Post")
    user = User.create(name: "Test User")
    post_token = PostToken.new(user: user, post: post, content: ActionText::Content.new("Content"))

    assert post_token.valid?
  end

  test "should have many token_ans_debate with dependent destroy" do
    post = Post.create(title: "Test Post")
    user = User.create(name: "Test User")
    post_token = PostToken.create(user: user, post: post, content: ActionText::Content.new("Content"))
    token_ans_debate1 = TokenAnsDebate.create(post_token: post_token, user: user, content: ActionText::Content.new("Debate 1"))
    token_ans_debate2 = TokenAnsDebate.create(post_token: post_token, user: user, content: ActionText::Content.new("Debate 2"))

    assert_includes post_token.token_ans_debate, token_ans_debate1
    assert_includes post_token.token_ans_debate, token_ans_debate2

    assert_difference 'TokenAnsDebate.count', -3 do
      post_token.destroy
    end
  end

  test "should have constants for token types" do
    assert_equal "note", PostToken::TOKEN_TYPE_NOTE
    assert_equal "question", PostToken::TOKEN_TYPE_QUESTION
    assert_equal "debate", PostToken::TOKEN_TYPE_DEBATE
  end

  test "should have scopes for different token types" do
    post1 = Post.create(title: "Test Post 1")
    post2 = Post.create(title: "Test Post 2")
    user = User.create(name: "Test User")
    token1 = PostToken.create(user: user, post: post1, content: ActionText::Content.new("Note Content"), post_token_type: PostToken::TOKEN_TYPE_NOTE)
    token2 = PostToken.create(user: user, post: post1, content: ActionText::Content.new("Question Content"), post_token_type: PostToken::TOKEN_TYPE_QUESTION)
    token3 = PostToken.create(user: user, post: post2, content: ActionText::Content.new("Debate Content"), post_token_type: PostToken::TOKEN_TYPE_DEBATE)

    note_tokens = PostToken.note_tokens
    question_tokens = PostToken.question_tokens
    debate_tokens = PostToken.debate_tokens

    assert_includes note_tokens, token1
    assert_includes question_tokens, token2
    assert_includes debate_tokens, token3
  end
end
