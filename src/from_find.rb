
# Expected input on stream is as output by the following command:
#   find . -exec stat -f "%z %m %N%T" {} + -exec tag {} +
#
# The root directory may be included in the results, it will be ignored.

require './index.rb'
require 'set'

def parse_stream(stream, idx)
  stream.each do |line|
    stat = line.match /^([\*\/]?) (\d+) (\d+) (.+)$/
    if stat then
      idx.touch(
        name: stat[4],
        size: stat[2].to_i,
        type: if stat[1] == '/' then :dir else :file end,
        date: Time.at(stat[3].to_i))
    else
      tag = line.match /^([^\t]+)\t(\S+)$/
      if tag then
        idx.touch(name: tag[1], tags: tag[2].split(',').to_set)
      else
        # ignore: tag output just the file-nae if there is no tag.
        # difficult to discriminate from real error.
      end
    end
  end
end
