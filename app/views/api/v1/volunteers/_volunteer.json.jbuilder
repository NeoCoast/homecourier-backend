# frozen_string_literal: true

json.partial! 'api/v1/users/user', user: volunteer

json.document_number volunteer.document_number
json.document_type_id volunteer.document_type_id
json.document_face_pic url_for(volunteer.document_face_pic) if volunteer.document_face_pic.attached?
json.document_back_pic url_for(volunteer.document_back_pic) if volunteer.document_back_pic.attached?
