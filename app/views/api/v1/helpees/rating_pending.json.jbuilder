if !@order.blank? and !@order_request.blank? and @rating.blank? then
    json.pending true
    json.order_id @order.id
    json.volunteer_id @order_request.volunteer.id
    json.score nil
    json.comment nil
    json.created_at nil 
    json.updated_at nil 
else
    json.pending false
    json.order_id nil
    json.score nil
    json.comment nil
    json.created_at nil
    json.updated_at nil 
end 
