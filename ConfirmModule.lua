--[[
	During my course of working for people on Fiverr, I have encountered the fact that a lot of time I have to design 
	a "Confirm Prompt", which basically asks the user to say yes or no to a question. This module is an attempt to 
	automate the creation of such a prompt. 
]]

local ConfirmModule = {}

function ConfirmModule.new(frame: Frame, text: string, yesFunction: any, noFunction: any)
	
	if frame:GetAttribute("InUse") then
		return
	end
	
	frame:SetAttribute("InUse", true)
	
	text = text or "Are You Sure?"
	yesFunction = yesFunction or function() print("Yes!") end
	noFunction = noFunction or function() print("No!") end

	local yesButton = frame:FindFirstChild("Yes")
	local noButton = frame:FindFirstChild("No")

	local yesConnection: RBXScriptConnection = yesButton.Activated:Once(yesFunction)
	local noConnection: RBXScriptConnection = noButton.Activated:Once(noFunction)
	
	frame:FindFirstChildOfClass("TextLabel").Text = text
	frame.Visible = true
	
	repeat 
		task.wait()
	until not yesConnection.Connected or not noConnection.Connected

	frame.Visible = false
	frame:SetAttribute("InUse", false)
	
	if noConnection then
		noConnection:Disconnect()
		return false
	else
		yesConnection:Disconnect()
		return true
	end

end

return ConfirmModule
