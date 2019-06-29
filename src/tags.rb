
def process(state, args)
  tags = if args.empty? then ['Green'] else args end
  state.roots.select! do |root|
    tags.all? do |tag|
      state.entries[root].tags.include?(tag)
    end
  end
end