# frozen_string_literal: true

require 'rails_helper'

# AdminsController
RSpec.describe Admin::AdminsController, type: :controller do
  # this lets us inspect the rendered results
  render_views

  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:admin_user) { create :admin_user }
  before(:each) do
    sign_in admin_user
  end

  describe 'GET index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
    it 'should render the expected columns' do
      get :index
      expect(page).to have_content(admin_user.email)
      expect(page).to have_content(admin_user.created_at.strftime('%B %e, %Y %H:%M'))
    end

    context 'filter works' do
      let(:filters_sidebar) { page.find('#filters_sidebar_section') }
      let!(:matching_admin_user) { create :admin_user, email: 'match@example.com' }
      let!(:non_matching_admin_user) { create :admin_user, email: 'mismatched_admin_user@example.com' }

      it 'filter Email exists' do
        get :index
        expect(filters_sidebar).to have_css('label[for="q_email"]', text: 'Email')
        expect(filters_sidebar).to have_css('input[name="q[email_contains]"]')
      end
      it 'filter Email works' do
        get :index, params: { q: { email_contains: 'match@example' } }

        expect(page).to have_content(matching_admin_user.email)
        expect(page).not_to have_content(non_matching_admin_user.email)
      end
    end
  end

  describe 'GET new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end
    it 'should render the form elements' do
      get :new
      expect(page).to have_field('Email')
      expect(page).to have_field('Password')
      expect(page).to have_field('Password confirmation')
    end
  end

  describe 'POST create' do
    let(:valid_attributes) { build :admin_user }

    subject do
      {
        email: valid_attributes.email,
        password: valid_attributes.password,
        password_confirmation: valid_attributes.password
      }
    end

    context 'with valid params' do
      it 'creates a new AdminUser' do
        expect do
          post :create, params: { admin_user: subject }
        end.to change(AdminUser, :count).by(1)
      end

      it 'redirects to the created admin_user' do
        post :create, params: { admin_user: subject }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(admin_admin_path(AdminUser.last))
      end

      it 'should create the admin_user' do
        post :create, params: { admin_user: subject }
        admin_user_last = AdminUser.last

        expect(admin_user_last['email']).to eq(subject[:email])
      end
    end

    context 'with invalid params' do
      before(:each) do
        subject[:email] = nil
      end
      it 'invalid_attributes return http success' do
        post :create, params: { admin_user: subject }
        expect(response).to have_http_status(:success)
      end

      it 'invalid_attributes do not create a AdminUser' do
        expect do
          post :create, params: { admin_user: subject }
        end.not_to change(AdminUser, :count)
      end
    end
  end

  describe 'GET edit' do
    before do
      get :edit, params: { id: admin_user.id }
    end
    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
    it 'should render the form elements' do
      expect(page).to have_field('Email', with: admin_user.email)
    end
  end

  describe 'PUT update' do
    let(:valid_attributes) { build :admin_user }

    subject do
      {
        email: valid_attributes.email,
        password: valid_attributes.password,
        password_confirmation: valid_attributes.password
      }
    end

    context 'with valid params' do
      before do
        put :update, params: { id: admin_user.id, admin_user: subject }
      end
      it 'returns http redirect' do
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(admin_admin_path(admin_user))
      end
      it 'should update the admin_user' do
        admin_user.reload

        expect(admin_user.email).to eq(valid_attributes[:email])
      end
    end
    context 'with invalid params' do
      before(:each) do
        subject[:email] = nil
      end
      it 'returns http success' do
        put :update, params: { id: admin_user.id, admin_user: subject }
        expect(response).to have_http_status(:success)
      end
      it 'does not change admin_user' do
        expect do
          put :update, params: { id: admin_user.id, admin_user: subject }
        end.not_to change { admin_user.reload.email }.from(admin_user.reload.email)
      end
    end
  end

  describe 'GET show' do
    before do
      get :show, params: { id: admin_user.id }
    end
    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
    it 'should render the form elements' do
      expect(page).to have_content(admin_user.email)
      expect(page).to have_content(admin_user.created_at.strftime('%B %e, %Y %H:%M'))
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested select_option' do
      expect do
        delete :destroy, params: { id: admin_user.id }
      end.to change(AdminUser, :count).by(-1)
    end

    it 'redirects to the field' do
      delete :destroy, params: { id: admin_user.id }
      expect(response).to redirect_to(admin_admins_path)
    end
  end
end
