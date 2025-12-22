#!/usr/bin/env fish

set dropbox_output (~/.local/bin/dropbox status 2>/dev/null)
set exit_code $status

# Defaults
set icon "⚠"
set class "error"
set status_text $dropbox_output

if test $exit_code -ne 0
  set icon "❌"
  set status_text "not running"
else
  switch $dropbox_output
    case "Up to date"
      set icon "✓"
      set class ""
    case "Syncing*"
      set icon "⟳"
      set class "syncing"
    case "Starting...*"
      set icon "⋯"
      set class "syncing"
    case "Upgrading Dropbox...*"
      set icon "⬆"
      set class "syncing"
  end
end

set tooltip "Dropbox: $status_text"
if test -n "$class"
  echo "{\"text\":\"$icon\",\"tooltip\":\"$tooltip\",\"class\":\"$class\"}"
else
  echo "{\"text\":\"$icon\",\"tooltip\":\"$tooltip\"}"
end
