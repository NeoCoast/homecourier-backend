# frozen_string_literal: true

json.pendings @pendings do |pending|
  json.order_id pending.id
  json.user_id pending.volunteers.first.id
  json.user_name pending.volunteers.first.name + ' ' + pending.volunteers.first.lastname
end
