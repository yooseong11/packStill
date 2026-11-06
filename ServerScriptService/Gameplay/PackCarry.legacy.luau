local pack = workspace:WaitForChild("PhotoPack")
local Zone = require(game:GetService("ServerScriptService"):WaitForChild("Gameplay"):WaitForChild("Zone"))
assert(pack:IsA("BasePart"), "PhotoPack은 BasePart여야 해요")
local spot = workspace:FindFirstChild("HatchSpot", true)
assert(spot and spot:IsA("BasePart"), "HatchSpot을 찾을 수 없어요")

local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "집기"
prompt.ObjectText = "포토카드 팩"
prompt.KeyboardKeyCode = Enum.KeyCode.E
prompt.HoldDuration = 0.3
prompt.MaxActivationDistance = 10
prompt.RequiresLineOfSight = false
prompt.Parent = pack

local holder = nil
local weld = nil
local deathConnection = nil
local returnCFrame = pack.CFrame

local function release(target)
	if weld then
		weld:Destroy()
		weld = nil
	end
	if deathConnection then
		deathConnection:Disconnect()
		deathConnection = nil
	end

	pack.Anchored = true
	pack.CanCollide = true
	pack.Massless = false
	pack.CFrame = target
	holder = nil
	prompt.ActionText = "집기"
end

prompt.Triggered:Connect(function(player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid or humanoid.Health <= 0 then
		return
	end
	if (root.Position - pack.Position).Magnitude > 12 then
		return
	end

	if holder then
		if holder ~= player then
			return
		end

		-- HatchSpot은 바닥판일 수 있어 높이 대신 바닥 면적 안인지 검사합니다.
		local playerPoint = spot.CFrame:PointToObjectSpace(root.Position)
		local projectedPosition = spot.CFrame:PointToWorldSpace(
			Vector3.new(playerPoint.X, 0, playerPoint.Z)
		)
		if not Zone.containsPoint(spot, projectedPosition) then
			return
		end

		-- 플레이어 앞쪽을 내려놓을 위치로 사용해요.
		local target = root.Position + root.CFrame.LookVector * 4
		local point = spot.CFrame:PointToObjectSpace(target)

		-- 계란 전체가 부화 공간 안에 들어갈 때만 내려놓아요.
		local limitX = (spot.Size.X - pack.Size.X) / 2
		local limitZ = (spot.Size.Z - pack.Size.Z) / 2
		if math.abs(point.X) > limitX or math.abs(point.Z) > limitZ then
			return
		end

		local height = (spot.Size.Y + pack.Size.Y) / 2
		release(spot.CFrame * CFrame.new(point.X, height, point.Z))
	else
		holder = player
		returnCFrame = pack.CFrame
		pack.CanCollide = false
		pack.Massless = true
		pack.CFrame = root.CFrame * CFrame.new(0, 0, -3)

		weld = Instance.new("WeldConstraint")
		weld.Part0 = root
		weld.Part1 = pack
		weld.Parent = pack
		pack.Anchored = false
		prompt.ActionText = "기지에 내려놓기"

		deathConnection = humanoid.Died:Connect(function()
			release(returnCFrame)
		end)
	end
end)

game:GetService("Players").PlayerRemoving:Connect(function(player)
	if holder == player then
		release(returnCFrame)
	end
end)
