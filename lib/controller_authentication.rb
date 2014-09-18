# This module is included in your application controller which makes
# several methods available to all controllers and views. Here's a
# common example you might add to your application layout file.
#
#   <% if logged_in? %>
#     Welcome <%= current_user.username %>.
#     <%= link_to "Edit profile", edit_current_user_path %> or
#     <%= link_to "Log out", logout_path %>
#   <% else %>
#     <%= link_to "Sign up", signup_path %> or
#     <%= link_to "log in", login_path %>.
#   <% end %>
#
# You can also restrict unregistered users from accessing a controller using
# a before filter. For example.
#
#   before_filter :login_required, :except => [:index, :show]
module ControllerAuthentication

  def self.included(controller)
    controller.send :helper_method, :admin_user, :current_obj, :current_user, :logged_in?, :redirect_to_target_or_default
  end

  def admin_user
    @admin_user ||= User.find_by(username: ["", nil])
  end

  # current_obj
  # @obj=>(any instance variable that matches...?)
  def current_obj
    for cls in makena_classes_u
      #instance_variable_set("@#{cls}")||=nil
      obj||=instance_variable_get("@#{cls}")
    end
    if obj.present? and (logged_in?(obj) or obj.is_public==true)
      obj
    elsif logged_in?
      current_user
    else
      nil
    end
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def logged_in?(obj=nil)
    if current_user.present?
      if obj.present?
        case obj.class.to_s
        when "User"
          current_user.id==obj.id
        else
          current_user.id==obj.user_id
        end
      else
        true
      end
    else
      false
    end
  end

  def login_required
    unless logged_in?
      store_target_location
      redirect_to login_url, :alert => "You must first log in or sign up before accessing this page."
    end
  end

  def redirect_to_target_or_default(default, *args)
    redirect_to(session[:return_to] || default, *args)
    session[:return_to] = nil
  end

  private

  def store_target_location
    session[:return_to] = request.url
  end
end
