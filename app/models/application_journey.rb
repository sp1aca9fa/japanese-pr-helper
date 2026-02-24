class ApplicationJourney < ApplicationRecord
  enum :application_road, %i[married long_term work highly special]

  validates :application_road, presence: true

  SYSTEM_PROMPT = ""
  DESCRIPTION = {
    married: "1 (if the applicant is a spouse of a
    Japanese national, a spouse of a permanent resident, a spouse of a special
    permanent resident, or their biological child, etc.)",
    long_term: "2 (if the applicant has a \"long-term resident\" status)",
    work: "3 (If the applicant has a work-related residence status
    (such as \"Engineer/Specialist in Humanities/International Services\"
    or \"Skilled Work\") or \"Dependent\" residence status)",
    highly: "4 (If the applicant applies for permanent residence as a
    \"highly skilled foreign professional\")",
    special: "5 (If the applicant applies for permanent residence as a
    \"specially highly skilled foreign professional\")"
  }
end
