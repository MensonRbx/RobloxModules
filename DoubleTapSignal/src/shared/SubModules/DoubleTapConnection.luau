local UserInputService = game:GetService("UserInputService")

local TAP_COOLDOWN = 0.5

local DoubleTapConnection = {}
DoubleTapConnection.__index = DoubleTapConnection

function DoubleTapConnection.new(signal, func)
    local self = setmetatable({}, DoubleTapConnection)

    self.func = func
    self.connected = true
    
    self._signal = signal
    self._currentlyCalling = false

    self:init()

    return self
end

function DoubleTapConnection:init()
    self._currentTap = 0

    local onTouchTap = function(...)
        self._currentTap += 1
        if self._currentTap >= 2 then
            self.func(...)
            self._currentTap = 0
        end
        task.wait(TAP_COOLDOWN)
        self._currentTap = math.max(self._currentTap - 1, 0)
    end

    self._baseTouchTapConnection = UserInputService.TouchTap:Connect(onTouchTap) 
end

function DoubleTapConnection:Disconnect()
    self._baseTouchTapConnection:Disconnect()
    self.connected = false
end

function DoubleTapConnection:Destroy()
    self:Disconnect()
    for key in self do
        self[key] = nil
    end
end

return DoubleTapConnection

