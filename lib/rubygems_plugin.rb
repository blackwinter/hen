Gem.post_install { |installer|
  next unless installer.options[:post_install_message]

  next if ENV['HEN_DISABLE_POST_INSTALL_CHANGELOG']

  spec = [curr_spec = installer.spec]

  begin
    spec << Gem::Specification.find_by_name(
      curr_spec.name, "< #{curr_spec.version}")
  rescue Gem::MissingSpecVersionError
    next
  end

  # XXX remove
  installer.say "#{spec[1].version} -> #{spec[0].version} (#{Dir.pwd})"

  # XXX install dir
  next unless File.readable?(log = ENV['HEN_CHANGELOG'] || curr_spec.files
    .grep(%r{\A(?:change(?:s|log)|history)[^/]*\z}i).first || 'ChangeLog')

  pre, ver = /\A== /, spec.map { |s| s.version.release.to_s }

  found, single, msg, h = nil, ver.uniq!, [],
    ver.map { |v| /#{pre}#{Regexp.escape(v)}\D.*/o }

  File.foreach(log) { |line|
    line.chomp!

    case line
      when h[0] then found = 0
      when h[1] then found ? found = 1 : break
      when pre  then break if single || (found && found > 0)
    end

    msg << line if found
  }

  installer.say "\n#{msg.join("\n").strip}\n\n" unless msg.empty?
}
