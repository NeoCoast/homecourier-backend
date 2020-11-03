ActiveAdmin.register Volunteer do
  permit_params :enabled
  # permit_params :enabled, :avatar, :document_face_pic, :document_back_pic

  actions :index, :show

  scope :all
  scope("Pendings", default: true) { |scope| scope.where(enabled: false) }  

  action_item :accept, only: :show do
    link_to 'Accept', accept_admin_volunteer_path(volunteer), method: :put if !volunteer.enabled?
  end

  action_item :reject, only: :show do
    link_to 'Reject', reject_admin_volunteer_path(volunteer), method: :put if !volunteer.enabled?
  end

  member_action :accept, method: :put do
    volunteer = Volunteer.find(params[:id])
    volunteer.update(enabled: true)
    redirect_to admin_volunteer_path(volunteer), alert: "Volunteer has been accepted"
  end

  member_action :reject, method: :put do
    volunteer = Volunteer.destroy(params[:id])
    redirect_to collection_path, alert: "Volunteer has been rejected"
  end

  batch_action :accept do |ids|
    batch_action_collection.find(ids).each do |volunteer|
      volunteer.update(enabled: true)
    end
    redirect_to collection_path, alert: "Volunteers have been enabled."
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

  # form do |f|
  #   f.inputs do
  #     f.input :enabled
  #     f.input :avatar, as: :file
  #     f.input :document_face_pic, as: :file
  #     f.input :document_back_pic, as: :file
  #   end
  #   f.actions
  # end

end
