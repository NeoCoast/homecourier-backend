# frozen_string_literal: true

json.user_id @user_id
json.page @page
json.page_size @page_size
json.ratings do
  json.array! @ratings, partial: 'api/v1/users/rating', as: :rating
end
