# frozen_string_literal: true

# Phone validator
class PhoneValidator < ActiveModel::Validator
  def validate(record)
    record.errors.add(:phone_number, 'The phone must be in a valid format.') if record.phone_number !~ /\A09\d{7}\z/
  end
end
