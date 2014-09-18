class SetupGenerator < Rails::Generators::NamedBase

  # Root
  source_root File.expand_path('../../../../../success', __FILE__)

  def copy_readme
    adapt_file("README.rdoc")
  end

  def copy_gitignore
    copy_file ".gitignore"
  end

  def install_cucumber
    run "rails g rspec:install"
    run "rails g cucumber:install"
    directory "features"
    adapt_file("features/user.feature")
  end

  def copy_figaro
    copy_file "config/application.yml"
    adapt_file "config/application.yml"
  end

  def copy_fog
    copy_file "config/initializers/fog.rb"
    append_to_file "config/initializers/fog.rb", 
      "\n# #{"todo".upcase} add AWS bucket #{name.downcase}\n\n"
  end

  def copy_friendship
    run "rails g scaffold friendships message:text deny:boolean:index meet_at:datetime:index address:string:index latitude:float:index longitude:float:index user:references friend:references"
  end

  def copy_uploaders
    directory "app/uploaders"
  end

  def copy_layout
    copy_file "app/assets/javascripts/application.js"
    copy_file "app/assets/stylesheets/application.css"
    directory "app/views/layouts"
    copy_helper "apple"
    copy_helper "controllers"
    copy_helper "layouts"
    copy_helper "layout"
  end

  def add_user
    copy_migration "20140502222428_create_users.rb"
    copy_scaffold "users"
    copy_scaffold "layouts"
    copy_scaffold "friendships"
    copy_views "sessions"
    copy_controller "sessions_controller.rb"
    copy_helper "apple"
    copy_helper "controllers"
    copy_helper "layout"
    copy_helper "sessions"
    add_user_authentication
    add_user_routes
    add_layouts_routes
  end

  def rake_notes
    run "rake notes"
  end

  def run_git_for_the_first_time
    run "git init"
  end

private

  def copy_controller(passpath)
    copy_file "app/controllers/#{passpath}"
  end

  def copy_helper(pass_helper_name)
    copy_file "app/helpers/#{pass_helper_name}_helper.rb"
    add_helper_to_app pass_helper_name
  end

  def copy_migration(passpath)
    copy_file "db/migrate/#{passpath}"
  end

  def copy_models(passpath)
    copy_file "app/models/#{passpath}"
  end

  def copy_scaffold(passname)
    copy_views passname 
    copy_helper passname 
    copy_controller "#{passname}_controller.rb"
    copy_models "#{passname.singularize}.rb"
  end

  def copy_views(passpath)
    directory "app/views/#{passpath}"
  end

  def add_helper_to_app(pass_helper_name)
    pass_injection = "  include #{pass_helper_name.camelcase}Helper\n"
    pass_file = "app/controllers/application_controller.rb" 
    pass_after = "class ApplicationController < ActionController::Base\n"
    inject_into_file pass_file, pass_injection, :after => pass_after
  end

  def adapt_file(passpath)
    generator "copy", "foobar #{name} #{passpath}"
  end

  def add_user_authentication
    copy_file "lib/controller_authentication.rb"

    pass_path = "config/application.rb"
    pass_target = "  class Application < Rails::Application\n"
    pass_injection = "    config.autoload_paths << \"\#{config.root}/lib\"\n"
    inject_into_file pass_path, pass_injection, :after => pass_target

    pass_path = "app/controllers/application_controller.rb"
    pass_target = "class ApplicationController < ActionController::Base\n"
    pass_injection = "  include ControllerAuthentication\n"
    inject_into_file pass_path, pass_injection, :after => pass_target

  end

  def add_layouts_routes
    inject_into_file "config/routes.rb", "
  resources :layouts
  get 'activity/:from_name/:from_id/:activity/:to_name(/:to_id)' => 'layouts#index', as: :activity
    ", :before => "\n  resources :users"
  end

  def add_user_routes
    inject_into_file "config/routes.rb", "
  resources :users
  resources :sessions
  root 'users#new'
  match 'user/home' => 'users#show', :as => :user_home, via: [:get, :post]
  get 'user/edit' => 'users#edit', :as => :edit_current_user
  get 'signup' => 'users#new', :as => :signup
  get 'logout' => 'sessions#destroy', :as => :logout
  get 'login' => 'sessions#new', :as => :login
    ", :after => "routes.draw do\n"
  end


end
