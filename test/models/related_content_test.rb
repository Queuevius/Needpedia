# test/models/related_content_test.rb

require 'test_helper'

class RelatedContentTest < ActiveSupport::TestCase
  def setup
    @user = User.create(username: 'user1', email: 'user1@example.com', password: 'password')
    @post = Post.create(title: 'Sample Post', user: @user)
  end

  test 'should be valid with valid attributes' do
    related_content = RelatedContent.new(parent: nil, post: @post, user: @user, body: 'This is a valid related content.')
    assert related_content.valid?
  end

  test 'should not be valid without a user' do
    related_content = RelatedContent.new(parent: nil, post: @post, body: 'Missing user.')
    assert_not related_content.valid?
  end

  test 'should not be valid without a post' do
    related_content = RelatedContent.new(parent: nil, user: @user, body: 'Missing post.')
    assert_not related_content.valid?
  end

  test 'should have a MAX_BODY_LENGTH constant' do
    assert_equal 350, RelatedContent::MAX_BODY_LENGTH
  end

  test 'should belong to a parent with a class_name' do
    association = RelatedContent.reflect_on_association(:parent)
    assert_equal :belongs_to, association.macro
    assert_equal 'RelatedContent', association.class_name
  end

  test 'should have many replies with the specified class_name and dependent: destroy' do
    association = RelatedContent.reflect_on_association(:replies)
    assert_equal :has_many, association.macro
    assert_equal 'RelatedContent', association.class_name
    assert_equal :destroy, association.options[:dependent]
  end

  test 'should belong to a post' do
    association = RelatedContent.reflect_on_association(:post)
    assert_equal :belongs_to, association.macro
  end

  test 'should belong to a user' do
    association = RelatedContent.reflect_on_association(:user)
    assert_equal :belongs_to, association.macro
  end
end
