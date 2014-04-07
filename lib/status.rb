#!/usr/bin/env ruby

require 'pstore'

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
  text == "Initialize server" || text == "Running and idle" || !!(text =~ /Sending Job/)
end

#
# Have we already sent out a failed status?
#
def sent_status(fax_status)
  store = PStore.new(FILENAME)
  sent = store.transaction {store[:sent]}

  if fax_status && sent
    # Fax is back and working so lets reset the sent flag.
    store.transaction{store[:sent] = false}
    true
  else
    # Return the fail sent status
    sent
  end
end

