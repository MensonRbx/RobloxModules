--Not made on Roblox, but still Lua


local Set = {}
Set.__index = Set

function Set.new(...)
	local newSet = {}

	for _, value in pairs{...} do
		newSet[value] = true
	end

	return setmetatable(newSet, Set)
end

function Set:copy()
	local copySet = Set.new()

	for entry in pairs(self) do
		copySet = copySet + entry
	end

	return copySet
end

function Set:Union(otherSet)
	local result = Set.new()

	for entry in pairs(self) do
		result = result + entry
	end
	for entry in pairs(otherSet) do
		result = result + entry
	end

	return result
end

function Set:Intersection(otherSet)
	local result = Set.new()

	for entry in pairs(self) do
		result = otherSet[entry] and result + entry or result
	end

	return result
end

function Set:Without(otherSet)
	local result = Set.new()

	for entry in pairs(self) do
		result = not otherSet[entry] and result + entry or result
	end

	return result
end
--all except in common
function Set:Unique(otherSet)
	local result = Set.new()

	local union = self:Union(otherSet)
	local Intersection = self:Intersection(otherSet)


	for entry in pairs(union) do
		result = not Intersection[entry] and result + entry or result
	end

	return result
end

function Set:__add(newItem)
	self[newItem] = true
	return self
end

function Set:__sub(itemToRemove)
	self[itemToRemove] = nil
	return self
end

function Set:__tostring()
	local elems = {}
	for key, value in pairs(self) do
		table.insert(elems, tostring(key))
	end
	return (table.concat(elems, ", "))
end

local allFruits = Set.new("Apple", "Lemon", "Mango", "Cherry", "Lime", "Peach")
local sourFruits = Set.new("Lemon", "Lime")

local sweetFruits = allFruits:Without(sourFruits)
print(sweetFruits)
