!SLIDE center subsection

# Debugging with mastery

## Fabio Perrella

!SLIDE center

# Help others to lose less time debugging like I used to

!SLIDE center

# Idea

## Try to show how I used to do and what I've learnt

!SLIDE center

# Before we start...

!SLIDE smallbullets

# Tools

- Pry
  + code inspection
  + beautiful console
- Pry-debugger
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

    begin
      require 'awesome_print'
      Pry.config.print = proc { |output, value| Pry::Helpers::BaseHelpers.stagger_output("=> #{value.ai}", output) }
    rescue LoadError => err
     puts "no awesome_print :("
    end

!SLIDE smallbullets

# Snippets (using sublimetext)

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

# Understanding the flow of execution to understand the "step in" command

!SLIDE smallbullets

# Byebug commands

- next (n)
- step (s)
- finish (f)
- up
- down (d)
- backtrace (bt)
- frame

!SLIDE

# Example

## Using byebug commands to help debugging

    @@@ ruby
    # example1.rb
    require 'pry-byebug'

    def add_two(number)
      # binding.pry # try here to show up, down
      number + 2
    end

    def add_four(number)
      number + 4
    end

    binding.pry
    if add_two(2) > 1 && add_four(2) != 2
      puts(add_four(add_two(3) + add_four(8)))
    end

!SLIDE

# Example in real life

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

# Example in real life (pt 2)

Using `step`, `finish`, `next`, `break`, `continue`, `play`, and `edit` to
deep down in the code.

    @@@ ruby
    # PM/app/services/bundle_service.rb:25
    def create(raw_bundle)
      binding.pry
      result = build_bundle(raw_bundle)
      return result if result.value.unnecessary?

      Validation.adequate_transaction do
        result.on_success(post_build_validator)
          .on_success(Bundle::Validator::PendingBundle)
          .on_success { |bundle| bundle.tap(&:save!) }
          .on_success(post_creation_validator)
          .on_success(send_to_recipes_manager(add_plan_recipe: false))
          .on_success(clear_transient_configurations)
      end
    end