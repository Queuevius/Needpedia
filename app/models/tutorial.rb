class Tutorial < ApplicationRecord
  has_rich_text :content
  after_create :update_user_tutorials
  after_update :update_user_tutorials

  private

  def update_user_tutorials
    User.all.each do |user|
      # find or initialize a user_tutorial record for the current user and tutorial.
      user_tutorial = user.user_tutorials.find_or_initialize_by(link: link)
      user_tutorial.update(content: content, viewed: false)
    end
  end
end
