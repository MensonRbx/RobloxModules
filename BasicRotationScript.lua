--[[
Inspired/Based on a tutorial on YouTube: https://www.youtube.com/watch?v=mdXRnNb0S6o
]]

local RunService = game:GetService('RunService')

local currentCamera = workspace.CurrentCamera
local character = script.Parent
local humanoidRootPart = character:WaitForChild('HumanoidRootPart')
local neckMotor6D = character:FindFirstChild('Neck', true)
local waistMotor6D  = character:FindFirstChild('Waist', true)

--Get this first so it remains constant, no movement of head up/down
local neck_Y = neckMotor6D.C0.Y
local waist_Y = waistMotor6D.C0.Y

--constants
local CFRAME_NEW = CFrame.new
local CFRAME_ANGLES = CFrame.Angles
local MATH_ASIN = math.asin
local MATH_ABS = math.abs

RunService.RenderStepped:Connect(function()
	local relative_camera_position: CFrame = humanoidRootPart.CFrame:ToObjectSpace(currentCamera.CFrame)
	local direction_of_camera: Vector3 = relative_camera_position.LookVector
	
	local absolute_x_rotation = MATH_ABS(direction_of_camera.X)
	
	local right = direction_of_camera.X > 0.5
	local left = direction_of_camera.X < -0.5 
	
	local clamp = 0.5
	
	if absolute_x_rotation > 0.5 then 
		if left then
			clamp *= -1
		end
		waistMotor6D.C0 = CFRAME_NEW(0, waist_Y, 0) * CFRAME_ANGLES(0,(-MATH_ASIN(direction_of_camera.X) + clamp),0) * CFRAME_ANGLES(MATH_ASIN(direction_of_camera.Y),0,0)
	else
		waistMotor6D.C0 = CFRAME_NEW(0, waist_Y, 0)
		neckMotor6D.C0 = CFRAME_NEW(0,neck_Y,0) * CFRAME_ANGLES(0,-MATH_ASIN(direction_of_camera.X),0) * CFRAME_ANGLES(MATH_ASIN(direction_of_camera.Y),0,0)
	end
		
end)
