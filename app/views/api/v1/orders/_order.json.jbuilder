# frozen_string_literal: true

json.id order.id
json.title order.title
json.description order.description
json.status order.status
json.created_at order.created_at
json.updated_at order.updated_at

#json.categories order.categories do |category|
    #json.partial! 'api/v1/categories/category', category: category
#end