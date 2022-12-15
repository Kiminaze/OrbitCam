
-- Toggle orbit cam when the player dies.
if (Config.deathCam) then
	AddEventHandler("baseevents:onPlayerDied", function(killerType, deathCoords)
		StartOrbitCam(vector3(0.0, 0.0, 0.5), PlayerPedId())

		while (NetworkIsPlayerActive(PlayerId()) and IsPedFatallyInjured(PlayerPedId())) do
			Citizen.Wait(500)
		end

		EndOrbitCam()
	end)
end
