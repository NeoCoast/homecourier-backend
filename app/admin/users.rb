ActiveAdmin.register User, as: "Usuarios" do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :enabled
  #
  # or
  #
  # permit_params do
  #   permitted = [:enabled]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
  # controller do
  #   def update
  #     # Good
  #     @user = User.find(permitted_params[:user])

  #     if @user.save
  #       # ...
  #     end
  #   end
  # end

  scope :all, default: false
  scope("Helpees") { |scope| scope.where(type: "Helpee") }
  scope("Volunteers") { |scope| scope.where(type: "Volunteer") }
  scope("Pendings") { |scope| scope.where(type: "Volunteer", enabled: nil) }

end
