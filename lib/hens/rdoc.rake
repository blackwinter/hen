Hen :rdoc do

  rdoc_options = {
    :rdoc_dir       => 'doc',
    :rdoc_files     => %w[README COPYING ChangeLog lib/**/*.rb ext/**/*.c],
    :charset        => 'UTF-8',
    :inline_source  => true,
    :line_numbers   => true,
    :all            => true
  }.update(config[:rdoc])

  rdoc_klass = begin
    raise LoadError if rdoc_options.delete(:legacy)

    require 'rdoc/task'

    rdoc_options.delete(:inline_source)  # deprecated
    RDoc::Task
  rescue LoadError
    require 'rake/rdoctask'
    Rake::RDocTask
  end

  rdoc_options[:title] ||= begin
    title = 'Application documentation'

    if name = project_name(*config.values_at(:rubyforge, :gem))
      title.insert(0, "#{name} ")
    end

    if version = config[:gem][:version]
      title << " (v#{version})"
    end

    title
  end

  ### rdoc_dir

  rdoc_dir = rdoc_options.delete(:rdoc_dir)

  ### rdoc_files, main

  rdoc_files = FileList[rdoc_options.delete(:rdoc_files)].sort_by { |file|
    [file.length, file]
  }

  rdoc_files_local = rdoc_files.dup

  if mangle_files!(rdoc_files)
    mangle_files!(rdoc_files_local, :managed => false)
  else
    rdoc_files_local = nil
  end

  rdoc_options.delete(:main) unless rdoc_files.include?(rdoc_options[:main])
  rdoc_options[:main] ||= rdoc_files.first

  ### rdoc_options

  rdoc_options = rdoc_options.map { |option, value|
    option = '--' << option.to_s.tr('_', '-')
    value.is_a?(String) ? [option, value] : value ? option : nil
  }.compact.flatten

  # Make settings available to other hens
  RDOC_OPTIONS = {
    :rdoc_dir   => rdoc_dir,
    :rdoc_files => rdoc_files,
    :options    => rdoc_options
  }

  unless rdoc_files.empty?
    rdoc_task = rdoc_klass.new(:doc) { |rdoc|
      rdoc.rdoc_dir   = rdoc_dir
      rdoc.rdoc_files = rdoc_files
      rdoc.options    = rdoc_options
    }
  else
    task :doc do
      warn 'No files to generate documentation for!'
    end
  end

  unless rdoc_files_local.nil? || rdoc_files_local.empty?
    rdoc_klass.new('doc:local') { |rdoc|
      rdoc.rdoc_dir   = rdoc_dir + '.local'
      rdoc.rdoc_files = rdoc_files_local
      rdoc.options    = rdoc_options

      extend_object(rdoc) {
        def local_description(desc); "#{desc} (including unmanaged files)"; end

        def clobber_task_description; local_description(super); end
        def rdoc_task_description;    local_description(super); end
        def rerdoc_task_description;  local_description(super); end
      }
    }
  end

  publish_desc = "Publish RDoc documentation"

  git do |git|

    git_branch = 'gh-pages'

    if git_remote = git.remote_for_branch(git_branch)
      pages_url = git.url_for_remote(git_remote)
      clone_dir = ".#{git_branch}"
    elsif git_remote = git.find_remote(/git@github\.com:/)
      git_remote, clone_url = git_remote
      clone_dir = ".clone-#{$$}-#{rand(100)}"
    end

    if pages_url  # inside git repo and found gh-pages branch

      desc "Publish RDoc to GitHub pages on #{git_remote}"
      task 'doc:publish:github' => :doc do
        rm_rf clone_dir

        git.easy_clone pages_url, clone_dir, git_remote

        Dir.chdir(clone_dir) {
          git.checkout_remote_branch git_remote, git_branch

          cp_r Dir["../#{rdoc_task.rdoc_dir}/*"], '.'

          git.add_and_commit 'Updated documentation.'
          git.push git_remote, git_branch
        }
      end

      desc publish_desc; publish_desc = nil
      task 'doc:publish' => 'doc:publish:github'

    elsif clone_url  # still git repo, but no gh-pages branch

      desc "Create #{git_branch} branch on #{git_remote}"
      task 'doc:make_ghpages' do
        git.easy_clone clone_url, clone_dir, git_remote

        Dir.chdir(clone_dir) {
          git.symbolic_ref 'HEAD', "refs/heads/#{git_branch}"

          rm_f '.git/index'
          git.clean '-fdx'

          File.open('index.html', 'w') { |f| f.puts 'My GitHub Page' }

          git.add_and_commit 'First pages commit.'
          git.push git_remote, git_branch
        }

        rm_rf clone_dir

        git.fetch git_remote
      end

    end

  end

  rubyforge do |rf_config|

    rf_project = rf_config[:project]

    rf_rdoc_dir, rf_package = rf_config.values_at(:rdoc_dir, :package)
    rf_rdoc_dir ||= :package if rf_package && rf_package != rf_project
    rf_rdoc_dir = rf_package if rf_package && rf_rdoc_dir == :package

    RDOC_OPTIONS[:rf_rdoc_dir] = rf_rdoc_dir

    desc 'Publish RDoc to RubyForge'
    task 'doc:publish:rubyforge' => :doc do
      rf_user = rf_config[:username]
      abort 'RubyForge user name missing' unless rf_user

      rf_host = "#{rf_user}@rubyforge.org"

      local_dir  = rdoc_task.rdoc_dir
      remote_dir = "/var/www/gforge-projects/#{rf_project}"
      remote_dir = File.join(remote_dir, rf_rdoc_dir) if rf_rdoc_dir

      execute(
        "rsync -av --delete #{local_dir}/ #{rf_host}:#{remote_dir}/",
        "scp -r #{local_dir}/ #{rf_host}:#{remote_dir}/"
      )
    end

    desc publish_desc
    task 'doc:publish' => 'doc:publish:rubyforge'

  end

end
