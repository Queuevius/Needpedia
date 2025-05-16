module ActivityPub
  class DeliveryJob < ApplicationJob
    queue_as :default

    def perform(post)
      return unless post.should_federate?
      
      # Send the post to all followers
      ActivityPub::RequestService.new(post.user).send_create_note(post)
    end
  end
end