# frozen_string_literal: true

require 'rails_helper'

# DashboardController
RSpec.describe Admin::DashboardController, type: :controller do
  # this lets us inspect the rendered results
  render_views

  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:admin_user) { create :admin_user }
  before(:each) do
    sign_in admin_user
  end

  describe 'index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end
end
