namespace :post do
  desc "Rename post_type for area"
  task change_area_post_type: :environment do
    Post.where(post_type: 'area').update_all(post_type: 'subject')
  end
end
