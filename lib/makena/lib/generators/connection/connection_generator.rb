class ConnectionGenerator < Rails::Generators::NamedBase

  # Look from root
  source_root File.expand_path('../../../../', __FILE__)

  # Example:
  # rails g connectionion spot note name|content|image
  def establish_variables
    @alpha = name.underscore.singularize
    @beta = args.shift.underscore.singularize 
    @connection = @alpha+"_"+@beta
    @atts = args.shift.to_s.split("|")
    @root = "lib/generators/connection/templates"
  end

  # Create standard scaffold
  def generate_scaffold_and_models
    if @alpha!=@beta
      generate_scaffold_beta
      generate_model_alpha_beta
    elsif @alpha==@beta
      generate_model_parents_children
    end
  end

  # Modify standard views
  def modify_views
    if @alpha!=@beta
      modify_views_assocs
    end
  end

  def generate_extensions
    if @alpha!=@beta
      empty_directory "app/models/extensions"
      add_has_many_to_alpha_beta_models
      template_extensions_geocoder if @atts.include?("location")
      template_extensions_image if @atts.include?("image")
    elsif @alpha==@beta
      template_extensions_parents_children
    end
  end
 
  # Add feature testing
  def add_testing_notes
    a = "features/user.feature"
    b = "#T\O\D\O Add testing for #{@alpha}, #{@beta}, #{@connection}"
    prepend_to_file a, b 
  end

  # Run migration
  def run_migration
    run "rake db:drop"
    run "rake db:create"
    run "rake db:migrate"
    run "rake db:test:clone" # unless Rails 4.1+
  end

  private

  # Generate parents and children model
  def generate_model_parents_children
    generate "model", "#{@connection} user:references parent:references child:references"
    from_file = "app/models/#{@connection}.rb"
      from = "  belongs_to :parent"
      to = "  belongs_to :parent_#{@beta}, class_name: '#{@beta.camelcase}', foreign_key: 'parent_id'"
      gsub_file from_file, from, to
    from_file = "app/models/#{@connection}.rb"
      from = "  belongs_to :child"
      to = "  belongs_to :child_#{@beta}, class_name: '#{@beta.camelcase}', foreign_key: 'child_id'"
      gsub_file from_file, from, to
  end

  # Modify assocs views
  def modify_views_assocs
      modify_view @beta, :name if @atts.include?("name")
      modify_view @beta, :image if @atts.include?("image")
      modify_view @beta, :text, :content if @atts.include?("content")
      modify_view @beta, :address, :location if @atts.include?("address")
  end

  # Generate scaffold assocs
  def generate_scaffold_beta
    pass_order = "#{@beta.pluralize} user:references"
    pass_order << " is_public:boolean:index"
    pass_order << " name:string:index" if @atts.include?("name")
    pass_order << " content:text" if @atts.include?("content")
    if @atts.include?("location")
      pass_order << " address:string:index"
      pass_order << " latitude:float:index"
      pass_order << " longitude:float:index"
    end
    pass_order << " image:string:index" if @atts.include?("image")
    generate "scaffold", pass_order
  end

  # Generate model for associates
  def generate_model_alpha_beta
    generate "model", "#{@connection} user:references #{@alpha}:references #{@beta}:references"
    from_file = "app/models/#{@connection}.rb"
      from = "  belongs_to :parent"
      to = "  belongs_to :parent_#{@beta}, class_name: '#{@beta.camelcase}', foreign_key: 'parent_id'"
      gsub_file from_file, from, to
    from_file = "app/models/#{@connection}.rb"
      from = "  belongs_to :child"
     to = "  belongs_to :child_#{@beta}, class_name: '#{@beta.camelcase}', foreign_key: 'child_id'"
      gsub_file from_file, from, to
  end

  # Transfer assocs extensions
  def add_has_many_to_alpha_beta_models
    passtarget = "< ActiveRecord::Base\n"

      passpath = "app/models/#{@alpha}.rb"
        passinsert = "  has_many :#{@alpha}_#{@beta.pluralize}\n"
        passinsert << "  has_many :#{@beta.pluralize}, :through => :#{@alpha}_#{@beta.pluralize}\n"
        insert_into_file passpath, passinsert, :after => passtarget

      passpath = "app/models/#{@beta}.rb"
        passinsert = "  has_many :#{@alpha}_#{@beta.pluralize}\n"
        passinsert << "  has_many :#{@alpha.pluralize}, :through => :#{@alpha}_#{@beta.pluralize}\n"
        insert_into_file passpath, passinsert, :after => passtarget
  end

  # Transfer parents children extensions
  def template_extensions_parents_children
    generate_model_extension "AlphaAlphas"
    modify_model_extension_include @alpha, "AlphaAlphas"
    modify_model_extension_include @beta, "AlphaAlphas"
  end

  # Transfer image extensions
  def template_extensions_image
    generate_model_extension "Image"
    modify_model_extension_include @beta, "Image"
  end

  # Transfer image extensions
  def template_extensions_geocoder
    generate_model_extension "Geocoder"
    modify_model_extension_include @beta, "Geocoder"
  end

  # Generate model extension
  def generate_model_extension(extname)
    passfrom = "#{@root}/extensions/#{extname.underscore}.rb"
    passto = "app/models/extensions/#{extname.underscore}.rb"
    template passfrom, passto 
  end

  # Modify object model
  # after: class Spot < ActiveRecord::Base
  # include Extensions::Geocoder
  def modify_model_extension_include(objname, extname)
    passtarget = "< ActiveRecord::Base\n"
    passinsert = "  include Extensions::#{extname}\n"
    passpath = "app/models/#{objname}.rb"
    insert_into_file passpath, passinsert, :after => passtarget
  end

  # Modify object views
  def modify_view(objname, objtype, objatt=nil)
    objatt||=objtype.to_sym
    modify_view_form(objname, objtype, objatt)
    build_view_partial(objname, objtype, objatt)
    modify_view_partial(objname, objtype, objatt)
  end

  # Modify object form
  def modify_view_form(objname, objtype, objatt)
    passformtarget = "<%= form_for @#{objname}, data:{ajax:false}, html:{multipart:true} do |f| %>\n"
    passforminsert = "  <%= layouts_form f, @#{objname}, \"#{objtype}\", #{objatt} %>\n"
    passfilepath = "app/views/#{objname.pluralize}/_form.html.erb"
    insert_into_file passfilepath, passforminsert, :after => passformtarget
  end

  # Build object partial
  def build_view_partial(objname, objtype, objatt)
    passfilepath = "app/views/#{objname.pluralize}/_#{objname}.html.erb"
    pass = []
    pass << "<!-- #{passfilepath} -->"
    pass << "<%= form_for @#{objname}, data:{ajax:false}, html:{multipart:true} do |f| %>"
    pass << "<% end %>"
    create_file passfilepath, pass.join("\n")
  end

  # Modify object partial
  def modify_view_partial(objname, objtype, objatt)
    passformtarget = "<%= form_for @#{objname}, data:{ajax:false}, html:{multipart:true} do |f| %>\n"
    passforminsert = "  <%= layouts_show #{objname}, \"#{objtype}\", #{objatt} %>\n"
    passfilepath = "app/views/#{objname.pluralize}/_#{objname}.html.erb"
    insert_into_file passfilepath, passforminsert, :after => passformtarget
  end

end
