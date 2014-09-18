class SuccessGenerator < Rails::Generators::NamedBase

  # Looks and starts here: "/"
  source_root File.expand_path('../../../../', __FILE__)

  def save_app
    run "rails g copy #{name} foobar app ../success/app"
    run "rails g copy #{name} foobar config ../success/config"
    run "rails g copy #{name} foobar lib ../success/lib"
    run "rails g copy #{name} foobar lib ../success/lib"
    run "rails g copy #{name} foobar Gemfile ../success/Gemfile"
    directory "public/themes", "../success/public/themes"
    copy_file "config/initializers/fog.rb", "../success/config/initializers/fog.rb"
    copy_file "public/favicon.ico", "../success/public/favicon.ico"
    copy_file ".gitignore", "../success/.gitignore"
  end

end
