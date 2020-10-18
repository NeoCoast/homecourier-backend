if !@order.blank? and @rating.blank? then 
    json.pending true
    json.order_id @order.id
    json.helpee_id @order.helpee.id
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
