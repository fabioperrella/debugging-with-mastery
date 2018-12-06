!SLIDE center subsection

# Debugging with mastery

## Fabio Perrella

!SLIDE center

# Help others to lose less time debugging like I used to lose

!SLIDE center

# Idea

## Show how I used to do and what I've learnt

!SLIDE center

# Before we start...

!SLIDE smallbullets

# Tools

- pry
  + code inspection
  + beautiful console
- pry-debugger
  + old debugger (before ruby 2.0.0)
- byebug
  + "new" debugger (after ruby 2.0.0)
- pry-byebug
 + pry + byebug (but byebug alone has some advantages!)

!SLIDE smallbullets

# .pryrc

    @@@ Bash
    $ cat ~/.pryrc
    Pry.commands.alias_command 'c', 'continue'
    Pry.commands.alias_command 's', 'step'
    Pry.commands.alias_command 'n', 'next'
    Pry.commands.alias_command 'f', 'finish'
    Pry.commands.alias_command 'w', 'whereami'
    Pry.commands.alias_command 'bt', 'backtrace'

    Pry.config.editor = "vim"

!SLIDE smallbullets

# Snippets (using Sublime Text)

* bp (binding.pry)
  + https://github.com/fabioperrella/dotfiles/blob/master/sublime/pry.sublime-snippet
* bb (byebug)
  + https://github.com/fabioperrella/dotfiles/blob/master/sublime/byebug.sublime-snippet

!SLIDE center subsection

# Problem

## Taking control of the debugger!

!SLIDE smallbullets center

# Case - Netflix fake recommendations app

Uderstanding why serie "Vai Anita" is recommended to everybody!?!?!

https://github.com/fabioperrella/fake-netflix-recommendations

!SLIDE center

# Show me the code!

!SLIDE center

# Understanding the flow of execution to understand the `step(in)` command

!SLIDE

# Code execution tree

    @@@ text
    UserRecommendations.list
    ├── UserRecommendations#list
    │   ├── fetchers
    │   ├── sort_by
    │   │   ├── ItemsFetcher::Main.order
    │   │   ├── ItemsFetcher::Secondary.order
    │   │   ├── ItemsFetcher::Sponsored.order
    │   ├── map
    │   │   ├── ItemsFetcher::Main.fetch
    │   │   │   ├── ItemsFetcher::Main#fetch
    │   │   │   │   ├── ItemsFetcher::Main#main_preferences
    │   │   ├── ItemsFetcher::Secondary.fetch
    │   │   │   ├── ItemsFetcher::Secondary#fetch
    │   │   │   │   ├── ItemsFetcher::Secondary#secondary_preferences
    │   │   ├── ItemsFetcher::Sponsored.fetch
    │   │   │   ├── ItemsFetcher::Sponsored#fetch
    │   │   │   │   ├── ItemsFetcher::Sponsored#fetch
    │   │   │   │   │   ├── each
    │   │   │   │   │   │   ├── SponsoredMetrics.new
    │   │   │   │   │   │   │   ├── SponsoredMetrics#save
    │   │   │   │   │   │   │   │   ├── SponsoredMetrics#key
    │   │   │   │   │   │   │   │   ├── SponsoredMetrics#value
    │   │   │   │   │   │   │   │   ├── Metrics.save
    │   │   │   │   │   │   │   │   │   ├── Rails.cache.save
    │   ├── inject
    │   ├── reject
    │   │   ├── UserRecommendations#watched_items

!SLIDE

# Suggestion

Build a gem to build this tree automatically!

I used the gem `tty-tree` to build it manually

    @@@ ruby
    require 'tty-tree'

    tree = TTY::Tree.new do
      node 'UserRecommendations.list' do
        node 'UserRecommendations#list' do
          node 'fetchers'
          node 'sort_by' do
            node 'ItemsFetcher::Main.order' do
            end
            node 'ItemsFetcher::Secondary.order' do
            end
            node 'ItemsFetcher::Sponsored.order' do
            end
          end
    ...

!SLIDE

# Deep down in the code with byebug

* Add a `binding.pry` in NETFLIX/app/services/user_recommendations.rb:3
* Run test `spec/services/user_recommendations_spec.rb:49`
* Use `play -l` to execute some block of code
* Use `step` to deep down
  * Unfortunately, there is no `step-back` command :(
* Use `finish` to current frame until the end
* Use `up` and `down` to know where in the stack I am, and inspect some variable
* Use `next` to execute the line and go to the next line
* Use `backtrace`, `frame` and `frame(n)` to show and change the current frame
in another frame
* Use `whereami` to show where the debugger is

!SLIDE center

# STEP / UP / DOWN

### If you have only 1 slot to learn something from this talk, save this!

!SLIDE

# Another example in real life

![](../_images/how_to_use_up.png)

Using `up`, `down` and `frame` to understand what happened before it gets in
the breakpoint.

    @@@ ruby
    # PM/lib/recipes_manager/client.rb:6
    class Client
      def post_bundle(bundle)
        binding.pry
        response = http.post('bundles', bundle.as_json)

        return response.body if response.success?

        # ....
      end
    end

!SLIDE

# To help using the `play` command

Good code:

    @@@ ruby
    fetchers
      .sort_by(&:order)
      .map{ |fetcher| fetcher.fetch(user) }
      .inject(:+)
      .reject { |item| watched_items.include?(item) }

    # play -l 1..2
    # play -l 1..3
    # play -l 1..4

Bad code:

    @@@ ruby
    fetchers.sort_by(&:order).map{ |fetcher| fetcher.fetch(user) }.inject(:+).reject { |item| watched_items.include?(item) }

    # play -l 1 :(

!SLIDE

# When you forgot a `binding.pry` and run all tests...

* Use command `edit -c` to edit the current file (`Pry.config.editor` must be configured)
* Remove the `binding.pry`
* Save and close the file
* Continue the execution of the tests!

!SLIDE

# Using `pry` to browse source code regardless of a debug session

* when debugging, the `pry` tools are available (with `pry-byebug`), but when
only in `pry` console, the debug commands are not available
* Use `rails c` to enter the console
* Use `cd` to inspect a class or instance
* Use `nesting` to show where I am
* Use `ls` to show the methods and variables
* Use `show-source` (or `$`) to show the current source
* Use `show-source` to show the source of some method

!SLIDE

# How to exit from a pry console correctly

* When using `ctrl+c`, it always **CRASHES THE TERMINAL !!**
  * Use command `reset` to restore the terminal
* When using `exit`, it exits only the current context
* When uusing `exit!`, it exists the console, no matter where you are

!SLIDE

# To avoid printing a lot of stuff to stdout

Without `;` in the end

    @@@ ruby
    [11] pry(main)> conn = ActiveRecord::Base.connection
    => #<ActiveRecord::ConnectionAdapters::SQLite3Adapter:0x000055e01c45ee60
     @active=true,
     @config={:adapter=>"sqlite3", :pool=>5, :timeout=>5000, :database=>"/home/fabio/workspace/fake-netflix-recommendations/db/development.sqlite3"},
     @connection=
      #<SQLite3::Database:0x000055e01c45f0b8
       @authorizer=nil,
       @busy_handler=nil,
       @collations={},
       @encoding=#<Encoding:UTF-8>,
       @functions={},
       @readonly=false,
       @results_as_hash=true,
    #...

With `;` in the end

    @@@ ruby
    [12] pry(main)> conn = ActiveRecord::Base.connection;
    [13] pry(main)> conn.class
    => ActiveRecord::ConnectionAdapters::SQLite3Adapter

