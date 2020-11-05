class LongitudeValidator < ActiveModel::Validator
  def validate(record)
    record.errors.add(:address, 'Invalid address') if record.longitude.nil?
  end
end
