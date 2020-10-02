# frozen_string_literal: true

json.array! @volunteers, partial: 'api/v1/volunteers/volunteer', as: :volunteer
