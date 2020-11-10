require 'csv'

# to run use rake db:seed

VOLUNTEER_LIMIT = 100  # number of volunteers to create
HELPEE_LIMIT = 100     # number of helpees to create
rng = Random.new(333) # random seed

# DOCUMENT TYPES

ci_doc_type = DocumentType.new
ci_doc_type.description = 'CI'
ci_doc_type.save!
puts "created document type CI"

# CATEGORIES

categories = Hash.new

csv_categories_file = File.read(Rails.root.join('lib', 'seeds', 'category.csv'))
csv_categories = CSV.parse(csv_categories_file, :headers => true, :encoding => 'ISO-8859-1')
csv_categories.each do |category_row|
  category = Category.new
  category.description = category_row["description"]
  categories[category_row["description"]] = category
  category.save!
  puts "created category " + category.description
end

# VOLUNTEERS

volunteer_list = []

csv_volunteer_file = File.read(Rails.root.join('lib', 'seeds', 'volunteer.csv'))
csv_volunteer = CSV.parse(csv_volunteer_file, :headers => true, :encoding => 'ISO-8859-1')
csv_volunteer.each_with_index do |volunteer_row, index|
  if index < VOLUNTEER_LIMIT
    volunteer = Volunteer.new
    volunteer.email = volunteer_row['email']
    volunteer.password = volunteer_row['password']
    volunteer.username = volunteer_row['username']
    volunteer.name = volunteer_row['name']
    volunteer.lastname = volunteer_row['lastname']
    volunteer.birth_date = volunteer_row['birth_date']
    volunteer.address = volunteer_row['address']
    puts volunteer.address
    volunteer.document_number = volunteer_row['document_number']
    volunteer.document_type_id = '1'
    volunteer.save!
    volunteer_list << volunteer
    Volunteer.confirm_by_token(volunteer.confirmation_token)
    puts "created volunteer " + volunteer.name + " " + volunteer.lastname
  end
end

# HELPEES

helpee_list = []

csv_helpee_file = File.read(Rails.root.join('lib', 'seeds', 'helpee.csv'))
csv_helpee = CSV.parse(csv_helpee_file, :headers => true, :encoding => 'ISO-8859-1')
csv_helpee.each_with_index do |helpee_row, index|
  if index < HELPEE_LIMIT
    helpee = Helpee.new
    helpee.email = helpee_row['email']
    helpee.password = helpee_row['password']
    helpee.username = helpee_row['username']
    helpee.name = helpee_row['name']
    helpee.lastname = helpee_row['lastname']
    helpee.birth_date = helpee_row['birth_date']
    helpee.address = helpee_row['address']
    helpee.save!
    helpee_list << helpee
    Helpee.confirm_by_token(helpee.confirmation_token)
    puts "created helpee " + helpee.name + " " + helpee.lastname
  end
end

# ORDERS

order_list = []

csv_order_file = File.read(Rails.root.join('lib', 'seeds', 'order.csv'))
csv_order = CSV.parse(csv_order_file, :headers => true, :encoding => 'ISO-8859-1')
csv_order.each do |order_row|
  order = Order.new
  order.helpee = helpee_list[order_row['helpee_id'].to_i]
  order.title = order_row['title']
  order.description = order_row['description']
  order.status = order_row['status'].to_i
  order.categories = [categories[order_row['category']]]
  order_list << order
  order.save!

  # notifications for orders (helpee)
  status = order_row['status'].to_i
  case status
  when 2
      notification = Notification.new
      notification.title = "En proceso"
      notification.body = "Su pedido #{order.title} ya se encuentra en camino"
      notification.status = 0
      notification.user = order.helpee
      notification.save!
  when 4
    notification = Notification.new
      notification.title = "Cancelado"
      notification.body = "El pedido #{order.title} ha sido cancelado"
      notification.status = 0
      notification.user = order.helpee
      notification.save!
  end
  puts "created order " + order.title
end

# ORDER REQUESTS

csv_order_request_file = File.read(Rails.root.join('lib', 'seeds', 'order_request.csv'))
csv_order_request = CSV.parse(csv_order_request_file, :headers => true, :encoding => 'ISO-8859-1')
csv_order_request.each do |order_request_row|
  order_request = OrderRequest.new
  order_request.volunteer = volunteer_list[order_request_row['volunteer'].to_i]
  order_request.order = order_list[order_request_row['order'].to_i]
  order_request.order_request_status = order_request_row['status'].to_i
  order_request.save!

  # notifications for order (volunteer)
  status = order_request.order.status
  case status
  when 'accepted'
      notification = Notification.new
      notification.title = "Aceptado"
      notification.body = "El pedido #{order_request.order.title} ha sido aceptado"
      notification.status = 0
      notification.user = order_request.volunteer
      notification.save!
  when 'finished'
    notification = Notification.new
      notification.title = "Aceptado"
      notification.body = "El pedido #{order_request.order.title} ha sido aceptado"
      notification.status = 0
      notification.user = order_request.volunteer
      notification.save!
    notification = Notification.new
      notification.title = "Finalizado"
      notification.body = "El pedido #{order_request.order.title} ha sido finalizado"
      notification.status = 0
      notification.user = order_request.volunteer
      notification.save!
  when 'cancelled'
    notification = Notification.new
      notification.title = "Cancelado"
      notification.body = "El pedido #{order_request.order.title} ha sido cancelado"
      notification.status = 0
      notification.user = order_request.volunteer
      notification.save!
  end
  puts "created order request " + order_request.volunteer.username + " -> " + order_request.order.title
end

# NOTIFICATIONS
notification_users_emails = [
  'notificaciones1@gmail.com',
  'notificaciones2@gmail.com',
  'notificaciones3@gmail.com',
  'notificaciones4@gmail.com',
  'notificaciones5@gmail.com',
  'notificaciones6@gmail.com']
notifications_per_user = 400
notification_users_emails.each_with_index do |n_user, index_user|
  (1..notifications_per_user).each do |index|
    notification = Notification.new
    notification.title = 'Aceptado'
    notification.body = 'Su pedido pedido ' + index.to_s + ' ha sido aceptado'
    notification.status = 0
    notification.user = User.where(:email => n_user).first
    notification.save!
  end
  print "saving notifications for user " + (index_user + 1).to_s + "/" + notification_users_emails.length.to_s + "\r"
end
puts

# RATINGS

order_requests = OrderRequest.where(order_request_status: OrderRequest.order_request_statuses[:accepted]).to_a
order_requests.each_with_index do |ord_req, index|
  helpee_rating = HelpeeRating.new
  helpee_rating.order_id = ord_req.order.id
  helpee_rating.qualifier_id = ord_req.order.helpee.id
  helpee_rating.qualified_id = ord_req.volunteer.id
  helpee_rating.score = rng.rand(1..5)
  helpee_rating.comment = 'sample comment'
  helpee_rating.save!

  volunteer_rating = VolunteerRating.new
  volunteer_rating.order_id = ord_req.order.id
  volunteer_rating.qualifier_id = ord_req.volunteer.id
  volunteer_rating.qualified_id = ord_req.order.helpee.id
  volunteer_rating.score = rng.rand(1..5)
  volunteer_rating.comment ='sample comment'
  volunteer_rating.save!

  ord_req.order.updated_at = Time.now
  ord_req.order.save

  print "saving ratings " + (index + 1).to_s + "/" + order_requests.length.to_s + "\r"
end
puts
