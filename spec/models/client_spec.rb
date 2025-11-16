require 'rails_helper'

RSpec.describe Client, type: :model do
  subject { build(:client) }

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe 'associations' do
    it { should have_many(:buildings).dependent(:destroy) }
  end
end
