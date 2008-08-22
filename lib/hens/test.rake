Hen :test do

  require 'rake/testtask'

  test_options = config[:test]

  test_files = test_options.delete(:files) || FileList[test_options.delete(:pattern)]

  if test_files && !test_files.empty?
    Rake::TestTask.new { |t|
      t.test_files = test_files

      test_options.each { |option, value|
        t.send("#{option}=", value)
      }
    }
  end

end
