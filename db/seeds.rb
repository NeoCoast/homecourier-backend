require 'csv'

# to run use rake db:seed

HELPEE_COUNT = 10
VOLUNTEER_COUNT = 10

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
  if index < VOLUNTEER_COUNT
    volunteer = Volunteer.new
    volunteer.email = volunteer_row['email']
    volunteer.password = volunteer_row['password']
    volunteer.username = volunteer_row['username']
    volunteer.name = volunteer_row['name']
    volunteer.lastname = volunteer_row['lastname']
    volunteer.birth_date = volunteer_row['birth_date']
    volunteer.address = volunteer_row['address']
    volunteer.document_number = volunteer_row['document_number']
    volunteer.document_type_id = '1'
    volunteer_list << volunteer
    volunteer.save!
    puts "created volunteer " + volunteer.name + " " + volunteer.lastname
  end
end

# HELPEES

helpee_list = []

csv_helpee_file = File.read(Rails.root.join('lib', 'seeds', 'helpee.csv'))
csv_helpee = CSV.parse(csv_helpee_file, :headers => true, :encoding => 'ISO-8859-1')
csv_helpee.each_with_index do |helpee_row, index|
  if index < HELPEE_COUNT
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
  puts "created order request " + order_request.volunteer.username + " -> " + order_request.order.title
end

# NOTIFICATIONS

csv = File.read(Rails.root.join('lib', 'seeds', 'notification.csv'))
notifications = CSV.parse(csv, :headers => true, :encoding => 'ISO-8859-1')
notifications.each_with_index do |notification_row, index|
  notification = Notification.new
  notification.title = notification_row['title']
  notification.body = notification_row['body']
  notification.status = notification_row['status'].to_i
  notification.user = helpee_list[notification_row['user'].to_i]
  notification.save!
  print "saving notifications " + (index + 1).to_s + "/" + notifications.length.to_s + "\r"
end
puts
