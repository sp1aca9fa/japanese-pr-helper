class Chat < ApplicationRecord
  belongs_to :user_application
  has_many :messages, dependent: :destroy
end
