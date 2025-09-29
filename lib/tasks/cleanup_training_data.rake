# lib/tasks/cleanup_training_data.rake
namespace :posts do
  desc 'Destroy ONLY posts with tag "TrainingData" (no descendants)'
  task destroy_training_data: :environment do
    tag_name = 'TrainingData'
    posts = Post.tagged_with(tag_name)

    if posts.empty?
      puts 'No posts found. Nothing to do.'
      next
    end

    puts "Found #{posts.count} posts tagged with \"#{tag_name}\""

    if ENV['DRY_RUN']
      puts "DRY RUN: Would delete #{posts.count} posts"
      posts.each { |p| puts "[DRY] id=#{p.id} title=#{p.title.inspect}" }
      next
    end

    puts "WARNING: This will delete #{posts.count} posts permanently!"
    print 'Continue? (y/N): '
    answer = STDIN.gets.chomp.downcase
    next unless answer == 'y'

    deleted_count = 0

    posts.find_each do |post|
      begin
        UserCuratedPost.where(post_id: post.id).delete_all
        UserPrivatePost.where(post_id: post.id).delete_all
        ActsAsTaggableOn::Tagging.where(taggable_id: post.id, taggable_type: 'Post').delete_all
        PostVersion.where(post_id: post.id).delete_all

        # Now delete the post directly
        Post.where(id: post.id).delete_all

        deleted_count += 1
        puts "Deleted post id=#{post.id}"
      rescue => e
        puts "Error deleting post #{post.id}: #{e.message}"
      end
    end


    puts "Successfully deleted #{deleted_count} posts."
  end
end
