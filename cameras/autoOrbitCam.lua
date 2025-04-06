
if (not autoOrbitCam) then return end

-- key binding (see https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/)
local INPUT_MAPPER <const> = "KEYBOARD"
local INPUT_KEYBIND <const> = "O"
local INPUT_DESCRIPTION <const> = "Start orbit cam"

-- focus point offset from the entity
local OFFSET <const> = vector3(0, 0, 0.5)

-- speed at which the camera should move on the orbit
local ORBIT_SPEED <const> = 1.0

local orbitCam = exports["OrbitCam"]
RegisterCommand("+startorbit", function(src, args, raw)
	if (orbitCam:IsOrbitCamActive()) then
		orbitCam:EndOrbitCam()
		return
	end
	
	orbitCam:StartOrbitCam(OFFSET, PlayerPedId())
	orbitCam:SetAutoOrbitSpeed(ORBIT_SPEED)
end, false)
RegisterCommand("-startorbit", function() end, false)

RegisterKeyMapping("+startorbit", INPUT_DESCRIPTION, INPUT_MAPPER, INPUT_KEYBIND)
