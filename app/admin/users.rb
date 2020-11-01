ActiveAdmin.register User, as: "Usuarios" do
  permit_params :enabled, :avatar, :document_face_pic, :document_back_pic

  #actions :index, :show, :edit, :update
  actions :index, :show

  # action_item :confirm, only: :show do |user|
  #   link_to 'Confirm', confirm_admin_user_path(user), method: :put
  # end

  # member_action :confirm, method: :put do
  #   user = User.find(params[:id])
  #   user.update(enabled: true)
  #   redirect_to admin_user_path(user)
  # end

  
  # batch_action :flag do |ids|
  #   batch_action_collection.find(ids).each do |user|
  #     user.flag! :hot
  #   end
  #   redirect_to collection_path, alert: "The posts have been flagged."
  # end

  index do
    selectable_column
    column :email
    column :username
    column :name
    column :lastname
    column :birth_date
    column :address
    column :type
    column :document_number
    column :document_type_id
    # column "Avatar" do |user|
    #   if user.avatar.attached?
    #     link_to 'Download', url_for(user.avatar), download: "Usuario_#{user.username}_avatar.png"
    #   end
    # end
    # column "CI Frente" do |user|
    #   if user.type == "Volunteer" and user.document_face_pic.attached?
    #     link_to 'Download', url_for(user.document_face_pic), download: "Usuario_#{user.username}_ci_frente.png"
    #   end
    # end
    # column "CI Dorso" do |user|
    #   if user.type == "Volunteer" and user.document_back_pic.attached?
    #     link_to 'Download', url_for(user.document_back_pic), download: "Usuario_#{user.username}_ci_dorso.png"
    #   end
    # end
    column :enabled
    column :created_at
    column :updated_at
    column :confirmed_at
    column :confirmed_sent_at
    actions
  end

  filter :email
  filter :username
  filter :name
  filter :lastname
  filter :document_number
  filter :created_at
  filter :updated_at

  show do |user|
    attributes_table do
      row :id
      row :email
      row :username
      row :name
      row :lastname
      row :birth_date
      row :address
      row :type
      row :document_number
      row :document_type_id
      row :avatar do
        if user.avatar.attached?
          link_to 'Download', url_for(user.avatar), download: "Usuario_#{user.username}_avatar.png"
        end
      end
      row :document_face_pic do
        if user.type == "Volunteer" and user.document_face_pic.attached?
          link_to 'Download', url_for(user.document_face_pic), download: "Usuario_#{user.username}_ci_frente.png"
        end 
      end
      row :document_back_pic do
        if user.type == "Volunteer" and user.document_back_pic.attached?
          link_to 'Download', url_for(user.document_back_pic), download: "Usuario_#{user.username}_ci_dorso.png"
        end
      end     
    end
  end

  form do |f|
    f.inputs do
      f.input :enabled
      f.input :avatar, as: :file
      f.input :document_face_pic, as: :file
      f.input :document_back_pic, as: :file
    end
    f.actions
  end

  scope :all, default: false
  scope("Helpees") { |scope| scope.where(type: "Helpee") }
  scope("Volunteers") { |scope| scope.where(type: "Volunteer") }
  scope("Pendings") { |scope| scope.where(type: "Volunteer", enabled: false) }


end
