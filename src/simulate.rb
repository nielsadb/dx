def delete_entry(state, name)
  entry = state.entries[name]
  if state.entries[entry.parent] then
    state.entries[entry.parent].children.delete(name)
  end
  state.entries.delete(name)
  state.roots.delete(name)
end

def process(state, args)
  state.commands.delete_if do |cmd|
    name = cmd.name
    entry = state.entries[name]
    fail "cannot find entry #{cmd}" unless entry
    parent = state.entries[entry.parent] if entry.parent
    case cmd.action
    when :delete
      delete_entry(state, name)
      true
    when :moveup
      fail "Cannot move out of root scope." unless parent
      delete_entry(state, name)
      new_name = File.join(File.dirname(parent.name), File.basename(name))
      entry.name = new_name
      state.entries[new_name] = entry
      if parent.parent then
        entries[parent.parent].children.append(new_name)
      else
        state.roots.append(new_name)
      end
      true
    when :rename
      delete_entry(state, name)
      entry.name = cmd.arg
      state.entries[cmd.arg] = entry
      if parent then
        parent.children.append(cmd.arg)
      else
        state.roots.append(cmd.arg)
      end
      true
    else
      pp cmd
      fail "unknown commnd!"
      false
    end
  end
end