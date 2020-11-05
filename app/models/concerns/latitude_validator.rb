class LatitudeValidator < ActiveModel::Validator
  def validate(record)
    record.errors.add(:address, 'Invalid address') if record.latitude.nil?
  end
end
