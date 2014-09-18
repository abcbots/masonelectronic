class CopyGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../../../../', __FILE__)
  # name = file or folder

  # rails g oldword newword oldname [newname]
  def process_names
    @oldword = name.to_s.humanize.downcase.gsub(" ","_")
    @newword = args.shift.to_s.humanize.downcase.gsub(" ","_")
    @oldname = args.shift.to_s
    @newname = (newname=args.shift).present? ? newname.to_s : @oldname.to_s
    @newname = @newname.
      gsub((o=@oldword).pluralize, (n=@newword).pluralize).
      gsub(o.singularize, n.singularize)
  end

  def move_files_or_directories
    if @oldname.gsub("..","").scan(".").present?
      copy_file @oldname, @newname
    else
      directory @oldname, @newname
    end
  end

  def apply_names
    adapt_words @newname, @oldword.pluralize, @newword.pluralize
    adapt_words @newname, @oldword.singularize, @newword.singularize
  end

  private

  # grep -rl 'pass_old_word' pass_path | xargs sed -i 's/'pass_old_word'/pass_new_word/g'
  def adapt_words(pass_path, pass_oldword, pass_newword)
    run "grep -rl '#{pass_oldword}' #{pass_path} | xargs sed -i 's/#{pass_oldword}/#{pass_newword}/g'"
    run "grep -rl '#{pass_oldword.camelcase}' #{pass_path} | xargs sed -i 's/#{pass_oldword.camelcase}/#{pass_newword.camelcase}/g'"
    run "grep -rl '#{pass_oldword.upcase}' #{pass_path} | xargs sed -i 's/#{pass_oldword.upcase}/#{pass_newword.upcase}/g'"
    run "grep -rl '#{pass_oldword.downcase}' #{pass_path} | xargs sed -i 's/#{pass_oldword.downcase}/#{pass_newword.downcase}/g'"
    run "grep -rl '#{pass_oldword.humanize}' #{pass_path} | xargs sed -i 's/#{pass_oldword.humanize}/#{pass_newword.humanize}/g'"
    run "grep -rl '#{pass_oldword.titleize}' #{pass_path} | xargs sed -i 's/#{pass_oldword.titleize}/#{pass_newword.titleize}/g'"
  end

end
