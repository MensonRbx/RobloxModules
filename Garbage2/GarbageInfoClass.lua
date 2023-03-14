local GarbageInfo = {}
GarbageInfo.__index = GarbageInfo

function GarbageInfo.new(fade: boolean, LifeTime: number, DestroyEffect: any)	
	return {Fade = fade or true, LifeTime = LifeTime or 0, DestroyEffect = DestroyEffect or nil}
end

return GarbageInfo

--[[

	PURPOSE OF MODULE/OBJECT
	Act as container for Information for items collected by GarbageService

]]
