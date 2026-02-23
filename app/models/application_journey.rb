class ApplicationJourney < ApplicationRecord
  validates :application_road, inclusion: { in: (1..5).to_a }

  enum :application_road, %i[married working long_term_resident]
end
