# frozen_string_literal: true

json.id helpee.id
json.email helpee.email
json.username helpee.username
json.name helpee.name
json.lastname helpee.lastname
json.birth_date helpee.birth_date
json.address helpee.address
json.avatar url_for(helpee.avatar) if helpee.avatar.attached?
