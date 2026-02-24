class ApplicationJourney < ApplicationRecord
  enum :application_road, %i[married working long_term_resident]
end
