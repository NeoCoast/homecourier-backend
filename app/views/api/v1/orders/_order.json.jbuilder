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
  json.phone_number order.helpee.phone_number unless order.created?
  json.email order.helpee.email if order.accepted? || order.in_process? || order.finished?
  json.address order.helpee.address if order.accepted? || order.in_process? || order.finished?
  json.longitude order.helpee.longitude if order.accepted? || order.in_process? || order.finished?
  json.longitude order.helpee.offsetlongitude if order.created? || order.cancelled?
  json.latitude order.helpee.latitude if order.accepted? || order.in_process? || order.finished?
  json.latitude order.helpee.offsetlatitude if order.created? || order.cancelled?
  unless @user_coordinates.nil?
    json.distance Geocoder::Calculations.distance_between(
      @user_coordinates, [order.helpee.latitude, order.helpee.longitude]
    )
  end
  json.avatar url_for(order.helpee.avatar) if order.helpee.avatar.attached?
  json.rating VolunteerRating.where(qualified_id: order.helpee.id).average(:score)
end

json.categories order.categories do |category|
  json.call(category, :description)
end

json.created_at order.created_at
json.updated_at order.updated_at

json.volunteers order.volunteers do |volunteer|
  json.call(volunteer, :id, :email, :username, :name, :lastname)
  json.phone_number volunteer.phone_number unless order.created?
  json.avatar url_for(volunteer.avatar) if volunteer.avatar.attached?
  json.rating HelpeeRating.where(qualified_id: volunteer.id).average(:score)
end
