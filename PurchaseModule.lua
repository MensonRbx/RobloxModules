local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

--module where functions are stored for products
local ProductFunctions = require(script:WaitForChild("ProductFunctions"))

local PromptPurchase = ReplicatedStorage.PromptPurchase

local PurchaseModule = {}
PurchaseModule.__index = PurchaseModule

function PurchaseModule.new()
	local self = setmetatable({}, PurchaseModule)

	local onProductPurchase = function(player, id, isFuneral)
		self:PlayerPurchaseProduct(player, id, isFuneral)
	end

	MarketplaceService.ProcessReceipt = function(receiptInfo)
		return self:ProcessReceipt(receiptInfo)
	end
	
	PromptPurchase.OnServerEvent:Connect(onProductPurchase)
	
	return self
end

function PurchaseModule:ProcessReceipt(receiptInfo)
	
	--for some reason, purchases can duplicate so I have a table which records purchases
	local tableName = tostring(receiptInfo.PlayerId).."Purchases"

	local dataTable = _G[tableName]
	if not dataTable then
		_G[tableName] = {}
		dataTable = _G[tableName]
	end

	if table.find(dataTable, receiptInfo.PurchaseId) then 
		return Enum.ProductPurchaseDecision.NotProcessedYet
	else
		table.insert(dataTable, receiptInfo.PurchaseId)
	end

	local playerProductKey = receiptInfo.PlayerId .. "_" .. receiptInfo.PurchaseId
	local success1, isPurchaseRecorded = pcall(function()

		local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
		if not player then
			warn("Player does not exist!")
			return nil
		end

		local handler = ProductFunctions[receiptInfo.ProductId] or nil

		local success2, result = pcall(handler, player)

		if not success2 then
			error("Failed to process a product purchase for ProductId:", receiptInfo.ProductId, " Player:", player)
			return nil
		end

		return true
	end)

	if not success1 then
		warn("Not Granted!")
		return Enum.ProductPurchaseDecision.NotProcessedYet
	elseif success1 then
		warn("Granted!")
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
end

function PurchaseModule:PlayerPurchaseProduct(player, id, isFuneral)
	
	if isFuneral and _G["CurrentFuneral"] then
		return
	end
	
	MarketplaceService:PromptProductPurchase(player, id)
end

return coroutine.wrap(PurchaseModule.new)()
