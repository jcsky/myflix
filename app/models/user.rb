class User < ActiveRecord::Base
  has_secure_password
  has_many :queue_items

  validates_presence_of :email, :password, :username
  validates_uniqueness_of :email
end