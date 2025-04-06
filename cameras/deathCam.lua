
local orbitCam = exports["OrbitCam"]

-- Toggle orbit cam when the player dies.
AddEventHandler("baseevents:onPlayerDied", function()
	orbitCam:StartOrbitCam(vector3(0.0, 0.0, 0.5), PlayerPedId())

	while (NetworkIsPlayerActive(PlayerId()) and IsPedFatallyInjured(PlayerPedId())) do
		Wait(0)
	end

	orbitCam:EndOrbitCam()
end)
