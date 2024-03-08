function t
  if test (count $argv) -eq 0
    set session (sesh list -tz | fzf)
    if test -n "$session"
      sesh connect $session
    end
  else
    sesh connect $argv
  end
end
