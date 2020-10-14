if @rating.blank? 
    json.pending true
    json.order_id @order.id
    json.volunteer_id @order_request.volunteer.id
    json.score nil
    json.comment nil
    json.created_at nil 
    json.updated_at nil
else
    json.pending false
    json.order_id @rating.order_id
    json.score @rating.score
    json.comment @rating.comment
    json.created_at @rating.created_at
    json.updated_at @rating.updated_at
end

