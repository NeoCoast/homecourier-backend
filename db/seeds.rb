require 'csv'

# to run use rake db:seed

# DOCUMENT TYPES

ci_doc_type = DocumentType.new
ci_doc_type.description = 'CI'
ci_doc_type.save!
puts ci_doc_type

# CATEGORIES

categories = Hash.new

csv_categories_file = File.read(Rails.root.join('lib', 'seeds', 'category.csv'))
csv_categories = CSV.parse(csv_categories_file, :headers => true, :encoding => 'ISO-8859-1')
csv_categories.each do |category_row|
  category = Category.new
  category.description = category_row["description"]
  categories[category_row["description"]] = category
  category.save!
  puts category
end

# VOLUNTEERS

volunteer_list = []

csv_volunteer_file = File.read(Rails.root.join('lib', 'seeds', 'volunteer.csv'))
csv_volunteer = CSV.parse(csv_volunteer_file, :headers => true, :encoding => 'ISO-8859-1')
csv_volunteer.each do |volunteer_row|
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
  puts volunteer
end

# HELPEES

helpee_list = []

csv_helpee_file = File.read(Rails.root.join('lib', 'seeds', 'helpee.csv'))
csv_helpee = CSV.parse(csv_helpee_file, :headers => true, :encoding => 'ISO-8859-1')
csv_helpee.each do |helpee_row|
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
  puts helpee
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
  puts order
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
  puts order_request
end
