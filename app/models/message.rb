class Message < ApplicationRecord
  belongs_to :chat

  validates :role, presence: true
  validates :content, presence: true
  validates :role, inclusion: { in: %w[user assistant] }
end
