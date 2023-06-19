local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local GamepassModel = {}
GamepassModel.__index = GamepassModel

function GamepassModel.new(instance)
	local self = setmetatable({}, GamepassModel)
	
	self.instance = instance
	self.touchPart = instance.Touch
	self.gamepassId = instance:GetAttribute("GamepassId")
	
	self:init()
	
	return GamepassModel
end

function GamepassModel:init()
	local onTouched = function(hitPart: Part)
		self:ProcessTouched(hitPart)
	end
	
	self.touchPart.Touched:Connect(onTouched)
end

function GamepassModel:ProcessTouched(hitPart: Part)
	local player = Players:GetPlayerFromCharacter(hitPart.Parent)
	
	if player then
		MarketplaceService:PromptGamePassPurchase(player, self.gamepassId)
	end
	
end

return GamepassModel
