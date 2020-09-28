# frozen_string_literal: true

json.id order.id
json.title order.title
json.description order.description
json.status order.status

json.categories order.categories do |category|
    json.(category, :description)
end

json.created_at order.created_at
json.updated_at order.updated_at
