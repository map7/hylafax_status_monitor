#!/usr/bin/env ruby

#
# Strip the faxtat output for the status line we are after
#
def get_output(text)
  lines = text.split("\n")
  if lines.count > 1
    text = lines[1]
    text.split(":")[1].strip
  end
end

#
# Return true/false depending on if the status is good or bad.
#
def status(text)
  text == "Initialize server" || text == "Running and idle" || !!(text =~ /Sending Job/)
end
