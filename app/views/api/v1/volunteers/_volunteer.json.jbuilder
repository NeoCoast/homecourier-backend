# frozen_string_literal: true

json.id volunteer.id
json.email volunteer.email
json.username volunteer.username
json.name volunteer.name
json.lastname volunteer.lastname
json.birth_date volunteer.birth_date
json.address volunteer.address
json.document_number volunteer.document_number
json.document_type_id volunteer.document_type_id
json.avatar url_for(volunteer.avatar) if volunteer.avatar.attached?
json.document_face_pic url_for(volunteer.document_face_pic) if volunteer.document_face_pic.attached?
json.document_back_pic url_for(volunteer.document_back_pic) if volunteer.document_back_pic.attached?
