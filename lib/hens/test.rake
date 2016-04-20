Hen :test do

  test_options = {
    pattern: 'test/**/*_test.rb'
  }.update(config[:test])

  test_files = test_options.delete(:files) ||
      FileList[test_options.delete(:pattern)].to_a

  mangle_files!(test_files, managed: false)

  unless test_files.empty?
    require_lib 'rake/testtask' or next

    Rake::TestTask.new { |t|
      t.test_files = test_files
      set_options(t, test_options, 'Test')
    }
  end

end
