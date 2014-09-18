module Views

  # Capitalize first letter, leave the rest as is
  def headline(string=nil)
    if string.present?
      pass = string.to_s.slice(0,1).capitalize + string.to_s.slice(1..-1)
    else
      pass = ""
    end
  end

  # Object is looping 
  def is_looping(obj=nil)
    if (obj||=nil).present?
      @looping_objs||={}
      @looping_objs[obj.class.to_s]||=[]
      if @looping_objs[obj.class.to_s].include?(obj.id)
        return true
      else
        @looping_objs[obj.class.to_s] << obj.id
        return false
      end
    else
      false
    end
  end

  # content = "Welcome to http://www.mine.com/. Email me at me@mine.com."
  # auto_link content, html: {target: '_blank'} do |text|; truncate(text, length: 15); end
  # markdown content
  #=> "Welcome to <a href='http://www.mine.com/'>http://www.mine.com/</a>. Email me..."
  # Starring:
  # Redcarpet
  # Nokogiri
  # Albino
  # RailsAutolink
  def markdown(pass_content="")
    pass_options = {
	:autolink => false,
	:hard_wrap => true,
	:filter_html => false,
	:no_intraemphasis => true,
	:fenced_code => true,
	:gh_blockcode => true
      }
    Redcarpet.new(pass_options)
    pass_content = auto_link( raw(pass_content.to_s), html: {target: '_blank'} )
    pass_content = Redcarpet.new(raw(pass_content.to_s)).to_html
    raw pass_content
  end

  # turn any string into a complete underscore
  def underscore(pass="")
    pass.to_s.strip.humanize.downcase.gsub(/[^a-z0-9-]/,"_")
  end

  # Object is not looping
  def not_looping(obj)
    !is_looping(obj)
  end

  # div collapsible generator
  def div_collapse(hsh={}, obj=nil)
    result=""
    if hsh.class.to_s=="Hash"
      for key in hsh.keys
        pass_key = key.to_s.split("__")
        key = long_key.shift
        options = long_key.shift.to_s.split("_")
        sender = long_key.shift
        content = content_tag(:h3, key.to_s.humanize )
        content << div_collapse(obj, hsh[key])
        content = content_tag(:div, content, data: {role: "collapsible", collapsed: "true"})
        content = content_tag(:div, content, data: {role: "collapsible-set"})
        result << content
      end
    elsif key.to_s=="pass"
      result << content_tag(:div, raw( key ) )
    end
    raw result
  end

  def div_collapse_content(obj, key, hsh, options="[]", sender="name")
    content = ""
    if obj.class.method_defined?(key.to_s)
      objs = obj.send(key.to_s)
      objs = objs.class.to_s=="Array" ? objs : [objs]
      content << render( "layouts/collapsible/objs", obj: obj, objs: objs, header: key.to_s.humanize, sender: sender, options: options)
    end
    raw content
  end

  # jquery mobile link with prefetch
  def link_to_prefetch(*args)
    link_to_builder(%w(prefetch)+args)
  end

  # jquery mobile link that feels like a button, pass obj, or name, obj/path, args
  def link_to_button(*args)
    unless ["String","NilClass"].include?(args.first.class.to_s)
      obj = args.shift
      pass_name = makena(obj, :name)
      pass_obj_or_path = obj
      pass_extra = args.shift
      args = [pass_name, pass_obj_or_path, pass_extra]
    end
    link_to_builder(%w(button)+args)
  end

  # jquery mobile link inline for multiple buttons per line
  def link_to_inline(*args)
    link_to_builder(%w(inline)+args)
  end

  # jquery mobile link inline for multiple buttons per line
  def link_to_inline_destroy(pass_obj_or_path)
    pass_class = pass_obj_or_path.new_record? ? "ui-disabled" : ""
    link_to "DESTROY", pass_obj_or_path, method: :delete, data: {role: "button", inline: "true", confirm: "Are you sure?"}, class: pass_class
  end

 # links in button form and disables if at that url
  def link_to_builder(*args)
    args.flatten!
    pass_type = args.shift.to_s
    pass_name = args.shift.to_s
    pass_obj_or_path = args.shift
    pass_extra = args.shift
    if pass_obj_or_path.present? and pass_obj_or_path.class.to_s!="String" and pass_obj_or_path.attribute_names.include?("image")
      if pass_obj_or_path.image? and pass_obj_or_path.image_url(:small)
        pass_image = (Rails.env.test? ? "_image_showing_" : "")+
        "#{image_tag(pass_obj_or_path.image_url(:small).to_s, size: "32x32")}"
      else
	pass_image = ""
      end
    else
      pass_image = ""
    end
    pass_style="text-overflow:normal;overflow:visible;white-space:pre-wrap;"
    if current_page?(pass_obj_or_path)
      pass_class = 'ui-disabled'
    else
      pass_class = ''
    end
    case pass_type
    when "inline"
      pass_name = pass_image+" "+pass_name
      if current_page?(pass_obj_or_path)
        pass_link_data = {data: {role: "button", inline: "true"}, class: "ui-disabled"}
      else
        pass_link_data = {data: {role: "button", inline: "true"}}
      end
      raw(link_to( raw(pass_name), pass_obj_or_path, pass_link_data ))
    when "button"
      pass_name = raw("<table><tr><td>#{pass_image}</td><td>#{pass_name}</td></tr></table>")
      if current_page?(pass_obj_or_path)
        pass_link_data = {data: {role: "button", prefetch: true}, style: pass_style, class: "ui-disabled"}
      else
        pass_link_data = {data: {role: "button", prefetch: true}, style: pass_style}
      end
      raw(link_to( raw(pass_name), pass_obj_or_path, pass_link_data))
    when "prefetch"
      raw("<ul data-role='listview' data-inset='true' \><li><a href='#{pass_obj_or_path}' 
      data-prefetch 
      data-role='button' 
      style='#{pass_style}' 
      class='#{pass_class}' />#{raw(pass_image)}#{raw(pass_name)}</a></li></ul>")
    end
  end

    # link_to_qrcode(path, pic_size)
    def link_to_qrcode(path, pic_size="256")
	pic_size = pic_size.to_i.to_s
	image_path = "http://chart.googleapis.com/chart?chs=#{pic_size}x#{pic_size}&cht=qr&chl=#{path}"
	raw link_to(image_tag(image_path), path, data: {role: "button", mini: true, inline: true})
    end

 # links in button form and disables if at that url
  def link_to_with_image(*args)
    args.flatten!
    pass_image = (args.shift.to_s or image_tag("white.png"))
    pass_name = args.shift.to_s+pass_image.to_s
    pass_obj_or_path = args.shift
    pass_extra = args.shift
    pass_style="text-overflow:normal;overflow:visible;white-space:pre-wrap;"
    if current_page?(pass_obj_or_path)
      pass_class = 'ui-disabled'
    else
      pass_class = ''
    end
    if current_page?(pass_obj_or_path)
      pass_link_data = {data: {role: "button", prefetch: true}, style: pass_style, class: "ui-disabled"}
    else
      pass_link_data = {data: {role: "button", inline: "false", prefetch: true}, style: pass_style}
    end
    pass_ul_data = {data: {role: "listview", inset: "true"} }
    content_tag(:ul, content_tag(:li, 
    raw(link_to( raw(pass_name), pass_obj_or_path, pass_link_data ) ) ), pass_ul_data)
  end

  def link_to_back
    hsh_b = {data: {role: "button", rel: "back", icon: "back", direction: "reverse", prefetch: true} }
    link_to "BACK", "#", hsh_b
  end

  def link_to_mapped_user(user=@user)
    passpath = ""
    if params[:lat_a].present?
      passpath << "/user/home/#{params[:lat_a].to_s}.#{params[:lat_b].to_s}"
      passpath << "/#{params[:long_a].to_s}.#{params[:long_b].to_s}"
    else
      passpath << "/user/home/#{user.latitude.to_s}/#{user.longitude.to_s}"
    end
    if current_page?(passpath)
      link_to user.name, passpath, data:{role:"button",icon:"heart"}, class:"ui-disabled"
    else
      link_to user.name, passpath, data:{role:"button",icon:"heart"}
    end
  end

end

