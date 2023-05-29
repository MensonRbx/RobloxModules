--[[
  Right, so this may be a bit useless, but basically this is a table that automatically removes stuff from itself.

        .-""""""-.
      .'          '.
     /   O      O   \
    :           `    :
    |                |   
    :    .------.    :
     \  '        '  /
      '.          .'
        '-......-'

]]

local CACHE_TIMEOUT = 60

local TimedCache = {}
local ContentMetatable = {}

function TimedCache.new()
	local self = setmetatable({}, TimedCache)
	
	return self
end

function TimedCache:__newindex(key, value)
	rawset(self, key, value)
	task.delay(CACHE_TIMEOUT, rawset, self, key, nil)	
	return self
end

return TimedCache
