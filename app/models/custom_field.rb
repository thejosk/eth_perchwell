class CustomField < ApplicationRecord
  belongs_to :client
  has_many :custom_field_values, dependent: :destroy

  VALID_TYPES = %w[number freeform enum].freeze

  validates :name, presence: true
  validates :field_type, presence: true, inclusion: { in: VALID_TYPES }
  validates :name, uniqueness: { scope: :client_id, case_sensitive: false }
  validate :enum_options_present_for_enum_type

  before_validation :normalize_name

  serialize :enum_options, coder: JSON

  def valid_value?(value)
    return true if value.blank?

    case field_type
    when 'number'
      Float(value) rescue return false
      true
    when 'freeform'
      true
    when 'enum'
      enum_options.map(&:downcase).include?(value.to_s.downcase)
    else
      false
    end
  end

  def validation_error(value)
    case field_type
    when 'number'
      "must be a number"
    when 'enum'
      "must be one of: #{enum_options.join(', ')}"
    else
      "invalid value"
    end
  end

  private

  def normalize_name
    # e.g. "Brick Color" => "brick_color"
    self.name = name.to_s.parameterize(separator: '_') if name.present?
  end

  def enum_options_present_for_enum_type
    if field_type == 'enum' && (enum_options.blank? || !enum_options.is_a?(Array) || enum_options.empty?)
      errors.add(:enum_options, "must be present for enum type fields")
    end
  end
end
