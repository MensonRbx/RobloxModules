local TRANSPARENCY_STEP = 0.05

local GarbageInfoClass = require(script.Parent:WaitForChild("GarbageInfoClass"))
local EasingStylesConfigFile = require(script:WaitForChild("EasingStylesConfigFile"))

local OnDestroyEffects = script.OnDestroyEffects

local Garbage = {}
Garbage.__index = Garbage

function Garbage.new()
	local self = setmetatable({}, Garbage)
	
	return self
end

--[[
	METHAMETHOD: Roll with it until you get it.
	Function called everytime Object is called like function
]]

function Garbage:__call(instance: Instance, GarbageInfo: table)
	
	GarbageInfo = GarbageInfo or GarbageInfoClass.new()
	local effectContainer: Part
	
	if GarbageInfo.DestroyEffect then
		effectContainer = Instance.new("Part")
		effectContainer.CFrame = self:_GetEffectContainerPosition(instance)
		effectContainer.Parent = workspace
		
		local effect = OnDestroyEffects:FindFirstChild(GarbageInfo.DestroyEffect):Clone()
		effect.Position = effectContainer.Position
		effect.Parent = effectContainer
		effect.Visible = true
		
		--[[
			GitHub users (love you to death), there is a folder for destroy effects in the file this is made in
		]]
		
	end
	
	self:_ProcessItem(instance, GarbageInfo, effectContainer)
	
end

--[[
	Method called for processing item added to service
]]

function Garbage:_ProcessItem(instance: Instance, GarbageInfo: table, effectContainer: Part)
	
	GarbageInfo = GarbageInfo or GarbageInfoClass.new()
	
	local LifeTime = GarbageInfo.LifeTime
	local DoesFade = GarbageInfo.Fade
	
	if DoesFade then
		for i = 0, LifeTime, TRANSPARENCY_STEP do
			self:_FadeRecursive(instance, i, LifeTime)
			task.wait(TRANSPARENCY_STEP)
		end
	else
		task.wait(LifeTime)
	end
	
	instance:Destroy()
	
	if effectContainer then
		effectContainer:Destroy()
	end
	
end

--[[
	Method sets transparency of instance and the recursively performs the method on it's children
]]

function Garbage:_FadeRecursive(instance: Instance, step: number, lifetime: number)
	
	local transparencyValue = step/lifetime
	
	if instance:IsA("BasePart") then
		if not instance:GetAttribute("InitialTransparency") then
			instance:SetAttribute("InitialTransparency", instance.Transparency)
		end
		
		local transDifference = (1 - instance:GetAttribute("InitialTransparency"))
		instance.Transparency = instance:GetAttribute("InitialTransparency") + (transDifference * (step/lifetime))
	end
	
	for _, child in instance:GetChildren() do
		self:_FadeRecursive(child, step, lifetime)
	end
	
end

function Garbage:_GetEffectContainerPosition(instance: Instance)
	if instance:IsA("Model") then
		return instance:GetBoundingBox()
	else
		return instance.CFrame
	end
end

return Garbage.new()

--[[
	MODULE INFO
	Singleton Module designed for destroying objects, similar to Debris but better. Currently includes
	fade out, planning on adding easing styles back into this and more effects.
]]
