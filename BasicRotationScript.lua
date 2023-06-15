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

RunService.RenderStepped:Connect(function()
	local relative_camera_position: CFrame = humanoidRootPart.CFrame:ToObjectSpace(currentCamera.CFrame)
	local direction_of_camera: Vector3 = relative_camera_position.LookVector
	
	local absolute_x_rotation = MATH_ABS(direction_of_camera.X)
	local max_neck_rotation = 0.7
	
	local is_looking_left = direction_of_camera.X < - max_neck_rotation
	
	if absolute_x_rotation > max_neck_rotation then 
		if is_looking_left then
			max_neck_rotation *= -1
		end
		waistMotor6D.C0 = CFRAME_NEW(0, waist_Y, 0) * CFRAME_ANGLES(0,(-MATH_ASIN(direction_of_camera.X) + max_neck_rotation),0)
	else
		waistMotor6D.C0 = CFRAME_NEW(0, waist_Y, 0)
		neckMotor6D.C0 = CFRAME_NEW(0,neck_Y,0) * CFRAME_ANGLES(0,-MATH_ASIN(direction_of_camera.X),0) * CFRAME_ANGLES(MATH_ASIN(direction_of_camera.Y),0,0)
	end
		
end)
