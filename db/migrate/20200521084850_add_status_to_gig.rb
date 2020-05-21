class AddStatusToGig < ActiveRecord::Migration[6.0]
  def change
    add_column :gigs, :status, :string, default: Gig::GIG_STATUS_PENDING
  end
end
