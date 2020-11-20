# frozen_string_literal: true

json.id user.id
json.email user.email
json.username user.username
json.name user.name
json.lastname user.lastname
json.birth_date user.birth_date
json.address user.address
json.avatar url_for(user.avatar) if user.avatar.attached?
json.latitude user.latitude
json.longitude user.longitude
json.orders_completed VolunteerRating.where(qualified_id: user.id).count if user.type == 'Helpee'
json.orders_completed HelpeeRating.where(qualified_id: user.id).count if user.type == 'Volunteer'
json.phone_number user.phone_number
