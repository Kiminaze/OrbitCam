
if (not autoOrbitCam) then return end

-- focus point offset from the entity
local DEFAULT_OFFSET <const> = vector3(0, 0, 0)

-- speed at which the camera should move on the orbit
local DEFAULT_ORBIT_SPEED <const> = 0.5

local orbitCam = exports["OrbitCam"]
RegisterCommand("autoorbit", function(src, args, raw)
	if (orbitCam:IsOrbitCamActive()) then
		orbitCam:EndOrbitCam()
		return
	end

	local ped = PlayerPedId()

	local boneIndex = nil
	if (args[1]) then
		boneIndex = GetEntityBoneIndexByName(ped, args[1])
	end

	local x, y, z = tonumber(args[2]), tonumber(args[3]), tonumber(args[4])
	local offset = nil
	if (x and y and z) then
		offset = vector3(x, y, z)
	end

	orbitCam:StartOrbitCam(offset or DEFAULT_OFFSET, ped, nil, nil, nil, boneIndex)
	orbitCam:SetAutoOrbitSpeed(tonumber(args[5]) or DEFAULT_ORBIT_SPEED)
end, false)
