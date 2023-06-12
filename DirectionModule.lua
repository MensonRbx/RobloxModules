--[[
Taken from the dash script, thought this should be separate.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character
local humanoidRootPart: BasePart = character:WaitForChild("HumanoidRootPart")

local DirectionModule = {}
DirectionModule.__index = DirectionModule

function DirectionModule.new()
	local self = setmetatable({}, DirectionModule)
	
	self.newPosition = humanoidRootPart.Position
	self.lastPosition = humanoidRootPart.Position
	
	RunService.PreRender:Connect(function(...) self:_RecordDirection(...) end)
	
	return self
end

function DirectionModule:_RecordDirection(dt)
	self.newPosition = character.HumanoidRootPart.Position

	local direction = (self.newPosition - self.lastPosition).Unit
	
	--print((self.newPosition - self.lastPosition).Magnitude / dt)

	local forwardDot = character.HumanoidRootPart.CFrame.LookVector:Dot(direction)
	local rightDot = character.HumanoidRootPart.CFrame.RightVector:Dot(direction)
	
	if forwardDot > 0.5 then
		self.movementDirection = "Forwards"
	elseif forwardDot < -0.5 then
		self.movementDirection = "Backwards"
	end
	
	if rightDot > 0.5 then
		if self.movementDirection == "Backwards" then
			self.movementDirection = "BackRight"
		elseif self.movementDirection == "Forwards" then
			self.movementDirection = "ForwardRight"
		else
			self.movementDirection = "Right"
		end
	elseif rightDot < -0.5 then
		if self.movementDirection == "Backwards" then
			self.movementDirection = "BackLeft"
		elseif self.movementDirection == "Forwards" then
			self.movementDirection = "ForwardLeft"
		else
			self.movementDirection = "Left"
		end
	end
	
	print(self.movementDirection)
		
	self.lastPosition = self.newPosition
end

return DirectionModule.new()
