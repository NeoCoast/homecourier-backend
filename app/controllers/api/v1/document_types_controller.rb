# frozen_string_literal: true

class Api::V1::DocumentTypesController < ApplicationController
  def index
    @document_types = DocumentType.all
  end
end
