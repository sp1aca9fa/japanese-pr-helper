class UserApplication < ApplicationRecord
  belongs_to :user
  belongs_to :application_journey
end
