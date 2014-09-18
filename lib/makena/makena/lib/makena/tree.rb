module Tree


  # hash of application objects and infromation about objects
  def makena(obj=nil, abstract=nil)
    sender = makenaize_sender(obj)
    if obj.present? and abstract.present?
    # if obj and abstract
      if makena_hsh[sender]
      # if obj has a key, makena_hsh[sender][abstract]
        abstract = abstract.to_s
        case abstract.to_s
        when "name"
	  if ( obj.attribute_names.include?("is_public") and obj.is_public!=true )
	    "#{headline( obj.send(makena_hsh[sender]["sender"]).to_s ).to_s} (private)"
	  else
	    headline( obj.send(makena_hsh[sender]["sender"]).to_s ).to_s
	  end
        when "sender"
          makena_hsh[sender]["sender"]
        when "header"
          makena_hsh[sender]["header"]
        when "options"
          makena_hsh[sender]["options"]
        when "senders"
  	  makena_senders(obj)
        when "assocs"
  	  makena_assocs(obj)
        when "specials"
          makena_hsh[sender]["specials"]
        end
      else
        return nil
      end
    elsif obj.present?
      if makena_hsh[sender]
        return makena_hsh[sender]
      else
        return nil
      end
    else
      return makena_hsh
    end
  end

  # Actual makena hash to draw from
  #def makena_hsh
  #  unless (@makena_hsh||=nil)
  #    @makena_hsh={}
  #    options = %w(public private new copy add remove destroy)
  #    @makena_hsh = @makena_hsh.merge( makena_hsh_obj(:user, nil, :name, options ) )
  #    specials = [:name_by_content_by_address]
  #    @makena_hsh = @makena_hsh.merge( makena_hsh_obj(:spot, nil, :name_with_distance, options, specials ) )
  #    specials = [:name_by_content]
  #    @makena_hsh = @makena_hsh.merge( makena_hsh_obj(:note, nil, :name, options, specials ) )
  #  end
  #  @makena_hsh
  #end
  # hsh = hsh.merge( makena_hsh_obj(:user, "User", :name, [], [:alpha, :beta, :ceta] ) )
  # hsh = hsh.merge( makena_hsh_obj(:alpha, nil, :name, [], [], [:name_from_content]) )
  # hsh = hsh.merge( makena_hsh_obj(:alpha_parent, nil, :name, [], [], [:name_from_content]) )
  # hsh = hsh.merge( makena_hsh_obj(:alpha_child, nil, :name, [], [], [:name_from_content]) )
  # hsh = hsh.merge( makena_hsh_obj(:beta, nil, :name, [], []) )
  # hsh = hsh.merge( makena_hsh_obj(:ceta, nil, :name, [], []) )

  # Find associates for each of obj senders and load into hash and return
  def makena_hsh_load_assocs(hsh)
    for key in hsh.keys
      for sender in hsh[key]["senders"]
        sender_sym = sender.singularize.to_sym
        key_sender = key.to_s.pluralize
        unless key==:user or hsh[sender_sym]["senders"].include?(key_sender) or hsh[sender_sym]["assocs"].include?(key_sender)
          hsh[sender_sym]["assocs"] << key_sender
        end
      end
    end
    hsh
  end

  def makena_assocs(obj)
    makena_senders(obj)
  end

  # Create makena hash object
  def makena_hsh_obj(objsym, header=nil, sender="id", options=[], specials=[])
    hsh||={}
    hsh[objsym]={}
    hsh[objsym]["header"]=(header||objsym.to_s.humanize.titleize).to_s
    hsh[objsym]["sender"]=sender.to_s
    hsh[objsym]["options"]=options.map{|a| a.to_s}
    hsh[objsym]["specials"]=specials.map{|a| a.to_sym}
    hsh
  end

  # Convert name into makena ready name
  def makenaize_name(obj, name)
    %w(parents children).include?(name) ? "#{obj.class.to_s.underscore}_#{name.singularize}".to_sym : name.to_s.singularize.to_sym
  end

  # Convert obj into makena ready sender
  def makenaize_sender(obj)
    if obj.present?
      if obj.class.to_s=="Symbol"
        obj.to_s.singularize.to_sym
      else
        obj.class.to_s.underscore.singularize.to_sym
      end
    else
      nil
    end
  end

  #makena_classes
  #=> [User, Foo, Foobar]
    def makena_classes
      Rails.application.eager_load!
      pass = ActiveRecord::Base.descendants.map{|a| a.to_s}
      pass.shift
      pass
    end

    #makena_classes_u
    #=> ["user_foos", "foo_foos", "foo_foobars", "foobar_foobars"]
    def makena_classes_connecting_u(pass_obj=nil)
      passsingles = makena_classes.map{|a| a.to_s.underscore}
      (passsingles & makena_classes_doubled)
    end

    def makena_classes_doubled
      passdoubles=[]
      for b in makena_classes
	passdoubles += makena_classes.map{|a| a.to_s.underscore+"_"+b.to_s.underscore}
	passdoubles += makena_classes.map{|a| b.to_s.underscore+"_"+a.to_s.underscore}
      end
      passdoubles
    end

    #makena_classes_u
    #=> ["user", "foo", "foobar"]
    #
    def makena_classes_u
      passsingles = makena_classes.map{|a| a.to_s.underscore}
      passsingles - makena_classes_doubled
    end

    #makena_classes_u_p_sym
    #=> [:users, :foos, :foobars]
    #
    def makena_classes_u_p_sym
      makena_classes_u.map{|a| a.underscore.pluralize.to_sym}
    end

    #makena_classes_u_p_sym_assocs_s_p(@user)
    # => ["spots", "friendships"]
    #
    def makena_classes_u_p_sym_assocs_s_p(obj)
      makena_classes_u_p_sym.map{|a| obj.class.reflect_on_association(a).present? ? a.to_s : nil}.uniq-[nil]
    end

    #makena_senders(@user)
    # => ["spots", "friendships"]
    #
    def makena_senders(obj)
      makena_classes_u_p_sym_assocs_s_p(obj)
    end

    # Generate list of possible foreign ids, example "user_id"
    #
    def makena_params
      Rails.application.eager_load!
      dants = ActiveRecord::Base.descendants
      return dants.map{|a| a.to_s}.map{|a| [a.underscore+"_parent_id", a.underscore+"_id", a.underscore+"_child_id"]}.flatten
    end

end
