local zone = script.Parent
local Players = game:GetService("Players")
local Zone = require(game:GetService("ServerScriptService"):WaitForChild("Gameplay"):WaitForChild("Zone"))

local states = {}

Players.PlayerRemoving:Connect(function(player)
	states[player] = nil
end)

while true do
	for _, player in Players:GetPlayers() do
		local character = player.Character
		local root = character
			and character:FindFirstChild("HumanoidRootPart")

		if not root then
			states[player] = nil
			continue
		end

		local inside = Zone.containsPoint(zone, root.Position)
		local previous = states[player]

		if previous and previous.character == character then
			if previous.inside == false and inside then
				print(player.Name .. "님이 밖에서 광장으로 들어왔습니다")
			end
		end

		states[player] = {
			character = character,
			inside = inside,
		}
	end

	task.wait(0.1)
end
