
# Expected input on stream is as output by the following command:
#   find . -exec ls -ldT {} + -exec tag {} +
#
# The root directory may be included in the results, it will be ignored.

require './index.rb'
require 'set'

def parse_stream(stream, idx)
  stream.each do |line|
    ls = line.match /^(.)\S+\s+\d+\s+\S+\s+\S+\s+(\d+)\s+(\S+)\s+(\d+)\s+(\d+):(\d+):(\d+)\s+(\d+)\s+(.+)$/
    if ls then
      idx.touch(
        name: ls[9],
        size: ls[2].to_i,
        type: if ls[1] == 'd' then :dir else :file end,
        date: Time.local(ls[8].to_i, ls[3], ls[4], ls[5].to_i, ls[6].to_i, ls[7].to_i))
    else
      tag = line.match /^([^\t]+)\t(\S+)$/
      if tag then
        idx.touch(name: tag[1], tags: tag[2].split(',').to_set)
      end
    end
  end
end
