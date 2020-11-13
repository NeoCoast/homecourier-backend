# frozen_string_literal: true

require 'rails_helper'

# VolunteersController
RSpec.describe Admin::VolunteersController, type: :controller do
  # this lets us inspect the rendered results
  render_views

  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:admin_user) { create :admin_user }
  before(:each) do
    sign_in admin_user
  end
  let!(:document_type) { create :document_type }
  let!(:volunteer) do
    create(
      :user,
      type: 'Volunteer',
      confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today),
      enabled: false,
      document_type_id: document_type.id,
      document_number: Faker::Number.number(digits: 8)
    )
  end

  describe 'GET index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
    it 'should render the expected columns' do
      get :index
      expect(page).to have_content(volunteer.email)
      expect(page).to have_content(volunteer.username)
      expect(page).to have_content(volunteer.name)
      expect(page).to have_content(volunteer.lastname)
      expect(page).to have_content(volunteer.birth_date)
      expect(page).to have_content(volunteer.address)
      expect(page).to have_content(volunteer.document_type_id)
      expect(page).to have_content(volunteer.document_number)
      expect(page).to have_content(volunteer.created_at.strftime('%B %e, %Y %H:%M'))
      expect(page).to have_content(volunteer.updated_at.strftime('%B %e, %Y %H:%M'))
    end

    context 'filter works' do
      let(:filters_sidebar) { page.find('#filters_sidebar_section') }
      let!(:matching_volunteer) do
        create(
          :user,
          type: 'Volunteer',
          confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today),
          enabled: false,
          document_type_id: document_type.id,
          email: 'match@example.com',
          username: 'match_username',
          name: 'match_name',
          lastname: 'match_lastname',
          document_number: '12345678'
        )
      end
      let!(:non_matching_volunteer) do
        create(
          :user,
          type: 'Volunteer',
          confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today),
          enabled: false,
          document_type_id: document_type.id,
          email: 'mismatched_volunteer@example.com',
          username: 'unmatched_username',
          name: 'unmatched_name',
          lastname: 'unmatched_lastname',
          document_number: '98765432'
        )
      end

      it 'filter Email exists' do
        get :index
        expect(filters_sidebar).to have_css('label[for="q_email"]', text: 'Email')
        expect(filters_sidebar).to have_css('input[name="q[email_contains]"]')
        expect(filters_sidebar).to have_css('label[for="q_username"]', text: 'Username')
        expect(filters_sidebar).to have_css('input[name="q[username_contains]"]')
        expect(filters_sidebar).to have_css('label[for="q_name"]', text: 'Name')
        expect(filters_sidebar).to have_css('input[name="q[name_contains]"]')
        expect(filters_sidebar).to have_css('label[for="q_lastname"]', text: 'Lastname')
        expect(filters_sidebar).to have_css('input[name="q[lastname_contains]"]')
        expect(filters_sidebar).to have_css('label[for="q_document_number"]', text: 'Document number')
        expect(filters_sidebar).to have_css('input[name="q[document_number_contains]"]')
        expect(filters_sidebar).to have_css('label', text: 'Created at')
        expect(filters_sidebar).to have_css('input[name="q[created_at_gteq_datetime]"]')
        expect(filters_sidebar).to have_css('input[name="q[created_at_lteq_datetime]"]')
        expect(filters_sidebar).to have_css('label', text: 'Updated at')
        expect(filters_sidebar).to have_css('input[name="q[updated_at_gteq_datetime]"]')
        expect(filters_sidebar).to have_css('input[name="q[updated_at_lteq_datetime]"]')
      end
      it 'filter Email works' do
        get :index, params: { q: { email_contains: 'match@example' } }

        expect(page).to have_content(matching_volunteer.email)
        expect(page).not_to have_content(non_matching_volunteer.email)
      end
      it 'filter Username works' do
        get :index, params: { q: { username_contains: 'match_username' } }

        expect(page).to have_content(matching_volunteer.username)
        expect(page).not_to have_content(non_matching_volunteer.username)
      end
      it 'filter Name works' do
        get :index, params: { q: { name_contains: 'match_name' } }

        expect(page).to have_content(matching_volunteer.name)
        expect(page).not_to have_content(non_matching_volunteer.name)
      end
      it 'filter Lastname works' do
        get :index, params: { q: { lastname_contains: 'match_lastname' } }

        expect(page).to have_content(matching_volunteer.lastname)
        expect(page).not_to have_content(non_matching_volunteer.lastname)
      end
      it 'filter Document Number works' do
        get :index, params: { q: { document_number_contains: '12345678' } }

        expect(page).to have_content(matching_volunteer.document_number)
        expect(page).not_to have_content(non_matching_volunteer.document_number)
      end
      context 'filter Created at works' do
        it 'since case1' do
          get :index, params: { q: {
            created_at_gteq_datetime: (Date.today - 1.day)
          } }

          expect(page).to have_content(matching_volunteer.email)
        end
        it 'since case2' do
          get :index, params: { q: {
            created_at_gteq_datetime: Date.today
          } }

          expect(page).to have_content(matching_volunteer.email)
        end
        it 'since-until' do
          get :index, params: { q: {
            created_at_gteq_datetime: Date.today,
            created_at_lteq_datetime: (Date.today + 1.day)
          } }

          expect(page).to have_content(matching_volunteer.email)
        end
      end
      context 'filter Updated at works' do
        it 'since case1' do
          get :index, params: { q: {
            updated_at_gteq_datetime: (Date.today - 1.day)
          } }

          expect(page).to have_content(matching_volunteer.email)
        end
        it 'since case2' do
          get :index, params: { q: {
            updated_at_gteq_datetime: Date.today
          } }

          expect(page).to have_content(matching_volunteer.email)
        end
        it 'since-until' do
          get :index, params: { q: {
            updated_at_gteq_datetime: Date.today,
            updated_at_lteq_datetime: (Date.today + 1.day)
          } }

          expect(page).to have_content(matching_volunteer.email)
        end
      end
    end
  end

  describe 'GET show' do
    before do
      get :show, params: { id: volunteer.id }
    end
    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
    it 'should render the form elements' do
      expect(page).to have_content(volunteer.id)
      expect(page).to have_content(volunteer.email)
      expect(page).to have_content(volunteer.username)
      expect(page).to have_content(volunteer.name)
      expect(page).to have_content(volunteer.lastname)
      expect(page).to have_content(volunteer.birth_date)
      expect(page).to have_content(volunteer.address)
      expect(page).to have_content(volunteer.document_type_id)
      expect(page).to have_content(volunteer.document_number)
      expect(page).to have_content(volunteer.created_at.strftime('%B %e, %Y %H:%M'))
      expect(page).to have_content(volunteer.updated_at.strftime('%B %e, %Y %H:%M'))
    end
  end

  describe 'Actions to verify volunteers' do
    before do
      get :show, params: { id: volunteer.id }
    end
    it 'enable volunteer' do
      expect do
        put :accept, params: { id: volunteer.id }
      end.to change { volunteer.reload.enabled }.from(volunteer.reload.enabled)
    end
    it 'reject volunteer' do
      expect do
        put :reject, params: { id: volunteer.id }
      end.to change(Volunteer, :count).by(-1)
    end
  end

  describe 'Batch to verify volunteers' do
    let!(:volunteer2) do
      create(
        :user,
        type: 'Volunteer',
        confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today),
        enabled: false,
        document_type_id: document_type.id,
        document_number: Faker::Number.number(digits: 8)
      )
    end
    it 'enable volunteer' do
      expect do
        post :batch_action, params: { batch_action: :accept, collection_selection: [volunteer.id, volunteer2.id] }
      end.to change { volunteer.reload.enabled }.from(volunteer.reload.enabled)
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(admin_volunteers_path)
    end
    it 'reject volunteer' do
      expect do
        post :batch_action, params: { batch_action: :reject, collection_selection: [volunteer.id, volunteer2.id] }
      end.to change(Volunteer, :count).by(-2)
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(admin_volunteers_path)
    end
  end
end
