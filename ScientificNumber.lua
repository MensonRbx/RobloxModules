--!nonstrict

--[[
	Scientific Notation Module:
	Purpose: Expression of big numbers greater than possible in Luau in most concise method possible
]]

local ROUND_TO = 4
local WARN_MODE = false

local ScientificNumber = {}
ScientificNumber.__index = ScientificNumber

--MISC FUNCTIONS
function isScientificNumber(number)
	return getmetatable(number) == ScientificNumber
end

function CanBeScientificNumber(number)
	return (math.floor(number) == number) and math.abs(number) == number
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
function ScientificNumber.Add(num1, num2)

	local exponent1 = num1:GetExponentFromString()
	local exponent2 = num2:GetExponentFromString()

	local sumofExponents = exponent1 + exponent2
	
	local finalCooefficient = num1.coefficient + (num2.coefficient) / math.max(10 * exponent1 - exponent2, 1)
	local finalExponent = exponent1

	if finalCooefficient > 10 then
		finalCooefficient /= 10
		finalExponent += 1
	end		
	
	while finalCooefficient < 1 do
		finalCooefficient /= 10
		finalExponent += 1
	end
	
	local roundNum = 10^ROUND_TO
	local result = ScientificNumber.new()
	result.coefficient = math.round(finalCooefficient*(roundNum))/roundNum
	result.exponent = finalExponent

	return result
end

function ScientificNumber:Sub(num1, num2)
	local exponent1 = num1:GetExponentFromString()
	local exponent2 = num2:GetExponentFromString()

	local differenceInExponents = exponent1 - exponent2
	
	local finalCooefficient = num1.coefficient - (num2.coefficient) / math.max(10 * math.abs(differenceInExponents), 1)
	local finalExponent = exponent1
		
	while finalCooefficient < 1 do
		finalCooefficient *= 10
		finalExponent -= 1		
	end	

	local roundNum = 10^ROUND_TO
	local result = ScientificNumber.new()
	result.coefficient = math.round(finalCooefficient*(roundNum))/roundNum
	result.exponent = finalExponent

	return result
end

function ScientificNumber.ComputeSciNumbers(sciNum, otherSciNum, adding)
	
	local largerNum, smallerNum
	
	if sciNum > otherSciNum then
		largerNum, smallerNum = sciNum, otherSciNum	
	elseif sciNum < otherSciNum then
		largerNum, smallerNum = otherSciNum, sciNum
	else
		print("Equal")
		if not adding then
			return 0
		end
		
		--answer is same but coefficient x2
		local newNumber = ScientificNumber.new()
		newNumber.exponent = sciNum.exponent
		newNumber.coefficient = sciNum.coefficient * 2
		
		if newNumber.coefficient >= 10 then
			newNumber.coefficient /= 10
			newNumber.exponent += 1
		end
		
		return newNumber
	end

	local exponent1 = sciNum:GetExponentFromString()
	local exponent2 = otherSciNum:GetExponentFromString()
	
	if typeof(exponent1) == "number" and typeof(exponent2) == "number" then
		
		local difference = exponent1 - exponent2
		if difference > ROUND_TO then
			return largerNum
		end
		
		if adding then
			return ScientificNumber.Add(sciNum, otherSciNum)
		else
			return ScientificNumber.Add(sciNum, otherSciNum)
		end
		
	else
		warn("One exponent is not number, cannot add together.")
		return largerNum
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

function ScientificNumber:__add(value)
	if self:IsScientificNumber(value) then
		return self.ComputeSciNumbers(self, value, true)
	elseif typeof(value) == "number" then
		return self.ComputeSciNumbers(self, ScientificNumber.new(value), true)
	end
end

function ScientificNumber:__sub(value)
	if self:IsScientificNumber(value) then
		return self.ComputeSciNumbers(self, value, false)
	elseif typeof(value) == "number" then
		return self.ComputeSciNumbers(self, value, false)
	end
end

function ScientificNumber.__lt(sciNum, otherNumber)
	
	if isScientificNumber(otherNumber) then
		--compare exponents to check if one is bigger
		if sciNum.exponent ~= otherNumber.exponent then
			return sciNum.exponent < otherNumber.exponent
		else
			return sciNum.coefficient < otherNumber.coefficient
		end
		
	elseif typeof(otherNumber) == "number" then
		return ScientificNumber.__lt(sciNum, ScientificNumber.new(otherNumber))
	end
	
end

function ScientificNumber.__le(sciNum, otherNumber)
	
	if isScientificNumber(otherNumber) then

		--compare exponents to check if one is bigger
		
		if sciNum.exponent ~= otherNumber.exponent then
			return sciNum.exponent <= otherNumber.exponent 
		else
			return sciNum.coefficient <= otherNumber.coefficient 
			
			--[[
			Compare cooefficients
			>= due to comparing less than, inverse of greater than/equal to
			]]
			--if sciNum.coefficient > otherNumber.coefficient then
			--	return false
			--elseif sciNum.coefficient <= otherNumber.coefficient then
			--	return true
			--end
		end
		
	elseif typeof(otherNumber) == "number" then
		return ScientificNumber.__le(sciNum, ScientificNumber.new(otherNumber))
	end
	
end


return ScientificNumber
