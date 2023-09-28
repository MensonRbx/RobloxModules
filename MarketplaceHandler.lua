local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players") 

local GamepassFunctions: {[number]: (Player) -> (any)} = require(script:WaitForChild("GamepassFunctions"))
local ProductFunctions: {[number]: (Player) -> (any)} = require(script:WaitForChild("ProductFunctions"))

--[[
  FORMAT OF FUNCTION MODULES:

  NAME_OF_TABLE[ID_OF_GAMEPASS_OR_DEV_PRODUCT] = function(player)

  end

]]

local MarketplaceHandler = {}
MarketplaceHandler.__index = MarketplaceHandler

function MarketplaceHandler.new()
	local self = setmetatable({}, MarketplaceHandler)

	self:init()

	return self
end

function MarketplaceHandler:init()
	Players.PlayerAdded:Connect(function(...) self:PlayerJoin(...) end)	
	
	MarketplaceService.ProcessReceipt = function(receiptInfo) return self:ProductPurchaseFinished(receiptInfo) end
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(...) self:GamepassPurchaseFinished(...) end)	
end

function MarketplaceHandler:PlayerJoin(player)
	for id, func in GamepassFunctions do
		if MarketplaceService:UserOwnsGamePassAsync(player.UserId, id) then
			func(player)
		end
	end
end

function MarketplaceHandler:ProductPurchaseFinished(receiptInfo)

	local tableName = tostring(receiptInfo.PlayerId).."Purchases"

	local dataTable = _G[tableName]

	if not dataTable then
		_G[tableName] = {}
		dataTable = _G[tableName]
	end

	if table.find(dataTable, receiptInfo.PurchaseId) then 
		return 
	end

	table.insert(dataTable, receiptInfo.PurchaseId)

	local playerProductKey = receiptInfo.PlayerId .. "_" .. receiptInfo.PurchaseId
	local success, isPurchaseRecorded = pcall(function()

		-- Find the player who made the purchase in the server
		local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
		if not player then
			-- The player probably left the game
			-- If they come back, the callback will be called again
			return nil
		end

		local handler = ProductFunctions[receiptInfo.ProductId] or nil

		local success, result = pcall(handler, player)
		if not success or not result then
			error("Failed to process a product purchase for ProductId:", receiptInfo.ProductId, " Player:", player)
			return nil
		end

		return true
	end)

	if not success then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	else	
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

end

function MarketplaceHandler:GamepassPurchaseFinished(player: Player, gamepassId: number, wasPurchased: boolean)
	if wasPurchased then
		GamepassFunctions[gamepassId](player)
	end
end

return MarketplaceHandler.new()
