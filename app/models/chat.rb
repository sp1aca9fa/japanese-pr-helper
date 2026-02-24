class Chat < ApplicationRecord
  belongs_to :user_application
  has_many :messages, dependent: :destroy

  validates :title, presence: true, uniqueness: { scope: :user_application }
  validates :done, presence: true
end
