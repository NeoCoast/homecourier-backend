# frozen_string_literal: true

json.user_id @user_id
json.page @page
json.page_size @page_size
json.notifications do
  json.array! @notifications, partial: 'api/v1/notifications/notification', as: :notification
end
