class CountryLocation < ActiveRecord
  belongs_to :user
  belongs_to :country
  belongs_to :location
end
