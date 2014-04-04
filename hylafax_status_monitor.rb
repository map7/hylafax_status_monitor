#!/usr/bin/env ruby

def get_output(text)
  lines = text.split("\n")
  if lines.count > 1
    text = lines[1]
    text.split(":")[1].strip
  end
end


