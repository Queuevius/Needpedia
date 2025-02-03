class ChatThread < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :guest, optional: true
end
