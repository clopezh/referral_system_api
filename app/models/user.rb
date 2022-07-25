class User < ApplicationRecord
  has_many :permissions
  has_many :referrals
  has_many :positions_referrals_histories
  belongs_to :role

  validates :name, presence: true
  validates :email,
            presence: true,
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "Invalid e-mail address" },
            uniqueness: { case_sensitive: false },
            length: { minimum: 8, maximum: 254 }
end
