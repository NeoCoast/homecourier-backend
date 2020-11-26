# frozen_string_literal: true

json.pendings @pendings do |pending|
  json.order_id pending.id
  json.user_id pending.helpee.id
  json.user_name pending.helpee.name + ' ' + pending.helpee.lastname
end
