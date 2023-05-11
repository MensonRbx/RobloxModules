--[[
	Description:
		Class for a TagGroup, a group defined by a CollectionService tag that has an associated class
		for each instance tagged.
		
		Parameter name is both tag name and class name
]]

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClassesForGroup = ReplicatedStorage.ClassesForGroup

local TagGroupHandler = {}
TagGroupHandler.__index = TagGroupHandler

function TagGroupHandler.new(name: string)
	local classModule = ClassesForGroup:FindFirstChild(name)
	assert(classModule, "Error when finding module to require, module with name "..name.." does not exist!")
	
	--object construction
	local self = setmetatable({}, TagGroupHandler)
	
	self.objects = {}
	
	self.class = require(classModule)
	self.tagGroupArray = CollectionService:GetTagged(name)
	
	self:Initialize()
	
	return self
end

function TagGroupHandler:Initialize()
	
	for _, instance in self.tagGroupArray do
		self.objects[instance] = self.class.new(instance)
	end
	
end

return TagGroupHandler
