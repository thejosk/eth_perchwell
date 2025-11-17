require 'rails_helper'

RSpec.describe CustomField, type: :model do
  subject { build(:custom_field) }

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:field_type) }
    it { should validate_inclusion_of(:field_type).in_array(%w[number freeform enum]) }
    it { should validate_uniqueness_of(:name).scoped_to(:client_id).case_insensitive }

    context 'when field_type is enum' do
      it 'requires enum_options' do
        field = build(:custom_field, field_type: 'enum', enum_options: nil)
        expect(field).not_to be_valid
        expect(field.errors[:enum_options]).to include("must be present for enum type fields")
      end

      it 'is valid with enum_options' do
        field = build(:custom_field, :enum)
        expect(field).to be_valid
      end
    end

    context 'name normalization' do
      it 'converts name to lowercase' do
        field = create(:custom_field, name: 'Building_Size')
        expect(field.name).to eq('building_size')
      end

      it 'strips whitespace from name' do
        field = create(:custom_field, name: '  test_field  ')
        expect(field.name).to eq('test_field')
      end

      it 'converts spaces to underscores' do
        field = create(:custom_field, name: 'Brick Color')
        expect(field.name).to eq('brick_color')
      end

      it 'handles multiple spaces' do
        field = create(:custom_field, name: 'Building   Floor   Count')
        expect(field.name).to eq('building_floor_count')
      end

      it 'prevents duplicate names per client(case-insensitive)' do
        client = create(:client)
        create(:custom_field, name: 'building_size', client: client)
        duplicate = build(:custom_field, name: 'Building_Size', client: client)
        expect(duplicate).not_to be_valid
      end

      it 'allows same name for different clients' do
        client1 = create(:client)
        client2 = create(:client)
        create(:custom_field, name: 'building_size', client: client1)
        field2 = build(:custom_field, name: 'building_size', client: client2)
        expect(field2).to be_valid
      end
    end
  end

  describe 'associations' do
    it { should belong_to(:client) }
    it { should have_many(:custom_field_values).dependent(:destroy) }
  end

  describe '#valid_value?' do
    context 'number field' do
      let(:field) { create(:custom_field, :number) }

      it 'accepts valid numbers' do
        expect(field.valid_value?("123")).to be true
        expect(field.valid_value?("123.45")).to be true
        expect(field.valid_value?("-10")).to be true
      end

      it 'rejects non-numeric values' do
        expect(field.valid_value?("abc")).to be false
        expect(field.valid_value?("12abc")).to be false
      end

      it 'accepts blank values' do
        expect(field.valid_value?("")).to be true
        expect(field.valid_value?(nil)).to be true
      end
    end

    context 'freeform field' do
      let(:field) { create(:custom_field, field_type: "freeform") }

      it 'accepts any string' do
        expect(field.valid_value?("any text")).to be true
        expect(field.valid_value?("123")).to be true
      end
    end

    context 'enum field' do
      let(:field) { create(:custom_field, :enum) }

      it 'accepts valid enum values' do
        expect(field.valid_value?("Option 1")).to be true
        expect(field.valid_value?("Option 2")).to be true
      end

      it 'accepts enum values(case-insensitive)' do
        expect(field.valid_value?("option 1")).to be true
        expect(field.valid_value?("OPTION 2")).to be true
        expect(field.valid_value?("OpTiOn 3")).to be true
      end

      it 'rejects invalid enum values' do
        expect(field.valid_value?("Invalid")).to be false
      end

      it 'accepts blank values' do
        expect(field.valid_value?("")).to be true
      end
    end
  end
end
