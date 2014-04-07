#!/usr/bin/env ruby
require 'pstore'                # Built in simple store for ruby

FILENAME="/tmp/hylafax_status_failed.db"

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
  if !!(text =~ /Waiting for modem/)
    store = PStore.new(FILENAME)
    timed_status = store.transaction {store[:timed_status]}

    if timed_status == nil
      # Check if this is the first time we have seen this error
      puts "set timed_status to #{Time.now}"
      store.transaction {store[:timed_status] = Time.now}
      true

    elsif Time.now > timed_status
      # Check if this same error has been happening for more than 5 minutes.
      puts "reset timed_status"
      store.transaction {store[:timed_status] = nil}
      false
    else
      true
    end
  else
    text == "Initializing server" || text == "Running and idle" || !!(text =~ /Sending Job/)
  end
end

#
# Have we already sent out a failed status?
#
def sent_status(fax_status)
  store = PStore.new(FILENAME)
  sent = store.transaction {store[:sent]}

  if fax_status && sent
    # Fax is back and working so lets reset the sent flag.
    set_status(false)
    true
  elsif sent == nil
    set_status(false)
    false
  else
    # Return the fail sent status
    sent
  end
end

#
# Set the sent status
#
def set_status(value)
  store = PStore.new(FILENAME)
  store.transaction{store[:sent] = value}
end
