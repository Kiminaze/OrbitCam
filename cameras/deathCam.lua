
-- Toggle orbit cam when the player dies.
AddEventHandler("baseevents:onPlayerDied", function()
	StartOrbitCam(vector3(0.0, 0.0, 0.5), PlayerPedId())

	while (NetworkIsPlayerActive(PlayerId()) and IsPedFatallyInjured(PlayerPedId())) do
		Wait(0)
	end

	EndOrbitCam()
end)
