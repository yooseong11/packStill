-- ModuleScript. 구역은 회전 가능한 상자 형태의 BasePart로 지정합니다.
local Zone = {}

function Zone.containsPoint(zone: BasePart, position: Vector3): boolean
	local point = zone.CFrame:PointToObjectSpace(position)
	local half = zone.Size / 2
	return math.abs(point.X) <= half.X
		and math.abs(point.Y) <= half.Y
		and math.abs(point.Z) <= half.Z
end

function Zone.containsPlayer(zone: BasePart, player: Player): boolean
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	return root ~= nil and root:IsA("BasePart")
		and Zone.containsPoint(zone, root.Position)
end

-- 회전한 아이템도 꼭짓점 8개가 모두 구역 안에 있는지 확인합니다.
-- 배치할 CFrame을 넘기면 실제 이동 전에 검사할 수 있습니다.
function Zone.containsBox(zone: BasePart, boxCFrame: CFrame, size: Vector3): boolean
	local half = size / 2
	for x = -1, 1, 2 do
		for y = -1, 1, 2 do
			for z = -1, 1, 2 do
				local corner = boxCFrame:PointToWorldSpace(
					Vector3.new(x * half.X, y * half.Y, z * half.Z)
				)
				if not Zone.containsPoint(zone, corner) then
					return false
				end
			end
		end
	end
	return true
end

return Zone
