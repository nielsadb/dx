#!/usr/bin/env ruby

Entry   = Struct.new(:name, :size, :is_dir, :date, :tags, :parent, :children, keyword_init: true)
Command = Struct.new(:action, :name, :arg, keyword_init: true)
Plugin  = Struct.new(:name, :args, keyword_init: true)
Options = Struct.new(:root, :input, :baseline, :plugins, keyword_init: true)
State   = Struct.new(:roots, :entries, :commands, keyword_init: true)

def main(options)
  print "Running baseline #{options.baseline}\n"
  load(options.baseline)
  s = baseline(options)
  options.plugins.each do |plugin|
    if plugin.args.empty? then
      print "Running #{plugin.name}\n"
    else
      print "Running #{plugin.name} @ #{plugin.args}\n"
    end
    load(plugin.name)
    process(s, plugin.args)
  end
end

def process_argv(argv, options)
  next_mod = nil
  argv.each do |arg|
    case next_mod
    when nil
      case arg
      when '-r', '--root'
        next_mod = 'r'
      when '-i', '--input'
        next_mod = 'i'
      when '-b', '--baseline'
        next_mod = 'b'
      else
        name, args_str = arg.split('@')
        args = (args_str or "").split(',')
        options.plugins.append(Plugin.new(name: name, args: args))
      end
    when 'r'
      options.root = arg
      next_mod = nil
    when 'i'
      options.input = File.open(arg, 'r')
      next_mod = nil
    when 'b'
      options.baseline = arg
      next_mod = nil
    end
  end
  options
end

defaults = Options.new(
  root:     '.',
  input:    STDIN,
  baseline: 'input_find_ls_tag.rb',
  plugins:  []
)
main(process_argv(ARGV, defaults))
