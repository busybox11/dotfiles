if application "Ghostty" is running then
	tell application "Ghostty"
		set aWin to make new window
	end tell
else
	tell application "Ghostty" to activate
end if