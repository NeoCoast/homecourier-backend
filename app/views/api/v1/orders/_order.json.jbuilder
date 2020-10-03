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
end

json.categories order.categories do |category|
    json.(category, :description)
end

json.created_at order.created_at
json.updated_at order.updated_at
