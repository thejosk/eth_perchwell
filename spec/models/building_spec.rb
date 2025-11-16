require 'rails_helper'

RSpec.describe Building, type: :model do
  subject { build(:building) }

  describe 'validations' do
    it { should validate_presence_of(:street) }
    it { should validate_presence_of(:client) }
  end

  describe 'associations' do
    it { should belong_to(:client) }
  end
end
