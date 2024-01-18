local UserInputService = game:GetService("UserInputService")

local SubModules = script.Parent.SubModules

local DoubleTapConnection = require(SubModules:WaitForChild("DoubleTapConnection"))

local DoubleTapSignal = {}
DoubleTapSignal.__index = DoubleTapSignal

function DoubleTapSignal.new()
	assert(UserInputService.TouchEnabled, "Error when creating DoubleTapSignal: Touch is not enabled!")
	local self = setmetatable({}, DoubleTapSignal)

	return self
end

function DoubleTapSignal:Connect(func: (any) -> any)
	self._doubleTapConnection = DoubleTapConnection.new(self, func)
	
	return self._doubleTapConnection
end

function DoubleTapSignal:Destroy()
	if self._doubleTapConnection then
		self._doubleTapConnection:Disconnect()
	end
	self._doubleTapConnection = nil
end

return DoubleTapSignal
