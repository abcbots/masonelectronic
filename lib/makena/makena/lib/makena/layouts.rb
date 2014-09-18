module Layouts

  # Broker layout form partials to obj forms
  def layouts_form(*args)
    f = (args.shift)
    obj = (args.shift)
    name_of_partial = (args.shift).to_s
    name_of_attribute = (args.shift||name_of_partial).to_s
    header = (args.shift||name_of_attribute).to_s.humanize.upcase
    render "layouts/form/#{name_of_partial}", f: f, obj: obj, sender: name_of_attribute, header: header, args: args
  end

  # Broker layout form partials to obj forms
  def layouts_forms(*args)
    f = (args.shift)
    obj = (args.shift)
    name_of_partial = (args.shift).to_s
    senders = (args.shift||name_of_partial)
    headers = (args.shift||senders)
    render "layouts/form/#{name_of_partial}", f: f, obj: obj, senders: senders, headers: headers, args: args
  end

  # Broker layout view partials to obj views
  def layouts_show(*args)
    obj = args.shift
    if args.present?
      name_of_partial = (args.shift).to_s
      name_of_attribute = (args.shift||name_of_partial).to_s
      header = args.shift
      render "layouts/show/#{name_of_partial}", obj: obj, sender: name_of_attribute, header: header, args: args.shift
    else
      render "layouts/show", obj: obj
    end
  end

  # Broker layout view partials to obj views
  def layouts_show_links(*args)
    render "layouts/show/links", obj: args.shift, sender: args.shift, args: args 
  end

end
