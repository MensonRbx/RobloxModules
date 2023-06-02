print("Loading script")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local DISTANCE_IN_STUDS = 10
local SPEED = 70

local BEGIN_INPUT_STATE = Enum.UserInputState.Begin

local LOW_PRIORITY = Enum.ContextActionPriority.Low.Value
local MEDIUM_PRIORITY = Enum.ContextActionPriority.Medium.Value
local HIGH_PRIORITY = Enum.ContextActionPriority.High.Value

local moveToMap = {
	W = Vector3.new(0, 0, -30),
	A = Vector3.new(-30, 0, 0),
	S = Vector3.new(0, 0, 30),
	D = Vector3.new(30, 0, 0),
}

local localPlayer = Players.LocalPlayer

local DashScript = {}
DashScript.__index = DashScript

function DashScript.new()
	local self = setmetatable({}, DashScript)
	
	self.dashSpeed = SPEED
	self.dashing = false
	self.canDash = false
	
	self.lastPosition = Vector3.new()
	self.newPosition = Vector3.new()
	self.movementDirection = Vector3.new()
	
	local onInput = function(actionName, inputState)
		if inputState ~= BEGIN_INPUT_STATE or self.dashing then return end
		if self.canDash then
			self:Dash()
		else
			self:BindDash()
		end
	end

	ContextActionService:BindActionAtPriority("Q", onInput, false, LOW_PRIORITY, Enum.KeyCode.Q)
	
	localPlayer.CharacterAdded:Connect(function(...) self:CharacterAdded(...) end)
	
	repeat task.wait() until localPlayer.Character
	
	self.character = localPlayer.Character
	self.humanoid = self.character:WaitForChild("Humanoid")
	
	self.animator = self.humanoid:FindFirstChild("Animator")
	if not self.animator then
		self.animator = Instance.new("Animator", self.humanoid)
	end
	
	self.humanoidRootPart = self.character:WaitForChild("HumanoidRootPart")
	
	RunService.RenderStepped:Connect(function(...) self:_RecordDirection(...) end)
	
	return self
end

function DashScript:_RecordDirection(dt)
	-- Get the current position of the player
	self.newPosition = self.character.HumanoidRootPart.Position

	-- Calculate the direction vector
	local direction = (self.newPosition - self.lastPosition).unit

	-- Compare the direction with the player's orientation
	local forwardDot = self.character.HumanoidRootPart.CFrame.LookVector:Dot(direction)
	local rightDot = self.character.HumanoidRootPart.CFrame.RightVector:Dot(direction)

	-- Determine the movement direction
	local movementDirection = ""

	if forwardDot > 0.9 then
		self.movementDirection = Vector3.new(0, 0, DISTANCE_IN_STUDS)
	elseif forwardDot < -0.9 then
		self.movementDirection = Vector3.new(0, 0, -DISTANCE_IN_STUDS)
	elseif rightDot > 0.9 then
		self.movementDirection = Vector3.new(DISTANCE_IN_STUDS, 0, 0)
	elseif rightDot < -0.9 then
		self.movementDirection = Vector3.new(-DISTANCE_IN_STUDS, 0, 0)
	end
	
	print(self.movementDirection)

	-- Update the previous position
	self.lastPosition = self.newPosition
end

function DashScript:CharacterAdded(character)
	self.character = character
end

function DashScript:BindDash()
	self.canDash = true
	task.wait(0.35)
	
	self.canDash = false
end

function DashScript:Dash()
	
	if not self.canDash then
		return
	end

	self.dashing = true
	self.canDash = false

	local targetCFrame = self:GetCFramePlayerIsMovingTo(self.movementDirection)

	local tweenTime = (targetCFrame.Position - self.humanoidRootPart.Position).Magnitude / self.dashSpeed
	local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)
	local targetTable = {CFrame = targetCFrame}

	self:TweenPlayerToPosition(tweenInfo, targetTable)

	task.wait(0.2)
		
	self.canDash = true
	
	self.dashing = false
end

function DashScript:GetCFramePlayerIsMovingTo()
	
	print(self.movementDirection)
	
	local targetCFrame = self.humanoidRootPart.CFrame * CFrame.new(self.movementDirection.X, 0, -self.movementDirection.Z)

	local rayparams = RaycastParams.new()
	rayparams.FilterDescendantsInstances = self.character:GetDescendants()
	rayparams.FilterType = Enum.RaycastFilterType.Exclude

	local startPos = self.humanoidRootPart.Position
	local endPos = targetCFrame.Position

	local getEndPositionRaycast = workspace:Raycast(startPos, endPos - startPos, rayparams)  

	if getEndPositionRaycast then
		local rayPos = getEndPositionRaycast.Position 
		if rayPos then
			targetCFrame = CFrame.new(rayPos) * self.humanoidRootPart.CFrame.Rotation
		end
	end
	return targetCFrame
end

function DashScript:TweenPlayerToPosition(tweenInfo, targetTable)
	self.humanoidRootPart.Anchored = true
	
	local tween = TweenService:Create(self.humanoidRootPart, tweenInfo, targetTable)
	
	tween:Play()
	
	tween.Completed:Wait()
	
	self.humanoidRootPart.Anchored = false
end

return DashScript.new()
