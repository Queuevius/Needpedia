class EmailTemplate < ApplicationRecord
  has_rich_text :message
end
