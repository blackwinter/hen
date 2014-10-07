var search_data = {"index":{"searchIndex":["hen","cli","commands","dsl","file","version","object","hen()","hen!()","[]()","[]()","_hen_original_ask()","add_hen()","ask()","ask!()","call_block()","classname()","config()","config()","config()","create()","create_git()","create_path()","create_skel()","default_classname()","default_emailaddress()","default_fullname()","default_githubuser()","default_henrc()","emailaddress()","execute()","extend_object()","find_henrc()","fullname()","gemcutter()","git()","gitconfig()","githubuser()","h()","have_git?()","have_rubygems?()","have_svn?()","have_task?()","help()","henconfig()","henrc()","init_git()","init_rubygems()","init_svn()","laid?()","lay!()","list()","load_config()","load_hens()","mangle_files!()","mangle_target()","map_options()","method_missing()","missing_lib()","new()","progdesc()","progname()","progsumm()","pseudo_object()","render()","resolve_args()","rubygems()","set_options()","skipping()","svn()","task!()","tasks()","to_a()","to_s()","usage()","verbose()","version()","copying","changelog","readme"],"longSearchIndex":["hen","hen::cli","hen::commands","hen::dsl","hen::file","hen::version","object","object#hen()","object#hen!()","hen#[]()","hen::commands#[]()","hen::cli#_hen_original_ask()","hen#add_hen()","hen::cli#ask()","hen::cli#ask!()","hen::dsl#call_block()","hen::cli#classname()","hen#config()","hen::commands#config()","hen::dsl#config()","hen::commands#create()","hen::commands#create_git()","hen::commands#create_path()","hen::commands#create_skel()","hen::cli#default_classname()","hen::cli#default_emailaddress()","hen::cli#default_fullname()","hen::cli#default_githubuser()","hen#default_henrc()","hen::cli#emailaddress()","hen::dsl#execute()","hen::dsl#extend_object()","hen#find_henrc()","hen::cli#fullname()","hen::dsl#gemcutter()","hen::dsl#git()","hen::cli#gitconfig()","hen::cli#githubuser()","hen::commands#h()","hen::dsl#have_git?()","hen::dsl#have_rubygems?()","hen::dsl#have_svn?()","hen::dsl#have_task?()","hen::commands#help()","hen::cli#henconfig()","hen#henrc()","hen::dsl#init_git()","hen::dsl#init_rubygems()","hen::dsl#init_svn()","hen#laid?()","hen#lay!()","hen::commands#list()","hen#load_config()","hen#load_hens()","hen::dsl#mangle_files!()","hen::commands#mangle_target()","hen::dsl#map_options()","hen::commands#method_missing()","hen::dsl#missing_lib()","hen::new()","hen::cli#progdesc()","hen::cli#progname()","hen::cli#progsumm()","hen::dsl#pseudo_object()","hen::cli#render()","hen#resolve_args()","hen::dsl#rubygems()","hen::dsl#set_options()","hen::dsl#skipping()","hen::dsl#svn()","hen::dsl#task!()","hen::dsl#tasks()","hen::version#to_a()","hen::version#to_s()","hen::commands#usage()","hen#verbose()","hen::commands#version()","","",""],"info":[["Hen","","Hen.html","","<p>The class handling the program logic. This is what you use in your\nRakefile. See the README for more …\n"],["Hen::CLI","","Hen/CLI.html","","<p>Some helper methods used by the Hen executable. Also available for use in\ncustom project skeletons.\n"],["Hen::Commands","","Hen/Commands.html","",""],["Hen::DSL","","Hen/DSL.html","","<p>Some helper methods for use inside of a Hen definition.\n"],["Hen::File","","Hen/File.html","",""],["Hen::Version","","Hen/Version.html","",""],["Object","","Object.html","",""],["Hen","Object","Object.html#method-i-Hen","(args, &block)","<p>Delegates to Hen.new.\n"],["Hen!","Object","Object.html#method-i-Hen-21","(args, &block)","<p>Delegates to Hen.new, but overwrites any existing hen with the same name.\n"],["[]","Hen","Hen.html#method-i-5B-5D","(hen)","<p>Get <code>hen</code> by name.\n"],["[]","Hen::Commands","Hen/Commands.html#method-i-5B-5D","(arg)",""],["_hen_original_ask","Hen::CLI","Hen/CLI.html#method-i-_hen_original_ask","(key, default = nil, cached = true)",""],["add_hen","Hen","Hen.html#method-i-add_hen","(hen, overwrite = false)","<p>Adds <code>hen</code> to the global container. Overwrites an existing hen\nonly if <code>overwrite</code> is true.\n"],["ask","Hen::CLI","Hen/CLI.html#method-i-ask","(key, default = nil, cached = true)","<p>Ask the user to enter an appropriate value for <code>key</code>. Uses\nalready stored answer if present, unless <code>cached</code> …\n"],["ask!","Hen::CLI","Hen/CLI.html#method-i-ask-21","(key, default = nil, max = 3)","<p>Same as #ask, but requires a non-empty value to be entered.\n"],["call_block","Hen::DSL","Hen/DSL.html#method-i-call_block","(block, *args, &block2)","<p>Calls block <code>block</code> with <code>args</code>, appending an\noptional passed block if requested by <code>block</code>.\n"],["classname","Hen::CLI","Hen/CLI.html#method-i-classname","(default = default_classname)","<p>The project&#39;s namespace. (Required)\n<p>Namespaces SHOULD match the project name in SnakeCase.\n"],["config","Hen","Hen.html#method-i-config","(key = nil)","<p>The configuration resulting from the user&#39;s <code>.henrc</code>. Takes\noptional <code>key</code> argument as “path” …\n"],["config","Hen::Commands","Hen/Commands.html#method-i-config","()",""],["config","Hen::DSL","Hen/DSL.html#method-i-config","()","<p>The Hen configuration.\n"],["create","Hen::Commands","Hen/Commands.html#method-i-create","()",""],["create_git","Hen::Commands","Hen/Commands.html#method-i-create_git","(path, created)",""],["create_path","Hen::Commands","Hen/Commands.html#method-i-create_path","(path, created)",""],["create_skel","Hen::Commands","Hen/Commands.html#method-i-create_skel","(path, skel, created, replace)",""],["default_classname","Hen::CLI","Hen/CLI.html#method-i-default_classname","()","<p>Determine a suitable default namespace from the project name.\n"],["default_emailaddress","Hen::CLI","Hen/CLI.html#method-i-default_emailaddress","()","<p>Determine a default e-mail address from the global config or from the Git\nconfig.\n"],["default_fullname","Hen::CLI","Hen/CLI.html#method-i-default_fullname","()","<p>Determine a default name from the global config or from the Git config or,\nif available, from the GECOS …\n"],["default_githubuser","Hen::CLI","Hen/CLI.html#method-i-default_githubuser","()","<p>Determine a default GitHub user name from the global config or from the Git\nconfig.\n"],["default_henrc","Hen","Hen.html#method-i-default_henrc","()","<p>The path to a suitable default <code>.henrc</code> location.\n"],["emailaddress","Hen::CLI","Hen/CLI.html#method-i-emailaddress","(default = default_emailaddress)","<p>The author&#39;s e-mail address. (Optional, but highly recommended)\n"],["execute","Hen::DSL","Hen/DSL.html#method-i-execute","(*commands)","<p>Find a command that is executable and run it. Intended for\nplatform-dependent alternatives (Command  …\n"],["extend_object","Hen::DSL","Hen/DSL.html#method-i-extend_object","(object, *blocks, &block2)","<p>Extend <code>object</code> with given <code>blocks</code>.\n"],["find_henrc","Hen","Hen.html#method-i-find_henrc","(must_exist = true)","<p>Returns all readable <code>.henrc</code> files found in the (optional)\nenvironment variable <code>HENRC</code> and in each directory …\n"],["fullname","Hen::CLI","Hen/CLI.html#method-i-fullname","(default = default_fullname)","<p>The author&#39;s full name. (Required)\n"],["gemcutter","Hen::DSL","Hen/DSL.html#method-i-gemcutter","(&block)","<p>DEPRECATED: Use #rubygems instead.\n"],["git","Hen::DSL","Hen/DSL.html#method-i-git","()","<p>Encapsulates tasks targeting at Git, skipping those if the current project\nis not controlled by Git. …\n"],["gitconfig","Hen::CLI","Hen/CLI.html#method-i-gitconfig","(*key)","<p>Find <code>key</code> in the Git config and return its non-empty value.\n"],["githubuser","Hen::CLI","Hen/CLI.html#method-i-githubuser","(default = default_githubuser)","<p>The author&#39;s GitHub user name. (Optional)\n"],["h","Hen::Commands","Hen/Commands.html#method-i-h","()",""],["have_git?","Hen::DSL","Hen/DSL.html#method-i-have_git-3F","()","<p>Checks whether the current project is managed by Git.\n"],["have_rubygems?","Hen::DSL","Hen/DSL.html#method-i-have_rubygems-3F","()","<p>Loads the RubyGems <code>push</code> command, giving a nicer error message\nif it&#39;s not found.\n"],["have_svn?","Hen::DSL","Hen/DSL.html#method-i-have_svn-3F","()","<p>Checks whether the current project is managed by SVN.\n"],["have_task?","Hen::DSL","Hen/DSL.html#method-i-have_task-3F","(t)","<p>Return true if task <code>t</code> is defined, false otherwise.\n"],["help","Hen::Commands","Hen/Commands.html#method-i-help","()",""],["henconfig","Hen::CLI","Hen/CLI.html#method-i-henconfig","(*key)","<p>Find <code>key</code> in the global config and return its non-empty value.\n"],["henrc","Hen","Hen.html#method-i-henrc","()","<p>The paths to the user&#39;s <code>.henrc</code> files.\n"],["init_git","Hen::DSL","Hen/DSL.html#method-i-init_git","()","<p>Prepare the use of Git. Returns the Git (pseudo-)object.\n"],["init_rubygems","Hen::DSL","Hen/DSL.html#method-i-init_rubygems","()","<p>Prepare the use of RubyGems.org. Returns the RubyGems (pseudo-)object.\n"],["init_svn","Hen::DSL","Hen/DSL.html#method-i-init_svn","()","<p>Prepare the use of SVN. Returns the SVN (pseudo-)object.\n"],["laid?","Hen","Hen.html#method-i-laid-3F","()","<p>Keeps track of whether the block has already been executed.\n"],["lay!","Hen","Hen.html#method-i-lay-21","(*args)","<p>Loads the hens, causing them to lay their eggs^H^H^Htasks. Either all, if\nno restrictions are specified, …\n"],["list","Hen::Commands","Hen/Commands.html#method-i-list","()",""],["load_config","Hen","Hen.html#method-i-load_config","()","<p>Load the configuration from the user&#39;s <code>.henrc</code> files.\n"],["load_hens","Hen","Hen.html#method-i-load_hens","(*hens, &block)","<p>Actually loads the hen files for <code>hens</code>, or all available if\nnone are specified. If a block is given, only …\n"],["mangle_files!","Hen::DSL","Hen/DSL.html#method-i-mangle_files-21","(*args)","<p>Clean up the file lists in <code>args</code> by removing duplicates and\neither deleting any files that are not managed …\n"],["mangle_target","Hen::Commands","Hen/Commands.html#method-i-mangle_target","(path, sample, git)",""],["map_options","Hen::DSL","Hen/DSL.html#method-i-map_options","(options)","<p>Map <code>options</code> hash to array of command line arguments.\n"],["method_missing","Hen::Commands","Hen/Commands.html#method-i-method_missing","(method, *)",""],["missing_lib","Hen::DSL","Hen/DSL.html#method-i-missing_lib","(lib, do_warn = $DEBUG)","<p>Warn about missing library <code>lib</code> (if <code>do_warn</code> is\ntrue) and return false.\n"],["new","Hen","Hen.html#method-c-new","(args, overwrite = false, &block)","<p>Creates a new Hen instance of a certain name and optional dependencies; see\n#resolve_args for details …\n"],["progdesc","Hen::CLI","Hen/CLI.html#method-i-progdesc","(default = nil)","<p>A long description of the project. (Optional)\n"],["progname","Hen::CLI","Hen/CLI.html#method-i-progname","(default = nil)","<p>The project name. (Required)\n<p>Quoting the Ruby Packaging Standard:\n<p>Project names SHOULD only contain underscores …\n"],["progsumm","Hen::CLI","Hen/CLI.html#method-i-progsumm","(default = nil)","<p>A short summary of the project&#39;s description. (Required)\n"],["pseudo_object","Hen::DSL","Hen/DSL.html#method-i-pseudo_object","(&block)","<p>Create a (pseudo-)object.\n"],["render","Hen::CLI","Hen/CLI.html#method-i-render","(sample, target)","<p>Renders the contents of <code>sample</code> as an ERb template, storing the\nresult in <code>target</code>. Returns the content. …\n"],["resolve_args","Hen","Hen.html#method-i-resolve_args","(args)","<p>Splits into hen name and optional dependencies: <code>args</code> may be a\nsingle symbol (or string), or a hash with …\n"],["rubygems","Hen::DSL","Hen/DSL.html#method-i-rubygems","(&block)","<p>Encapsulates tasks targeting at RubyGems.org, skipping those if\nRubyGem&#39;s &#39;push&#39; command …\n"],["set_options","Hen::DSL","Hen/DSL.html#method-i-set_options","(object, options, type = object.class)","<p>Set <code>options</code> on <code>object</code> by calling the\ncorresponding setter method for each option; warns about illegal …\n"],["skipping","Hen::DSL","Hen/DSL.html#method-i-skipping","(name, do_warn = Hen.verbose)","<p>Warn about skipping tasks for <code>name</code> (if <code>do_warn</code> is\ntrue) and return nil.\n"],["svn","Hen::DSL","Hen/DSL.html#method-i-svn","()","<p>Encapsulates tasks targeting at SVN, skipping those if the current project\nis not controlled by SVN. …\n"],["task!","Hen::DSL","Hen/DSL.html#method-i-task-21","(t, *args, &block)","<p>Define task <code>t</code>, but overwrite any existing task of that name!\n(Rake usually just adds them up.)\n"],["tasks","Hen::DSL","Hen/DSL.html#method-i-tasks","()","<p>Get a handle on the currently defined tasks.\n"],["to_a","Hen::Version","Hen/Version.html#method-i-to_a","()","<p>Returns array representation.\n"],["to_s","Hen::Version","Hen/Version.html#method-i-to_s","()","<p>Short-cut for version string.\n"],["usage","Hen::Commands","Hen/Commands.html#method-i-usage","()",""],["verbose","Hen","Hen.html#method-i-verbose","()","<p>Delegates to Hen.verbose.\n"],["version","Hen::Commands","Hen/Commands.html#method-i-version","()",""],["COPYING","","COPYING.html","","<p>License for hen\n\n<pre>                    GNU AFFERO GENERAL PUBLIC LICENSE\n                       Version 3, ...</pre>\n"],["ChangeLog","","ChangeLog.html","","<p>Revision history for hen\n<p>0.7.0 [2014-10-07]\n<p>Require at least Ruby 1.9.3.\n"],["README","","README.html","","<p>hen - Just a Rake helper\n<p>VERSION\n<p>This documentation refers to hen version 0.7.0\n"]]}}