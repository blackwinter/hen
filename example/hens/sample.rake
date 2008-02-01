# Add File.dirname(__FILE__) to your HENPATH environment variable -- et voilà.

# Meet your 'sample' hen
Hen :sample do

  # Access options set in your .henrc or project Rakefile
  sample_options = config[:sample]

  # Define your tasks
  desc "Like some tea?"
  task :make_tea do
    puts <<'TEA'
             (  )   (   )  )
              ) (   )  (  (
              ( )  (    ) )
              _____________
             <_____________> ___
             |             |/ _ \
             |               | | |
             |               |_| |
          ___|             |\___/
         /    \___________/    \
         \_____________________/

<http://www.afn.org/~afn39695/potier.htm>
TEA
  end

  # and so on...

end
