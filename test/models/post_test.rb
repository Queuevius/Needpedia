# # test/models/post_test.rb

# require 'test_helper'

# class PostTest < ActiveSupport::TestCase
#   def setup
#     @user = users(:one)
#     @subject_post = posts(:subject_post)
#   end

#   test 'should be valid' do
#     post = Post.new(title: 'Example Post', post_type: 'subject', user: @user)
#     assert post.valid?
#   end

#   test 'should not be valid without a title' do
#     post = Post.new(title: '', post_type: 'subject', user: @user)
#     assert_not post.valid?
#   end

#   test 'should not be valid without a post_type' do
#     post = Post.new(title: 'Example Post', post_type: nil, user: @user)
#     assert_not post.valid?
#   end

#   test 'should not be valid with an invalid post_type' do
#     post = Post.new(title: 'Example Post', post_type: 'invalid_type', user: @user)
#     assert_not post.valid?
#   end

#   test 'should require subject_id for POST_TYPE_PROBLEM' do
#     post = Post.new(title: 'Example Post', post_type: 'problem', user: @user)
#     assert_not post.valid?
#   end

#   test 'should require problem_id for POST_TYPE_IDEA' do
#     post = Post.new(title: 'Example Post', post_type: 'idea', user: @user)
#     assert_not post.valid?
#   end

#   test 'should require lat for geo_maxing posts' do
#     post = Post.new(title: 'Example Post', post_type: 'geomaxing', user: @user, lat: nil, long: 123.456)
#     assert_not post.valid?
#   end

#   test 'should require long for geo_maxing posts' do
#     post = Post.new(title: 'Example Post', post_type: 'geomaxing', user: @user, lat: 12.345, long: nil)
#     assert_not post.valid?
#   end

#   test 'belongs to a user' do
#     post = Post.new(title: 'Example Post', post_type: 'subject', user: @user)
#     assert_equal @user, post.user
#   end

#   test 'can have a parent subject post' do
#     post = Post.new(title: 'Example Post', post_type: 'problem', user: @user, subject_id: @subject_post.id)
#     assert_equal @subject_post, post.parent_subject
#   end

#   test 'can have child posts' do
#     post = Post.new(title: 'Example Post', post_type: 'subject', user: @user)
#     child_post = Post.new(title: 'Child Post', post_type: 'problem', user: @user, subject_id: post.id)
#     post.save
#     child_post.save
#     assert_includes post.child_posts, child_post
#   end

#   test 'can have a problem post' do
#     post = Post.new(title: 'Example Post', post_type: 'idea', user: @user, problem_id: @subject_post.id)
#     assert_equal @subject_post, post.problem
#   end

#   test 'can have ideas' do
#     post = Post.new(title: 'Example Post', post_type: 'problem', user: @user)
#     idea = Post.new(title: 'Idea Post', post_type: 'idea', user: @user, problem_id: post.id)
#     post.save
#     idea.save
#     assert_includes post.ideas, idea
#   end

#   test 'sends a notification after create for specific post types' do
#     post = Post.new(title: 'Example Post', post_type: 'layer', user: @user)
#     assert_difference('Notification.count') do
#       post.save
#     end
#   end

#   test 'checks if tracking is enabled for the user' do
#     post = Post.new(title: 'Example Post', post_type: 'subject', user: @user)
#     user_post = UserPost.new(user: @user, post: post)
#     user_post.save
#     assert post.tracking_enabled?
#   end

#   test 'cleans Froala link in content' do
#     post = Post.new(title: 'Example Post', post_type: 'subject', user: @user)
#     post.content = ActionText::Content.new(body: "This is a Froala link. Powered by Froala Editor.")
#     post.clean_froala_link
#     assert_equal "This is a Froala link. ", post.content.body.to_s
#   end

#   test 'checks if post type matches a given type' do
#     post = Post.new(title: 'Example Post', post_type: 'subject', user: @user)
#     assert post.type_of?('subject')
#     assert_not post.type_of?('problem')
#   end

#   test 'sends notification to posted_to user after create' do
#     posted_to_user = users(:two) # Replace with your user fixture or create a user instance
#     post = Post.new(title: 'Example Post', post_type: 'subject', user: @user, posted_to: posted_to_user)
#     assert_difference('Notification.count') do
#       post.save
#     end
#   end

#   test 'sends notification on layer create' do
#     parent_post_user = users(:three) # Replace with your user fixture or create a user instance
#     parent_post = Post.new(title: 'Parent Post', post_type: 'layer', user: parent_post_user)
#     parent_post.save
#     post = Post.new(title: 'Layer Post', post_type: 'layer', user: @user, post_id: parent_post.id)
#     assert_difference('Notification.count') do
#       post.save
#     end
#   end

#   test 'requires lat for geo_maxing posts' do
#     post = Post.new(title: 'Example Post', post_type: 'geomaxing', user: @user, lat: nil, long: 123.456)
#     assert_not post.valid?
#   end

#   test 'requires long for geo_maxing posts' do
#     post = Post.new(title: 'Example Post', post_type: 'geomaxing', user: @user, lat: 12.345, long: nil)
#     assert_not post.valid?
#   end

#   test 'returns posts_feed' do
#     post1 = Post.new(title: 'Feed Post 1', post_type: 'subject', user: @user)
#     post2 = Post.new(title: 'Feed Post 2', post_type: 'problem', user: @user)
#     post3 = Post.new(title: 'Feed Post 3', post_type: 'idea', user: @user)
#     post4 = Post.new(title: 'Feed Post 4', post_type: 'layer', user: @user)
#     post1.save
#     post2.save
#     post3.save
#     post4.save

#     posts = Post.posts_feed
#     assert_includes posts, post1
#     assert_not_includes posts, post2
#     assert_not_includes posts, post3
#     assert_not_includes posts, post4
#   end

#   test 'returns area_posts' do
#     post1 = Post.new(title: 'Area Post 1', post_type: 'subject', user: @user)
#     post2 = Post.new(title: 'Area Post 2', post_type: 'problem', user: @user)
#     post3 = Post.new(title: 'Area Post 3', post_type: 'subject', user: @user)
#     post4 = Post.new(title: 'Area Post 4', post_type: 'idea', user: @user)
#     post1.save
#     post2.save
#     post3.save
#     post4.save

#     posts = Post.area_posts
#     assert_includes posts, post1
#     assert_not_includes posts, post2
#     assert_includes posts, post3
#     assert_not_includes posts, post4
#   end

#   test 'returns problem_posts' do
#     post1 = Post.new(title: 'Problem Post 1', post_type: 'problem', user: @user)
#     post2 = Post.new(title: 'Problem Post 2', post_type: 'subject', user: @user)
#     post3 = Post.new(title: 'Problem Post 3', post_type: 'idea', user: @user)
#     post4 = Post.new(title: 'Problem Post 4', post_type: 'layer', user: @user)
#     post1.save
#     post2.save
#     post3.save
#     post4.save

#     posts = Post.problem_posts
#     assert_includes posts, post1
#     assert_not_includes posts, post2
#     assert_not_includes posts, post3
#     assert_not_includes posts, post4
#   end

#   test 'returns idea_posts' do
#     post1 = Post.new(title: 'Idea Post 1', post_type: 'idea', user: @user)
#     post2 = Post.new(title: 'Idea Post 2', post_type: 'problem', user: @user)
#     post3 = Post.new(title: 'Idea Post 3', post_type: 'subject', user: @user)
#     post4 = Post.new(title: 'Idea Post 4', post_type: 'layer', user: @user)
#     post1.save
#     post2.save
#     post3.save
#     post4.save

#     posts = Post.idea_posts
#     assert_includes posts, post1
#     assert_not_includes posts, post2
#     assert_not_includes posts, post3
#     assert_not_includes posts, post4
#   end

#   test "checks if it's of a specific type" do
#     post1 = Post.new(title: 'Type Check Post 1', post_type: 'subject', user: @user)
#     post2 = Post.new(title: 'Type Check Post 2', post_type: 'problem', user: @user)
#     post3 = Post.new(title: 'Type Check Post 3', post_type: 'idea', user: @user)
#     post1.save
#     post2.save
#     post3.save

#     assert post1.type_of?('subject')
#     assert post2.type_of?('problem')
#     assert post3.type_of?('idea')
#   end

#   test 'sends a notification to posted_to user after create' do
#     posted_to_user = users(:two) # Replace with your user fixture or create a user instance
#     post = Post.new(title: 'Example Post', post_type: 'subject', user: @user, posted_to: posted_to_user)
#     assert_difference('Notification.count') do
#       post.save
#     end
#   end

#   test 'sends a notification on layer create' do
#     parent_post_user = users(:three) # Replace with your user fixture or create a user instance
#     parent_post = Post.new(title: 'Parent Post', post_type: 'layer', user: parent_post_user)
#     parent_post.save
#     post = Post.new(title: 'Layer Post', post_type: 'layer', user: @user, post_id: parent_post.id)
#     assert_difference('Notification.count') do
#       post.save
#     end
#   end

#   test 'sends a notification on layer create if parent_post tracking is enabled' do
#     parent_post_user = users(:three) # Replace with your user fixture or create a user instance
#     parent_post = Post.new(title: 'Parent Post', post_type: 'layer', user: parent_post_user)
#     parent_post.tracking_enabled = true
#     parent_post.save

#     post = Post.new(title: 'Layer Post', post_type: 'layer', user: @user, post_id: parent_post.id)
#     assert_difference('Notification.count') do
#       post.save
#     end
#   end

#   test 'cleans Froala link in content body' do
#     post = Post.new(title: 'Example Post', post_type: 'subject', user: @user)
#     post.content = ActionText::Content.new(body: "This is a Froala link. Powered by Froala Editor.")
#     post.clean_froala_link
#     assert_equal "This is a Froala link. ", post.content.body.to_s
#   end

#   test 'does not clean Froala link if it does not exist' do
#     post = Post.new(title: 'Example Post', post_type: 'subject', user: @user)
#     post.clean_froala_link
#     assert_nil post.content
#   end

#   test 'does not send notification on layer create if parent_post is disabled' do
#     parent_post_user = users(:three) # Replace with your user fixture or create a user instance
#     parent_post = Post.new(title: 'Parent Post', post_type: 'layer', user: parent_post_user)
#     parent_post.disabled = true
#     parent_post.save

#     post = Post.new(title: 'Layer Post', post_type: 'layer', user: @user, post_id: parent_post.id)
#     assert_no_difference('Notification.count') do
#       post.save
#     end
#   end

#   test 'requires title presence' do
#     post = Post.new(title: '', post_type: 'subject', user: @user)
#     assert_not post.valid?
#   end

#   test 'returns layer_posts' do
#     post1 = Post.new(title: 'Layer Post 1', post_type: 'layer', user: @user)
#     post2 = Post.new(title: 'Layer Post 2', post_type: 'subject', user: @user)
#     post3 = Post.new(title: 'Layer Post 3', post_type: 'problem', user: @user)
#     post4 = Post.new(title: 'Layer Post 4', post_type: 'idea', user: @user)
#     post1.save
#     post2.save
#     post3.save
#     post4.save

#     posts = Post.layer_posts
#     assert_includes posts, post1
#     assert_not_includes posts, post2
#     assert_not_includes posts, post3
#     assert_not_includes posts, post4
#   end

#   test 'returns geo_maxing_posts' do
#     post1 = Post.new(title: 'Geo Maxing Post 1', post_type: 'geomaxing', user: @user, lat: 12.345, long: 123.456)
#     post2 = Post.new(title: 'Geo Maxing Post 2', post_type: 'subject', user: @user)
#     post3 = Post.new(title: 'Geo Maxing Post 3', post_type: 'problem', user: @user)
#     post4 = Post.new(title: 'Geo Maxing Post 4', post_type: 'idea', user: @user)
#     post1.save
#     post2.save
#     post3.save
#     post4.save

#     posts = Post.geo_maxing_posts
#     assert_includes posts, post1
#     assert_not_includes posts, post2
#     assert_not_includes posts, post3
#     assert_not_includes posts, post4
#   end

#   test 'sends a notification on layer create if parent_post tracking is enabled' do
#     parent_post_user = users(:three) # Replace with your user fixture or create a user instance
#     parent_post = Post.new(title: 'Parent Post', post_type: 'layer', user: parent_post_user)
#     parent_post.tracking_enabled = true
#     parent_post.save

#     post = Post.new(title: 'Layer Post', post_type: 'layer', user: @user, post_id: parent_post.id)
#     assert_difference('Notification.count') do
#       post.save
#     end
#   end

#   test 'cleans Froala link in content body' do
#     post = Post.new(title: 'Example Post', post_type: 'subject', user: @user)
#     post.content = ActionText::Content.new(body: "This is a Froala link. Powered by Froala Editor.")
#     post.clean_froala_link
#     assert_equal "This is a Froala link. ", post.content.body.to_s
#   end

#   test 'does not clean Froala link if it does not exist' do
#     post = Post.new(title: 'Example Post', post_type: 'subject', user: @user)
#     post.clean_froala_link
#     assert_nil post.content
#   end

#   test 'does not send notification on layer create if parent_post is disabled' do
#     parent_post_user = users(:three) # Replace with your user fixture or create a user instance
#     parent_post = Post.new(title: 'Parent Post', post_type: 'layer', user: parent_post_user)
#     parent_post.disabled = true
#     parent_post.save

#     post = Post.new(title: 'Layer Post', post_type: 'layer', user: @user, post_id: parent_post.id)
#     assert_no_difference('Notification.count') do
#       post.save
#     end
#   end

#   test 'requires title presence' do
#     post = Post.new(title: '', post_type: 'subject', user: @user)
#     assert_not post.valid?
#   end

#   test 'returns layer_posts' do
#     post1 = Post.new(title: 'Layer Post 1', post_type: 'layer', user: @user)
#     post2 = Post.new(title: 'Layer Post 2', post_type: 'subject', user: @user)
#     post3 = Post.new(title: 'Layer Post 3', post_type: 'problem', user: @user)
#     post4 = Post.new(title: 'Layer Post 4', post_type: 'idea', user: @user)
#     post1.save
#     post2.save
#     post3.save
#     post4.save

#     posts = Post.layer_posts
#     assert_includes posts, post1
#     assert_not_includes posts, post2
#     assert_not_includes posts, post3
#     assert_not_includes posts, post4
#   end

#   test 'returns geo_maxing_posts' do
#     post1 = Post.new(title: 'Geo Maxing Post 1', post_type: 'geomaxing', user: @user, lat: 12.345, long: 123.456)
#     post2 = Post.new(title: 'Geo Maxing Post 2', post_type: 'subject', user: @user)
#     post3 = Post.new(title: 'Geo Maxing Post 3', post_type: 'problem', user: @user)
#     post4 = Post.new(title: 'Geo Maxing Post 4', post_type: 'idea', user: @user)
#     post1.save
#     post2.save
#     post3.save
#     post4.save

#     posts = Post.geo_maxing_posts
#     assert_includes posts, post1
#     assert_not_includes posts, post2
#     assert_not_includes posts, post3
#     assert_not_includes posts, post4
#   end

#   test 'requires title presence' do
#     post = Post.new(title: '', post_type: 'subject', user: @user)
#     assert_not post.valid?
#   end

#   test 'requires a valid post_type' do
#     post = Post.new(title: 'Example Post', post_type: 'invalid_type', user: @user)
#     assert_not post.valid?
#   end

#   test 'requires subject_id for POST_TYPE_PROBLEM' do
#     post = Post.new(title: 'Example Post', post_type: 'problem', user: @user)
#     assert_not post.valid?
#   end

#   test 'requires problem_id for POST_TYPE_IDEA' do
#     post = Post.new(title: 'Example Post', post_type: 'idea', user: @user)
#     assert_not post.valid?
#   end

#   test 'requires lat for geo_maxing posts' do
#     post = Post.new(title: 'Example Post', post_type: 'geomaxing', user: @user, lat: nil, long: 123.456)
#     assert_not post.valid?
#   end

#   test 'requires long for geo_maxing posts' do
#     post = Post.new(title: 'Example Post', post_type: 'geomaxing', user: @user, lat: 12.345, long: nil)
#     assert_not post.valid?
#   end

#   test 'requires post_id for post_type layer' do
#     post = Post.new(title: 'Example Post', post_type: 'layer', user: @user)
#     assert_not post.valid?
#   end

#   test 'cleans Froala link in content body' do
#     post = Post.new(title: 'Example Post', post_type: 'subject', user: @user)
#     post.content = ActionText::Content.new(body: "This is a Froala link. Powered by Froala Editor.")
#     post.clean_froala_link
#     assert_equal "This is a Froala link. ", post.content.body.to_s
#   end

#   test 'does not clean Froala link if it does not exist' do
#     post = Post.new(title: 'Example Post', post_type: 'subject', user: @user)
#     post.clean_froala_link
#     assert_nil post.content
#   end

#   test 'requires title presence' do
#     post = Post.new(title: '', post_type: 'subject', user: @user)
#     assert_not post.valid?
#   end

#   test 'does not send notification on non-layer create' do
#     post = Post.new(title: 'Example Post', post_type: 'subject', user: @user)
#     assert_no_difference('Notification.count') do
#       post.save
#     end
#   end

#   test 'does not send notification on layer create if parent_post tracking is disabled' do
#     parent_post_user = users(:three) # Replace with your user fixture or create a user instance
#     parent_post = Post.new(title: 'Parent Post', post_type: 'layer', user: parent_post_user)
#     parent_post.tracking_enabled = false
#     parent_post.save

#     post = Post.new(title: 'Layer Post', post_type: 'layer', user: @user, post_id: parent_post.id)
#     assert_no_difference('Notification.count') do
#       post.save
#     end
#   end

#   test 'sends a notification on layer create if parent_post tracking is enabled' do
#     parent_post_user = users(:three) # Replace with your user fixture or create a user instance
#     parent_post = Post.new(title: 'Parent Post', post_type: 'layer', user: parent_post_user)
#     parent_post.tracking_enabled = true
#     parent_post.save

#     post = Post.new(title: 'Layer Post', post_type: 'layer', user: @user, post_id: parent_post.id)
#     assert_difference('Notification.count') do
#       post.save
#     end
#   end

#   test 'does not send notification on layer create if parent_post is disabled' do
#     parent_post_user = users(:three) # Replace with your user fixture or create a user instance
#     parent_post = Post.new(title: 'Parent Post', post_type: 'layer', user: parent_post_user)
#     parent_post.disabled = true
#     parent_post.save

#     post = Post.new(title: 'Layer Post', post_type: 'layer', user: @user, post_id: parent_post.id)
#     assert_no_difference('Notification.count') do
#       post.save
#     end
#   end

#   test 'requires title presence' do
#     post = Post.new(title: '', post_type: 'subject', user: @user)
#     assert_not post.valid?
#   end

#   test 'requires a valid post_type' do
#     post = Post.new(title: 'Example Post', post_type: 'invalid_type', user: @user)
#     assert_not post.valid?
#   end

#   test 'requires subject_id for POST_TYPE_PROBLEM' do
#     post = Post.new(title: 'Example Post', post_type: 'problem', user: @user)
#     assert_not post.valid?
#   end

#   test 'requires problem_id for POST_TYPE_IDEA' do
#     post = Post.new(title: 'Example Post', post_type: 'idea', user: @user)
#     assert_not post.valid?
#   end

#   test 'requires lat for geo_maxing posts' do
#     post = Post.new(title: 'Example Post', post_type: 'geomaxing', user: @user, lat: nil, long: 123.456)
#     assert_not post.valid?
#   end

#   test 'requires long for geo_maxing posts' do
#     post = Post.new(title: 'Example Post', post_type: 'geomaxing', user: @user, lat: 12.345, long: nil)
#     assert_not post.valid?
#   end

#   test 'requires post_id for post_type layer' do
#     post = Post.new(title: 'Example Post', post_type: 'layer', user: @user)
#     assert_not post.valid?
#   end

#   test 'returns layer_posts' do
#     post1 = Post.new(title: 'Layer Post 1', post_type: 'layer', user: @user)
#     post2 = Post.new(title: 'Layer Post 2', post_type: 'subject', user: @user)
#     post3 = Post.new(title: 'Layer Post 3', post_type: 'problem', user: @user)
#     post4 = Post.new(title: 'Layer Post 4', post_type: 'idea', user: @user)
#     post1.save
#     post2.save
#     post3.save
#     post4.save

#     posts = Post.layer_posts
#     assert_includes posts, post1
#     assert_not_includes posts, post2
#     assert_not_includes posts, post3
#     assert_not_includes posts, post4
#   end

#   test 'returns geo_maxing_posts' do
#     post1 = Post.new(title: 'Geo Maxing Post 1', post_type: 'geomaxing', user: @user, lat: 12.345, long: 123.456)
#     post2 = Post.new(title: 'Geo Maxing Post 2', post_type: 'subject', user: @user)
#     post3 = Post.new(title: 'Geo Maxing Post 3', post_type: 'problem', user: @user)
#     post4 = Post.new(title: 'Geo Maxing Post 4', post_type: 'idea', user: @user)
#     post1.save
#     post2.save
#     post3.save
#     post4.save

#     posts = Post.geo_maxing_posts
#     assert_includes posts, post1
#     assert_not_includes posts, post2
#     assert_not_includes posts, post3
#     assert_not_includes posts, post4
#   end

#   test 'cleans Froala link in content body' do
#     post = Post.new(title: 'Example Post', post_type: 'subject', user: @user)
#     post.content = ActionText::Content.new(body: "This is a Froala link. Powered by Froala Editor.")
#     post.clean_froala_link
#     assert_equal "This is a Froala link. ", post.content.body.to_s
#   end

#   test 'does not clean Froala link if it does not exist' do
#     post = Post.new(title: 'Example Post', post_type: 'subject', user: @user)
#     post.clean_froala_link
#     assert_nil post.content
#   end

#   test 'requires title presence' do
#     post = Post.new(title: '', post_type: 'subject', user: @user)
#     assert_not post.valid?
#   end

#   test 'requires a valid post_type' do
#     post = Post.new(title: 'Example Post', post_type: 'invalid_type', user: @user)
#     assert_not post.valid?
#   end

#   test 'requires subject_id for POST_TYPE_PROBLEM' do
#     post = Post.new(title: 'Example Post', post_type: 'problem', user: @user)
#     assert_not post.valid?
#   end

#   test 'requires problem_id for POST_TYPE_IDEA' do
#     post = Post.new(title: 'Example Post', post_type: 'idea', user: @user)
#     assert_not post.valid?
#   end

#   test 'requires lat for geo_maxing posts' do
#     post = Post.new(title: 'Example Post', post_type: 'geomaxing', user: @user, lat: nil, long: 123.456)
#     assert_not post.valid?
#   end

#   test 'requires long for geo_maxing posts' do
#     post = Post.new(title: 'Example Post', post_type: 'geomaxing', user: @user, lat: 12.345, long: nil)
#     assert_not post.valid?
#   end

#   test 'requires post_id for post_type layer' do
#     post = Post.new(title: 'Example Post', post_type: 'layer', user: @user)
#     assert_not post.valid?
#   end

#   test 'returns layer_posts' do
#     post1 = Post.new(title: 'Layer Post 1', post_type: 'layer', user: @user)
#     post2 = Post.new(title: 'Layer Post 2', post_type: 'subject', user: @user)
#     post3 = Post.new(title: 'Layer Post 3', post_type: 'problem', user: @user)
#     post4 = Post.new(title: 'Layer Post 4', post_type: 'idea', user: @user)
#     post1.save
#     post2.save
#     post3.save
#     post4.save

#     posts = Post.layer_posts
#     assert_includes posts, post1
#     assert_not_includes posts, post2
#     assert_not_includes posts, post3
#     assert_not_includes posts, post4
#   end

#   test 'returns geo_maxing_posts' do
#     post1 = Post.new(title: 'Geo Maxing Post 1', post_type: 'geomaxing', user: @user, lat: 12.345, long: 123.456)
#     post2 = Post.new(title: 'Geo Maxing Post 2', post_type: 'subject', user: @user)
#     post3 = Post.new(title: 'Geo Maxing Post 3', post_type: 'problem', user: @user)
#     post4 = Post.new(title: 'Geo Maxing Post 4', post_type: 'idea', user: @user)
#     post1.save
#     post2.save
#     post3.save
#     post4.save

#     posts = Post.geo_maxing_posts
#     assert_includes posts, post1
#     assert_not_includes posts, post2
#     assert_not_includes posts, post3
#     assert_not_includes posts, post4
#   end

#   test 'cleans Froala link in content body' do
#     post = Post.new(title: 'Example Post', post_type: 'subject', user: @user)
#     post.content = ActionText::Content.new(body: "This is a Froala link. Powered by Froala Editor.")
#     post.clean_froala_link
#     assert_equal "This is a Froala link. ", post.content.body.to_s
#   end

#   test 'does not clean Froala link if it does not exist' do
#     post = Post.new(title: 'Example Post', post_type: 'subject', user: @user)
#     post.clean_froala_link
#     assert_nil post.content
#   end

#   test 'checks if post type is in POST_TYPES' do
#     post = Post.new(title: 'Example Post', post_type: 'subject', user: @user)
#     assert post.type_of?('subject')
#   end

#   test 'checks if post type is not in POST_TYPES' do
#     post = Post.new(title: 'Example Post', post_type: 'invalid_type', user: @user)
#     assert_not post.type_of?('subject')
#   end

# end
