
def process(state, args)
  filters_file = args[0] || 'filters.txt'
  raise "Filter file #{filters_file} does not exist!" unless File.exist?(filters_file)
  File.open(filters_file).each do |line|
  end
end
