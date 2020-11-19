# frozen_string_literal: true

json.username user.username
json.name user.name
json.lastname user.lastname
json.avatar url_for(user.avatar) if user.avatar.attached?
json.rating VolunteerRating.where(qualified_id: user.id).average(:score) if user.type == 'Helpee'
json.orders_completed VolunteerRating.where(qualified_id: user.id).count if user.type == 'Helpee'
json.rating HelpeeRating.where(qualified_id: user.id).average(:score) if user.type == 'Volunteer'
json.orders_completed HelpeeRating.where(qualified_id: user.id).count if user.type == 'Volunteer'
