!SLIDE center subsection

# Debugging with mastery

## Fabio Perrella

!SLIDE center

# Try to help others to lose less time debugging like I used to lose

!SLIDE center

# Idea

## Try to show how I used to do and what I've learnt

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

Try to uderstand why serie "Vai Anita" is recommended to every one!?!?!

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

!SLIDE

# Deep down in the code with byebug

* Add a `binding.pry` in NETFLIX/app/services/user_recommendations.rb:3
* Run test `spec/services/user_recommendations_spec.rb:49`
* Use `play -l` to execute some block of code
* Use `step` to deep down
* Unfortunately, there is no `step-back` command :(
* Use `next` to execute the line and go to the next line
* Use `finish` to current frame until the end
* Use `up` and `down` to know where in the stack I am, and inspect some variable
in another frame
* Use `backtrace`, `frame` and `frame(n)` to show and change the current frame
* Use `whereami` to show where the debugger is

!SLIDE

# Another example in real life

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

# Editing the current code inside a debug session

* Add a `binding-pry`
* Run all tests
* Use command `edit -c` (current file) to remove the `binding.pry` and continue

!SLIDE

# Using pry commands to navigate around state

*
* `cd`
* `nesting`
* `ls`