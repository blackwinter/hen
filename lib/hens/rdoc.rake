Hen :rdoc do

  require 'rake/rdoctask'

  rdoc_options = config[:rdoc]

  if rf_package = config[:rubyforge][:package]
    rdoc_options[:title] ||= "#{rf_package} Application documentation"
  end

  RDOC_OPTIONS = {
    :rdoc_dir   => rdoc_options.delete(:rdoc_dir),
    :rdoc_files => FileList[rdoc_options.delete(:rdoc_files)].to_a.uniq,
    :options    => rdoc_options.map { |option, value|
      option = '--' << option.to_s.tr('_', '-')
      value.is_a?(String) ? [option, value] : value ? option : nil
    }.compact.flatten
  }

  rdoc_task = Rake::RDocTask.new(:doc) { |rdoc|
    rdoc.rdoc_dir   = RDOC_OPTIONS[:rdoc_dir]
    rdoc.rdoc_files = RDOC_OPTIONS[:rdoc_files]
    rdoc.options    = RDOC_OPTIONS[:options]
  }

  rubyforge do |rf_config|

    desc 'Publish RDoc to Rubyforge'
    task :publish_docs => :doc do
      rf_project = rf_config[:project]
      abort 'Rubyforge project name missing' unless rf_project

      rf_user = rf_config[:username]
      abort 'Rubyforge user name missing' unless rf_user

      user__host = "#{rf_user}@rubyforge.org"

      local_dir  = rdoc_task.rdoc_dir + '/'
      remote_dir = "/var/www/gforge-projects/#{rf_project}/"

      if rdoc_dir = rf_config[:rdoc_dir]
        if rf_package = rf_config[:package]
          rdoc_dir = rf_package if rdoc_dir == :package
        end

        remote_dir += rdoc_dir + '/'
      end

      execute(
        "rsync -av --delete #{local_dir} #{user__host}:#{remote_dir}",
        "scp -r #{local_dir} #{user__host}:#{remote_dir}"
      )
    end

  end

end
