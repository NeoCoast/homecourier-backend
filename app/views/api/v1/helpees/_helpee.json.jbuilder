# frozen_string_literal: true

json.partial! 'api/v1/users/user', user: helpee

json.rating VolunteerRating.where(qualified_id: helpee.id).average(:score)
