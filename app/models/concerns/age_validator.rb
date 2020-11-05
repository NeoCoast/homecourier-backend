# frozen_string_literal: true

# Age validator
class AgeValidator < ActiveModel::Validator
  def validate(record)
    record.errors.add(:birth_date, 'User must have 18 years old.') unless adult(record.birth_date)
  end

  private

  def adult(date)
    return true if date.nil?

    date_of_birth = Date.strptime(date, '%d/%m/%Y')

    return true if Date.today.year - date_of_birth.year > 18
    return false if Date.today.year - date_of_birth.year < 18

    return false if Date.today.month < date_of_birth.month
    return true if Date.today.month > date_of_birth.month

    Date.today.day >= date_of_birth.day if Date.today.month == date_of_birth.month
  end
end
