--[[
	During my course of working for people on Fiverr, I have encountered the fact that a lot of time I have to design 
	a "Confirm Prompt", which basically asks the user to say yes or no to a question.	This module is an attempt to 
	automate the creation of such a prompt. 
]]

local ConfirmModule = {}

function ConfirmModule.new(frame: Frame, yesFunction: any, noFunction: any)
	
	yesFunction = yesFunction or function() print("Yes!") end
	noFunction = noFunction or function() print("No!") end
	
	local yesButton = frame:FindFirstChild("Yes")
	local noButton = frame:FindFirstChild("No")
	
	local yesConnection: RBXScriptConnection = yesButton.Activated:Once(yesFunction)
	local noConnection: RBXScriptConnection = noButton.Activated:Once(noFunction)
	
	frame.Visible = true
	
	repeat 
		task.wait()
	until not yesConnection.Connected or not noConnection.Connected
	
	frame.Visible = false	
	
	if noConnection then
		noConnection:Disconnect()
		return false
	else
		yesConnection:Disconnect()
		return true
	end

end

return ConfirmModule
