class Client < ApplicationRecord
  has_many :buildings, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
