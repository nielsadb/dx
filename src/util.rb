
def merge_sets(s1, s2)
  if s2 then
    s1.clone.merge(s2).freeze
  else
    s1
  end
end
