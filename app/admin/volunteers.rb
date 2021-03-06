# frozen_string_literal: true

# ActiveAdmin - Volunteer
ActiveAdmin.register Volunteer do
  permit_params :enabled

  actions :index, :show

  scope :all
  scope('Pendings', default: true) { |scope| scope.where(enabled: false) }

  action_item :accept, only: :show do
    link_to 'Accept', accept_admin_volunteer_path(volunteer), method: :put unless volunteer.enabled?
  end

  action_item :reject, only: :show do
    link_to 'Reject', reject_admin_volunteer_path(volunteer), method: :put unless volunteer.enabled?
  end

  member_action :accept, method: :put do
    volunteer = Volunteer.find(params[:id])
    volunteer.update(enabled: true)
    NotificationMailer.with(volunteer: volunteer).accepted_volunteer_email.deliver_now
    redirect_to admin_volunteer_path(volunteer), alert: 'Volunteer has been accepted'
  end

  member_action :reject, method: :put do
    volunteer = Volunteer.find(params[:id])
    NotificationMailer.with(volunteer: volunteer).rejected_volunteer_email.deliver_now
    Volunteer.destroy(params[:id])
    redirect_to collection_path, alert: 'Volunteer has been rejected'
  end

  batch_action :accept do |ids|
    batch_action_collection.find(ids).each do |volunteer|
      volunteer.update(enabled: true)
      NotificationMailer.with(volunteer: volunteer).accepted_volunteer_email.deliver_now
    end
    redirect_to collection_path, alert: 'Volunteers have been enabled.'
  end

  batch_action :reject do |ids|
    batch_action_collection.find(ids).each do |volunteer|
      NotificationMailer.with(volunteer: volunteer).rejected_volunteer_email.deliver_now
      Volunteer.destroy(volunteer.id)
    end
    redirect_to collection_path, alert: 'Volunteers have been rejected.'
  end

  index do
    selectable_column
    column :email
    column :username
    column :name
    column :lastname
    column :birth_date
    column :address
    column :document_type_id
    column :document_number
    column :created_at
    column :updated_at
    column :enabled
    actions
  end

  filter :email
  filter :username
  filter :name
  filter :lastname
  filter :document_number
  filter :created_at
  filter :updated_at

  show do |volunteer|
    attributes_table do
      row :id
      row :email
      row :username
      row :name
      row :lastname
      row :birth_date
      row :address
      row :document_type_id
      row :document_number
      row :avatar do
        if volunteer.avatar.attached?
          link_to 'Download', url_for(volunteer.avatar), download: "Usuario_#{volunteer.username}_avatar.png"
        end
      end
      row :document_face_pic do
        if volunteer.document_face_pic.attached?
          link_to 'Download', url_for(volunteer.document_face_pic), download: "Usuario_#{volunteer.username}_ci_frente.png"
        end
      end
      row :document_back_pic do
        if volunteer.document_back_pic.attached?
          link_to 'Download', url_for(volunteer.document_back_pic), download: "Usuario_#{volunteer.username}_ci_dorso.png"
        end
      end
      row :created_at
      row :updated_at
      row :enabled
    end
  end
end
