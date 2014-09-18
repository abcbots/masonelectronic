module Controllers

  # standard index
  def controller_index(pass_class, pass_params)
    pass_sender = pass_class.to_s.underscore
    @params = pass_params
    pass_namer = makena(pass_sender, "sender").split("_").first
    @objs = (logged_in? ? current_user.send(pass_sender.pluralize).order("#{pass_namer} ASC") : [])
    #instance_variable_set("@#{pass_sender.pluralize}", (logged_in? ? current_user.send(pass_sender.pluralize).order("#{pass_namer} ASC") : []) )
  end

  #controller_create_user(user_params)
  #=> *new user from user_params"
  def controller_create_user(user_params, notice)
    @user = User.new(user_params)
    respond_to do |format|
      if @user.save
        session[:user_id] = @user.id
        format.html { redirect_to @user, notice: notice }
      else
        format.html { render :new }
      end
    end
  end

  # standard create
  def controller_create(pass_class, pass_params, pass_notice)
    if pass_params["pass_params"].present?
      @params = eval pass_params["pass_params"].to_s
      pass_params.delete("pass_params")
    else
      @params = nil
    end
    pass_obj = pass_class.new(pass_params)
    respond_to do |format|
      if pass_obj.save
        handle_specials(pass_obj)
	pass_previous = pass_obj
        pass_obj, pass_notice = controller_add(pass_obj) if @params.present?
        format.html { redirect_to pass_obj, notice: pass_notice }
        format.json { render :show, status: :created, location: pass_obj }
      else
        format.html { render :new }
        format.json { render json: pass_obj.errors, status: :unprocessable_entity }
      end
    end
  end

  # standard update
  def controller_update(pass_obj, pass_params, pass_notice)
    respond_to do |format|
      if pass_obj.update(pass_params)
        handle_specials(pass_obj)
        pass_obj.save
        if pass_params["remove_image"]=="1"
          begin; pass_obj.remove_image!; rescue; end
        end
        format.html { redirect_to pass_obj, notice: pass_notice }
        format.json { render :show, status: :ok, location: pass_obj }
      else
        format.html { render :edit }
        format.json { render json: pass_obj.errors, status: :unprocessable_entity }
      end
    end
  end

  # standard destroy
  def controller_destroy(pass_obj, pass_redirect, pass_notice)

    pass_obj.destroy
    respond_to do |format|
      format.html { redirect_to pass_redirect, notice: pass_notice }
      format.json { head :no_content }
    end

  end

  # A add B
  # If passed and obj, then it is added to list of objects to add.
  def controller_add(pass_obj=nil)

    from_name = @params["from_name"]
    from_id = @params["from_id"]
    from_rel = @params["from_rel"]
    activity = @params["activity"]
    to_name = @params["to_name"]
    to_rel = @params["to_rel"]

    to_ids = params["subjects"].present? ? params["subjects"].keys.to_a : []
    to_ids += [pass_obj.id.to_s] if (pass_obj.present? and !to_ids.include?(pass_obj.id.to_s))

    for to_id in to_ids
      sender, hsh = controller_sender_generate(from_name, from_id, from_rel, to_name, to_id, to_rel)
      current_user.send(sender).find_or_create_by(hsh) if sender
    end

    if from_name=="user"
      obj = User.find(from_id)
    else
      obj = current_user.send(from_name.pluralize).find(from_id)
    end
    notice = "#{activity.upcase} #{from_name.humanize} #{(to_rel||to_name).humanize} processed."
    return [obj, notice]
  end

  # A add B
  # If passed and obj, then it is added to list of objects to add.
  def controller_copy(pass_obj=nil)
    from_name = @params["from_name"]
    from_id = @params["from_id"]
    from_rel = @params["from_rel"]
    activity = @params["activity"]
    to_name = @params["to_name"]
    to_rel = @params["to_rel"]
    to_ids = params["subjects"].present? ? params["subjects"].keys.to_a : []
    to_ids += [pass_obj.id.to_s] if (pass_obj.present? and !to_ids.include?(pass_obj.id.to_s))
    from_obj = from_name.singularize=="user" ? current_user : current_user.send(from_name.pluralize).find(from_id)
    for to_id in to_ids
	to_obj = current_user.send(to_name.pluralize).find(to_id)
	obj = to_obj.dup
	obj.update(makena(obj, :sender).split("_").first.to_sym => obj.send(makena(obj, :sender).split("_").first)+"*")
	obj.save
	from_id = obj.id
	if from_name==to_name
	    sender, hsh = controller_sender_generate(from_name, to_id, from_rel, to_name, from_id, to_rel)
	else
	    sender, hsh = controller_sender_generate(from_name, from_id, from_rel, to_name, to_id, to_rel)
	end
	current_user.send(sender).find_or_create_by(hsh) if sender
    end
    notice = "#{activity.upcase} #{from_name.humanize} #{(to_rel||to_name).humanize} processed."
    return [obj, notice]
  end

  # A remove B
  def controller_remove(pass_obj=nil)
    from_name = @params["from_name"]
    from_id = @params["from_id"]
    from_rel = @params["from_rel"]
    activity = @params["activity"]
    to_name = @params["to_name"]
    to_rel = @params["to_rel"]
    to_ids = params["subjects"].present? ? params["subjects"].keys.to_a : []
    to_ids += [pass_obj.id.to_s] if (pass_obj.present? and !to_ids.include?(pass_obj.id.to_s))
    for to_id in to_ids

      sender, hsh = controller_sender_generate(from_name, from_id, from_rel, to_name, to_id, to_rel)
      if sender
        for destroyable in current_user.send(sender).where(hsh)
          destroyable.destroy
        end
      end
    end
    if from_name=="user"
      obj = User.find(from_id)
    else
      obj = current_user.send(from_name.pluralize).find(from_id)
    end
    notice = "#{activity.upcase} #{from_name.humanize} #{(to_rel||to_name).humanize} processed."
    return [obj, notice]
  end

  # A destroy B
  def controller_destroy(pass_obj=nil)
    from_name = @params["from_name"]
    from_id = @params["from_id"]
    from_rel = @params["from_rel"]
    activity = @params["activity"]
    to_name = @params["to_name"]
    to_rel = @params["to_rel"]
    to_ids = params["subjects"].present? ? 
      (params["subjects"].keys - [from_id.to_s]) : 
      (pass_obj.present? ? ([pass_obj.id.to_s] - [from_id.to_s]) : [])
    for to_id in to_ids
      for destroyable in current_user.send(to_name.pluralize).where(id: to_ids)
        destroyable.destroy
      end
    end
    if from_name=="user"
      obj = User.find(from_id)
    else
      obj = current_user.send(from_name.pluralize).find(from_id)
    end
    notice = "#{activity.upcase} #{from_name.humanize} #{(to_rel||to_name).humanize} processed."
    return [obj, notice]
  end

  protected

  # @user.address = "123 Street"
  # handle_specials(@user)
  #=> @user.content = "<h1>Foobar</h1>"
  # @user.address = nil 
  # handle_specials(@user)
  #=> @user.name = "Foobar"
  def handle_specials(pass_obj)
    if makena(pass_obj, :specials).include?(:name_by_content_by_address)
      pass_content = pass_obj.content.to_s.strip.present? ? pass_obj.content.to_s.strip : nil
      pass_address = pass_obj.address.to_s.strip.present? ? pass_obj.address.to_s.strip : nil
      pass_coords = (pass_obj.latitude and pass_obj.longitude) ? "#{pass_obj.latitude.to_s}/#{pass_obj.longitude.to_s}" : nil
      pass_obj.name=(pass_content||pass_address||pass_coords||Time.now).to_s.truncate(245)
    elsif makena(pass_obj, :specials).include?(:name_by_content)
      pass_content = pass_obj.content.to_s.strip.present? ? pass_obj.content.to_s.strip : nil
      pass_obj.name=(pass_content||Time.now).to_s.truncate(245)
    end
    pass_obj.save
    return pass_obj
  end

  # controller_sender_generate(pass_obj, from_name, from_id, to_name, to_id)
  # pass_obj => #<Section id: 10, user_id: 67, name: "Experience", content: "Experience content to follow below...", image: nil, created_at: "2014-07-07 16:10:39", updated_at: "2014-07-07 16:10:39", is_public: true, show_time: true>
  # from_name => "timeline"
  # from_id => "13"
  # from_rel => nil
  # to_name => "sections"
  # to_id => "10"
  # to_rel => nil
  def controller_sender_generate(from_name, from_id, from_rel, to_name, to_id, to_rel)
    hsh={}
    from_obj = from_name.camelize.constantize.find(from_id)
    if from_name==to_name
      hsh["#{from_rel}_id".to_sym]=from_id.to_i
      hsh["#{to_rel}_id".to_sym]=to_id.to_i
      # hsh => {:parent_id=>67, :child_id=>13}
    else
      hsh["#{from_name.singularize}_id".to_sym]=from_id.to_i
      hsh["#{to_name.singularize}_id".to_sym]=to_id.to_i
      # hsh => {:user_id=>67, :timeline_id=>13}
    end
    if from_obj.class.reflect_on_association( sender=(from_name+"_"+to_name.pluralize).to_sym ).present?
	sender = sender.to_s
        # sender => "timeline_sections"
    elsif from_obj.class.reflect_on_association( sender=(to_name+"_"+from_name.pluralize).to_sym ).present?
	sender = sender.to_s
        # sender => "section_entries"
    else
	sender = nil
    end
    # [sender, hsh] => ["section_entries", {:section_id=>10, :entry_id=>4}]
    [sender, hsh]
  end

end

