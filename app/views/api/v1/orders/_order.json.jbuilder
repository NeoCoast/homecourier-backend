# frozen_string_literal: true

json.id order.id
json.title order.title
json.description order.description
json.status order.status

json.helpee do
  json.id order.helpee.id
  json.username order.helpee.username
  json.name order.helpee.name
  json.lastname order.helpee.lastname
  json.email order.helpee.email
  json.address order.helpee.address
  json.created_at order.helpee.created_at
  json.updated_at order.helpee.updated_at
  json.rating VolunteerRating.where(qualified_id: order.helpee.id).average(:score)
end

json.categories order.categories do |category|
  json.call(category, :description)
end

json.created_at order.created_at
json.updated_at order.updated_at

json.volunteers order.volunteers do |volunteer|
  json.call(volunteer, :id, :email, :created_at, :updated_at, :jti, :username, :name, :lastname, :birth_date, :address,
            :document_number, :document_type_id)
  json.rating HelpeeRating.where(qualified_id: volunteer.id).average(:score)
end
