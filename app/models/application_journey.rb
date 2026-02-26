class ApplicationJourney < ApplicationRecord
  enum :application_road, {
    married: 1,
    long_term: 2,
    work: 3,
    highly1a: 4,
    highly1b: 5,
    highly2a: 6,
    highly2b: 7,
    special1: 8,
    special2: 9
  }
  validates :application_road, presence: true

  SYSTEM_PROMPT = ""
  DESCRIPTION = {
    married: "1 Those who are the spouse of a
    Japanese national, spouse of a permanent resident, spouse of a special
    permanent resident, or their biological child, etc.".squish,
    long_term: "2 Those who have a “long-term resident” status",
    work: "3 Those who have a work-related residence status
    (such as “Engineer/Specialist in Humanities/International Services”
    or “Skilled Work”) or “Dependent” residence status".squish,
    highly1a: "4-(1)-ア Those who have been granted permission to stay in Japan as a
    “highly skilled foreign professional” with a status of residence of
    “highly skilled professional” or “designated activities” and who have 80 or more points.".squish,
    highly1b: "4-(1)-イ Those who have 80 points or more when calculating points one year prior to
    applying for permanent residence permission and who are residing in Japan with permission for
    a status of residence other than 4-(1)-ア.".squish,
    highly2a: "4-(2)-ア Those who have been granted permission to stay in Japan as a
    “highly skilled foreign professional” with a status of residence of
    “highly skilled professional” or “designated activities” and who have 70 or more points.".squish,
    highly2b: "4-(2)-イ Those who have 70 points or more when calculating points
    three years prior to applying for permanent residence and who are residing
    in Japan with a status of residence other than 4-(2)-ア.".squish,
    special1: "5-(1) Those applying as a “specially highly skilled foreign professional”
    who have been confirmed to meet the criteria for it",
    special2: "5-(2) Those applying as a “specially highly skilled foreign professional”
    who have not been confirmed as meeting the criteria for it".squish
  }

  URL = {
    overview: "https://www.moj.go.jp/isa/applications/procedures/16-4.html",
    married: "https://www.moj.go.jp/isa/applications/procedures/zairyu_eijyu01.html",
    long_term: "https://www.moj.go.jp/isa/applications/procedures/zairyu_eijyu02.html",
    work: "https://www.moj.go.jp/isa/applications/procedures/zairyu_eijyu03.html",
    highly1a: "https://www.moj.go.jp/isa/applications/procedures/nyuukokukanri07_00130.html",
    highly1b: "https://www.moj.go.jp/isa/applications/procedures/nyuukokukanri07_00132.html",
    highly2a: "https://www.moj.go.jp/isa/applications/procedures/nyuukokukanri07_00133.html",
    highly2b: "https://www.moj.go.jp/isa/applications/procedures/nyuukokukanri07_00134.html",
    special1: "https://www.moj.go.jp/isa/10_00227.html",
    special2: "https://www.moj.go.jp/isa/10_00228.html"
  }
end
