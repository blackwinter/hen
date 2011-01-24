Hen :rdoc do

  require 'rake/rdoctask'

  rdoc_options = config[:rdoc]

  rdoc_options[:title] ||= begin
    title = 'Application documentation'

    if name = config[:gem][:name] || config[:rubyforge][:package]
      title.insert(0, "#{name} ")
    end

    if version = config[:gem][:version]
      title << " (v#{version})"
    end

    title
  end

  ### rdoc_dir

  rdoc_dir = rdoc_options.delete(:rdoc_dir)

  ### rdoc_files

  rdoc_files = FileList[rdoc_options.delete(:rdoc_files)].
    sort.uniq.select { |file| File.exists?(file) }

  ### rdoc_options

  rdoc_options.delete(:main) unless rdoc_files.include?(rdoc_options[:main])

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
    rdoc_task = Rake::RDocTask.new(:doc) { |rdoc|
      rdoc.rdoc_dir   = rdoc_dir
      rdoc.rdoc_files = rdoc_files
      rdoc.options    = rdoc_options
    }
  else
    task :doc do
      warn 'No files to generate documentation for!'
    end
  end

begin
  rubyforge do |rf_config|

    desc 'Publish RDoc to Rubyforge'
    task :publish_docs => :doc do
      rf_project = rf_config[:project]
      abort 'Rubyforge project name missing' unless rf_project

      rf_user = rf_config[:username]
      abort 'Rubyforge user name missing' unless rf_user

      rf_host = "#{rf_user}@rubyforge.org"

      local_dir  = rdoc_task.rdoc_dir
      remote_dir = "/var/www/gforge-projects/#{rf_project}"

      if rdoc_dir = rf_config[:rdoc_dir]
        if rf_package = rf_config[:package]
          rdoc_dir = rf_package if rdoc_dir == :package
        end

        remote_dir = File.join(remote_dir, rdoc_dir)
      end

      execute(
        "rsync -av --delete #{local_dir}/ #{rf_host}:#{remote_dir}/",
        "scp -r #{local_dir}/ #{rf_host}:#{remote_dir}/"
      )
    end

  end
rescue RuntimeError => err
  raise unless err.to_s == 'Skipping Rubyforge tasks'

  git do |git|

    git_branch = 'gh-pages'

    if git_remote = git.remote_for_branch(git_branch)
      pages_url = git.url_for_remote(git_remote)
      clone_dir = ".#{git_branch}"
    elsif git_remote = git.find_remote(/git@github\.com:/)
      git_remote, clone_url = git_remote.split[0..1]
      clone_dir = ".clone-#{$$}-#{rand(100)}"
    end

    if pages_url  # inside git repo and found gh-pages branch

      desc "Publish RDoc to GitHub pages"
      task :publish_docs => :doc do
        rm_rf clone_dir

        git.easy_clone pages_url, clone_dir, git_remote

        Dir.chdir(clone_dir) {
          git.checkout_remote_branch git_remote, git_branch

          cp_r Dir["../#{rdoc_task.rdoc_dir}/*"], '.'

          git.add_and_commit 'Updated documentation.'
          git.push git_remote, git_branch
        }
      end

    elsif clone_url  # still git repo, but no gh-pages branch

      desc "Create #{git_branch} branch on #{git_remote}"
      task :make_ghpages do
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
end

end
