class UserApplication < ApplicationRecord
  belongs_to :user
  belongs_to :application_journey
  has_many :chats

  # def set_title
  #   self.title = "My Journey" unless self.title
  # end
end
