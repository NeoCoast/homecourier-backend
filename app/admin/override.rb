# frozen_string_literal: true

# in app/admin/override.rb

ActiveAdmin::Devise::SessionsController.class_eval do
  def login_path
    '/admin/login'
  end

  def after_sign_in_path_for(_resource)
    admin_volunteers_path + '?scope=pending'
  end

  def after_sign_out_path_for(_resource_or_scope)
    login_path
  end
end
