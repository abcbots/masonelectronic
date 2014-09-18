class GitGenerator < Rails::Generators::NamedBase

  source_root File.expand_path('../../../../', __FILE__)
  argument :content, :type => :string, :default => ""

  def do_railroad
    if content.present?
      run "railroady -M -b | dot -Tsvg > app/assets/images/models.svg"
      run "railroady -C -b | dot -Tsvg > app/assets/images/controllers.svg"
    end
  end

  def do_yard
    if content.present?
      run "yard"
    end
  end

  def do_assets_precompile
    if content.present?
      run "rake assets:precompile"
    end
  end

  def git_gc_and_prune
    if content.present?
      run "git gc --prune"
    end
  end

  def git_comment
    if content.present?
      run "git add --all .; git commit -m '#{name.to_s.humanize.upcase} << #{content.to_s.gsub("_"," ")}'"
      run "heroku maintenance:on" if content.present?
      run "git push heroku master"
    else
      run "git add --all .; git commit -m '#{name.to_s}'"
    end
  end

  def run_heroku_migration
    if content.present?
      run "heroku run rake db:migrate" if content.present?
    end
  end

  def run_heroku_restart
    if content.present?
      run "heroku restart" if content.present?
      run "heroku maintenance:off" if content.present?
    end
  end

  def git_add
    run "rake notes"
  end


end
