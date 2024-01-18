local ReplcatedStorage = game:GetService("ReplicatedStorage")

local DoubleTapSignal = require(ReplcatedStorage.Shared:WaitForChild("DoubleTapSignal"))

local signal = DoubleTapSignal.new()

local connection = signal:Connect(function()
    print("Double tapped!")
end)

while true do
    task.wait()
    print(connection._currentTap)
end
