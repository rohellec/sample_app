class User < ActiveRecord::Base
  attr_accessor :remember_token
  before_save { email.downcase! }

  validates :name,  presence: true,
                    length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX }

  has_secure_password

  validates :password, presence: true,
                       length: { minimum: 6 }

  def self.digest(token)
    cost = ActiveModel::SecurePassword ? BCrypt::Engine::MIN_COST
                                       : BCrypt::Engine.cost
    BCrypt::Password.create(token, cost: cost)
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end
end
