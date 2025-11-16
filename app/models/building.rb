class Building < ApplicationRecord
  belongs_to :client

  validates :street, presence: true
  validates :client, presence: true
end
