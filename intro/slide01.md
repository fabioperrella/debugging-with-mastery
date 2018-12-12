!SLIDE center subsection

# Debugging with mastery in Ruby

## Fabio Perrella

### Tech Leader @ Locaweb

!SLIDE center

# Help others to lose less time debugging like I used to lose

!SLIDE center

# Idea

## Show how I used to do and what I've learned

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

!SLIDE

# Problem

## Taking control of the debugger!

![](../_images/dog_leash.gif)

!SLIDE

# Netflix fake recommendations app

Understand why the show "Vai Anita" is recommended to everybody!?!?!

https://github.com/fabioperrella/fake-netflix-recommendations

**Warning**: This is a crazy app, just to show some debugging scenarios!

!SLIDE center

# Show me the code!

!SLIDE center

# Understanding the flow of execution to understand the `step(in)` command

!SLIDE smaller

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

1. Add a `binding.pry` in `NETFLIX/app/services/user_recommendations.rb:3`
2. Run test `spec/services/user_recommendations_spec.rb:49`
3. Use `step` to deep down
4. Use `next` to execute the line and go to the next
  * Unfortunately, there is no `step-back` command :(
5. Use `finish` to run the current frame until the end
6. Use `up` and `down` to know where in the stack I am, and inspect some variable
7. Use `next` to execute the line and go to the next line
8. Use `backtrace` and `frame` to show the current frame
9. Use `whereami` to show where the debugger is

!SLIDE center

# STEP / UP / DOWN / FINISH

### If you have only 1 slot to learn something from this talk, save this!

!SLIDE small

# Another example in real life

![](../_images/how_to_use_up.png)

Using `up`, `down` and `frame` to understand what happened before it gets in
the breakpoint.

    @@@ ruby
    # PM/lib/recipes_manager/client.rb:16
    class Client
      def post_bundle(bundle)
        binding.pry
        response = http.post('bundles', bundle.as_json)

        return response.body if response.success?

        # ....
      end
    end

!SLIDE

# Using the `play` command to run lines

Good code (to play):

    @@@ ruby
    fetchers
      .sort_by(&:order)
      .map{ |fetcher| fetcher.fetch(user) }
      .inject(:+)
      .reject { |item| watched_items.include?(item) }

    # play -l 1..2
    # play -l 1..3
    # play -l 1..4

Bad code (to play):

    @@@ ruby
    fetchers.sort_by(&:order).map{ |fetcher| fetcher.fetch(user) }.inject(:+).reject { |item| watched_items.include?(item) }

    # play -l 1 :(

!SLIDE

# Debugging a code inside a block

    @@@ruby
    # app/services/item_remover.rb
    def remove(item)
      binding.pry
      ActiveRecord::Base.transaction do
        UserItemLog.where(item: item).destroy_all
        item.destroy
      end
    end

- Avoid using `step` to go into the block
- Use `break [LINE]` and `continue` for the win!

!SLIDE smaller

# Debugging a code inside a loop

    @@@ ruby
    # app/services/create_preference.rb
    def create(name, items)
      binding.pry
      ActiveRecord::Base.transaction do
        items.each do |item|
          item.preferences << name

          item.user_item_logs.each do |item_log|
            user = item_log.user
            unless user.preferences.include?(name)
              user.preferences << name
              user.save!
            end
          end

          item.save!
        end
      end
    end

- Use `break 10 if user.id == x` to not stop in each element
- Use `break` to list breakpoints
- Use `break --delete x` to delete a breakpoint

!SLIDE

# When you forgot a `binding.pry` and run all tests...

* Use command `edit -c` to edit the current file (`Pry.config.editor` must be configured)
* Remove the `binding.pry`
* Save and close the file
* Continue the execution of the tests!

!SLIDE center

# Now, some `pry` stuff...

!SLIDE

# Using `pry` to browse source code regardless of a debug session

1. when debugging, the `pry` tools are available (with `pry-byebug`), but when
only in `pry` console, the debug commands are not available
2. Use `rails c` to enter the console
3. Use `cd` to inspect a class or instance
4. Use `nesting` to show where I am
5. Use `ls` to show the methods and variables
6. Use `ls --grep XX` to filter the result of `ls`
7. Use `show-source` (or `$`) to show the current source
8. Use `show-source` to show the source of some method

!SLIDE smaller

# Using show-doc to show the docs

Use `show-doc` do show the docs (requires gem `pry-doc`):

    @@@ruby
    [2] pry> show-doc Array#all?

    From: enum.c (C Method):
    Owner: Enumerable
    Visibility: public
    Signature: all?(*arg1)
    Number of lines: 16

    Passes each element of the collection to the given block. The method
    returns true if the block never returns
    false or nil. If the block is not given,
    Ruby adds an implicit block of { |obj| obj } which will
    cause #all? to return true when none of the collection members are
    false or nil.

    If instead a pattern is supplied, the method returns whether
    pattern === element for every collection member.

       %w[ant bear cat].all? { |word| word.length >= 3 } #=> true
       %w[ant bear cat].all? { |word| word.length >= 4 } #=> false
       %w[ant bear cat].all?(/t/)                        #=> false
       [1, 2i, 3.14].all?(Numeric)                       #=> true
       [nil, true, 99].all?                              #=> false
       [].all?                                           #=> true


!SLIDE small

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
    #...

With `;` in the end

    @@@ ruby
    [12] pry(main)> conn = ActiveRecord::Base.connection;
    [13] pry(main)> conn.class
    => ActiveRecord::ConnectionAdapters::SQLite3Adapter

!SLIDE small

# Catching the last exception with `_ex_`

    @@@ruby
    [1] pry> 1/0
    ZeroDivisionError: divided by 0
    from (pry):1:in `/`
    [2] pry> _ex_
    => #<ZeroDivisionError: divided by 0>

And it is possible to find where it was raised with `cat --ex`:

    @@@ruby
    [3] pry> cat --ex

    Exception: ZeroDivisionError: divided by 0
    --
    From: (pry) @ line 5 @ level: 0 of backtrace (of 82).

        1: 1/0
        2: _ex_
        3: Item.new
        4: aa = _
     => 5: 1/0
        6: _ex_


!SLIDE

# Getting the last result with `_`

    @@@ruby
    [1] pry> Item.new
    => #<Item:0x00005578e8d1dba0 id: nil, name: nil, #...
    [2] pry> item = _
    => #<Item:0x00005578e8d1dba0 id: nil, name: nil, #...

!SLIDE

# Pry input buffer

Given the code below

    @@@ ruby
    pry(main)> def do_something
    pry(main)*   if x == 1
    pry(main)*     puts 'sim'
    pry(main)*   else

- Use command `edit` to edit the input buffer
- Use command `show-input` to show
- Use command `edit` to edit
- Use `!` to clear

!SLIDE

# Executing shell commands

Use `.` (dot) and a command, example:

    @@@ruby
    pry> .ruby -v
    ruby 2.5.3p105 (2018-10-18 revision 65156) [x86_64-linux]

    pry> .pwd
    /home/fabio/workspace/fake-netflix-recommendations

!SLIDE

# How to exit from a pry console

* When using `ctrl+c`, it always **CRASHES THE TERMINAL !!**
  * Use the command `reset` to restore the terminal
* When using `exit`, it exits only the current context
* When using `exit!`, it exists the console, no matter where you are

!SLIDE smaller

# Finish him! Questions??

I have a question!

## Pics

The source of this presentation: https://github.com/fabioperrella/debugging-with-mastery

This presentation was made with the gem **Showoff**: https://github.com/puppetlabs/showoff

How to find a subject to do a presentation: http://www.greaterthancode.com/2016/11/21/008-sandi-metz-and-katrina-owen/

## Me

https://github.com/fabioperrella

http://twitter.com/fabioperrella

## Work at Locaweb

https://www.locaweb.com.br/carreira
