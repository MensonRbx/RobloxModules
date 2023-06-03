--!nonstrict

--[[
	Scientific Notation Module:
	
	Purpose: Expression of big numbers greater than possible in Luau in most concise method possible
	
]]

local Util = require(script:WaitForChild("Util"))

local ROUND_TO = 4
local WARN_MODE = false

local ScientificNumber = {}
ScientificNumber.__index = ScientificNumber

--MISC FUNCTIONS
function isScientificNumber(number)
	return getmetatable(number) == ScientificNumber
end

function ScientificNumber.new(number)
	local self = setmetatable({}, ScientificNumber)
	
	if number then
		self.coefficient = self:CreateExponentFromNumber(number)
		self.coefficient = self:CreateCoefficient(number)
	else
		self.coefficient = 0 
		self.exponent = ""
	end

	
	return self
end

function ScientificNumber:IsScientificNumber(number)
	return getmetatable(number) == ScientificNumber
end

function ScientificNumber:ToRealNumber()

	local coefficient = self.coefficient > 1 and self.coefficient or 1
	local exponent

	local realNumber

	local isExponentSciNum = self:IsScientificNumber(self.exponent) 

	if isExponentSciNum then
		exponent = self.exponent:ToRealNumber()

		if typeof(exponent) ~= "string" and exponent ~= math.huge then
			realNumber = math.round(coefficient * 10^exponent)	
		else

			if WARN_MODE then
				warn("Exponent of",self,"cannot be converted to real number")
			end

			return self:__tostring()
		end
	else
		exponent = string.split(self.exponent, "^")
		local finalExponent = tonumber(exponent[1])

		for i = 2, #exponent do
			finalExponent ^= tonumber(exponent[i])
		end

		realNumber = math.round(coefficient * 10^finalExponent)	
	end

	if realNumber == math.huge then
		if WARN_MODE then
			warn("Number cannot be converted to real number, using scientific notation instead")
		end
		return self:__tostring()
	end

	return realNumber
end

function ScientificNumber:CreateCoefficient(number: number)
	local currentNum = number

	while currentNum > 0 and not (currentNum < 10) do
		currentNum *= 0.1
	end

	local roundingNumber = 10^ROUND_TO

	local result = tostring(math.round(currentNum*roundingNumber)/roundingNumber)

	return result 
end

--Run on initializing number
function ScientificNumber:CreateExponentFromNumber(number: number)
	local len = self:GetLength(number)
	return tostring(len - 1)
end

function ScientificNumber:GetExponentFromString()

	local isExponentSciNum = self:IsScientificNumber(self.exponent) 

	if isExponentSciNum then
		return self.exponent:ToRealNumber()
	end

	local exponentList = string.split(self.exponent, "^")

	local finalExponent = tonumber(exponentList[1])

	for i = 2, #exponentList do
		finalExponent ^= tonumber(exponentList[i])
		print("Iteration "..i..":", finalExponent)
	end

	return finalExponent
end

--DEPRECIATED
function ScientificNumber:GetLength(number)
	
	if number then
		return math.floor(math.log(math.abs(number))) + 1
	end

	local numbersBeforeDecimals = string.split(self.coefficient, ".")[1]
	local exponentOfNum = self:GetExponentFromString()

	if typeof(exponentOfNum) == "string" then
		return "Length: "..exponentOfNum.." Plus Extra Number: "..numbersBeforeDecimals
	else
		return "Length: "..exponentOfNum
	end

end

--methods only accessed via metamethods
function ScientificNumber.AddSciNumbers(sciNum, otherSciNum)

	local exponent1 = sciNum:GetExponentFromString()
	local exponent2 = otherSciNum:GetExponentFromString()

	local differenceInCoefficients
	local differenceInExponents 
	
	local largerNum, smallerNum
	if sciNum > otherSciNum then
		
	elseif sciNum < otherSciNum then
		
	else
		--answer is same but coefficient x2
		local newNumber = ScientificNumber.new()
		newNumber.exponent = exponent1
		newNumber.coefficient = sciNum.coefficient * 2
		
		if newNumber.coefficient >= 10 then
			newNumber.coefficient /= 10
			newNumber.exponent += 1
		end
		
		return newNumber
		
	end
		
		
	
	if typeof(exponent1) == "number" and typeof(exponent2) == "number" then
		differenceInExponents = exponent1 - exponent2
		differenceInCoefficients = sciNum.coefficient - otherSciNum.coefficient

		if differenceInExponents > ROUND_TO then
			return sciNum
		end

		if differenceInCoefficients < 1 then

		end

	else

	end

end

function ScientificNumber:AddNormalNumber(number)
	assert(math.round(number) == number, "Error when performing arithmetic (add) on scientific number: normal number added must be integer")

	local numberInSciNotation = ScientificNumber.new(number)

	local sciNumExponent = self:GetExponentFromString()
	local regNumExponent = numberInSciNotation:GetExponentFromString()

	--if one number is string and other is not, added number is insignificant
	if typeof(sciNumExponent) == "string" and typeof(regNumExponent) ~= "string" then
		return self
	elseif typeof(sciNumExponent) == "number" and typeof(regNumExponent) == "number" then
		return self.AddSciNumbers(self, numberInSciNotation)
	end

end

--METAMETHODS
function ScientificNumber:__tostring()
	return self.coefficient.."x10^"..self.exponent
end

--for when the exponent is a sciNum itself and has to be concatated
function ScientificNumber.__concat(concatinator, self)
	return concatinator..self.coefficient.."x10^"..self.exponent
end

function ScientificNumber:__add(valueToAdd)

	if self:IsScientificNumber(valueToAdd) then
		self.AddSciNumbers(self, valueToAdd)
	elseif typeof(valueToAdd) == "number" then
		self.AddNormalNumber(self, valueToAdd)
	end

end

function ScientificNumber.__lt(sciNum, otherNumber)
	
	if isScientificNumber(otherNumber) then
		
		if sciNum.exponent > otherNumber.exponent then
			return false
		elseif sciNum.exponent < otherNumber.exponent then
			return true
		else
			
		end
		
	elseif typeof(otherNumber) == "number" then
		local sciNumLength = sciNum:GetLength()
		local realNumLength = ScientificNumber:GetLength(otherNumber)
		
		if sciNumLength > realNumLength then
			return false
		elseif realNumLength > sciNumLength then
			return true
		else
			
			
			
		end
		
	end
	
end


return ScientificNumber
