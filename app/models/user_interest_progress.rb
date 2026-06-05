class UserInterestProgress < ApplicationRecord
  belongs_to :user
  belongs_to :interest
end
