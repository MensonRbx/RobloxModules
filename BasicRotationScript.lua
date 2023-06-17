--[[
Inspired/Based on a tutorial on YouTube: https://www.youtube.com/watch?v=mdXRnNb0S6o
]]
local RunService = game:GetService('RunService')

local currentCamera = workspace.CurrentCamera
local character = script.Parent
local humanoidRootPart = character:WaitForChild('HumanoidRootPart')
local neckMotor6D = character:WaitForChild("Head"):WaitForChild("Neck")
local waistMotor6D  = character:WaitForChild("UpperTorso"):WaitForChild("Waist")

--Get this first so it remains constant, no movement of head up/down
local neck_Y = neckMotor6D.C0.Y
local waist_Y = waistMotor6D.C0.Y

--constants
local CFRAME_NEW, CFRAME_ANGLES, MATH_ASIN, MATH_ABS = CFrame.new, CFrame.Angles, math.asin, math.abs

local RotationModule = {}
RotationModule.__index = RotationModule

function RotationModule.new()
	local self = setmetatable({}, RotationModule)
	
	self.max_neck_rotation = 0.7
	
	local onRenderedStep = function(dt)
		self:UpdateRotation(dt)
	end
	
	RunService.RenderStepped:Connect(onRenderedStep)
	
	return self
end

function RotationModule:UpdateRotation(dt)
	
	local relative_camera_position: CFrame = humanoidRootPart.CFrame:ToObjectSpace(currentCamera.CFrame)
	local direction_of_camera: Vector3 = relative_camera_position.LookVector

	local absolute_x_rotation = MATH_ABS(direction_of_camera.X)

	local is_looking_left = direction_of_camera.X < - self.max_neck_rotation

	if absolute_x_rotation > self.max_neck_rotation then 
		local yAdd = self.max_neck_rotation
		if is_looking_left then
			yAdd *= -1
		end
		waistMotor6D.C0 = CFRAME_NEW(0, waist_Y, 0) * CFRAME_ANGLES(0,(-MATH_ASIN(direction_of_camera.X) + yAdd),0)
		neckMotor6D.C0 = CFRAME_NEW(0,neck_Y,0) * CFRAME_ANGLES(0,-MATH_ASIN(direction_of_camera.X) + yAdd/4,0) * CFRAME_ANGLES(MATH_ASIN(direction_of_camera.Y),0,0)
	else
		waistMotor6D.C0 = CFRAME_NEW(0, waist_Y, 0)
		neckMotor6D.C0 = CFRAME_NEW(0,neck_Y,0) * CFRAME_ANGLES(0,-MATH_ASIN(direction_of_camera.X),0) * CFRAME_ANGLES(MATH_ASIN(direction_of_camera.Y),0,0)
	end
	
end

return RotationModule.new()

