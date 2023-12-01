local function formatTime(number): string
	local finalString = ""
	local minutes = math.floor(number / 60)
	local seconds = math.floor(number - (60 * minutes))
	local milliseconds = math.floor((number - (60 * minutes) - seconds) * 1000)

	if minutes < 10 then
		minutes = "0"..minutes
	end

	if seconds < 10 then
		seconds = "0"..seconds
	end

	if milliseconds < 10 then
		milliseconds = "00"..milliseconds
	elseif milliseconds < 100 then
		milliseconds = "0"..milliseconds
	else
		milliseconds = milliseconds
	end

	finalString = minutes..":"..seconds..":"..milliseconds

	return finalString
end

return formatTime
