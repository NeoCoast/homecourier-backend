# frozen_string_literal: true

json.array! @helpees, partial: 'api/v1/helpees/helpee', as: :helpee
