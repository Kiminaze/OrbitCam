
-- init default camera values
local cam			= nil
local trackedEntity	= nil
local camFocusPoint	= vector3(0, 0, 0)
local entityOffset	= nil

local minRadius, maxRadius	= Config.minRadius, Config.maxRadius
local currentRadius			= (minRadius + maxRadius) * 0.5

local angleY, angleZ = 0.0, 0.0

-- list of controls that should be disabled during camera
local disabledControls = { 14, 15, 16, 17, 81, 82, 99 }



-- start camera
function StartOrbitCam(position, entity, _minRadius, _maxRadius)
	-- set new focus point
	ClearFocus()
	if (entity) then
		trackedEntity = entity
		entityOffset = position
		camFocusPoint = GetEntityCoords(trackedEntity) + entityOffset
	else
		camFocusPoint = position
	end

	minRadius = _minRadius or Config.minRadius
	maxRadius = _maxRadius or Config.maxRadius

	local rot = GetGameplayCamRot(2)
	angleY = -rot.x
	angleZ = rot.z - 90

	-- setup camera
	cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", camFocusPoint, 0, 0, 0, GetGameplayCamFov())
	SetCamActive(cam, true)
	RenderScriptCams(true, true, Config.transitionSpeed, true, false)

	-- start camera processing
	Citizen.CreateThread(function()
		while (cam ~= nil) do
			ProcessCamControls()

			Citizen.Wait(0)
		end
	end)
end

-- destroy camera
function EndOrbitCam()
	ClearFocus()

	RenderScriptCams(false, true, Config.transitionSpeed, true, false)
	DestroyCam(cam, false)

	cam = nil
	trackedEntity = nil
end

-- update camera focus position
function UpdateCamPosition(position, entity, _minRadius, _maxRadius)
	if (entity) then
		trackedEntity = entity
		entityOffset = position
		camFocusPoint = GetEntityCoords(trackedEntity) + entityOffset
	else
		camFocusPoint = position
	end

	minRadius = _minRadius or Config.minRadius
	maxRadius = _maxRadius or Config.maxRadius
end



-- process camera controls
function ProcessCamControls()
	-- disable 1st person and some controls
	DisableFirstPersonCamThisFrame()
	for i, control in ipairs(disabledControls) do
		DisableControlAction(0, control, true)
	end

	-- calculate new position
	local newPos = ProcessNewPosition()

	-- set position of cam and focus
	SetCamCoord(cam, newPos)
	PointCamAtCoord(cam, camFocusPoint)
	SetFocusPosAndVel(camFocusPoint, 0.0, 0.0, 0.0)
end

function ProcessNewPosition()
	-- calculate angle from player camera input
	local speedMult = IsInputDisabled(0) and Config.mouseSpeed or Config.controllerSpeed
	angleZ = angleZ - GetDisabledControlUnboundNormal(1, 1) * speedMult	-- around Z axis (left / right)
	angleY = angleY + GetDisabledControlUnboundNormal(1, 2) * speedMult	-- around Y axis (up / down)
	angleY = math.max(math.min(angleY, 89.0), -89.0)				-- limit up / down angle to 90°

	-- calculate orbit height
	currentRadius = currentRadius + (GetDisabledControlNormal(0, 16) - GetDisabledControlNormal(0, 17)) * Config.radiusStepLength
	currentRadius = math.max(math.min(currentRadius, maxRadius), minRadius)

	if (trackedEntity and DoesEntityExist(trackedEntity)) then
		camFocusPoint = GetEntityCoords(trackedEntity) + entityOffset
	end
	
	-- do the thing with the math (calculate the orbit position)
	local cosY = Cos(angleY)
	local offset = vector3(Cos(angleZ) * cosY, Sin(angleZ) * cosY, Sin(angleY)) * currentRadius

	local newPos = camFocusPoint + offset

	local ignoreEnt = trackedEntity or PlayerPedId()
	local rayCastResults = {}
	if (Config.usePreciseMethod) then
		-- use raycasts to the new position offset by the cameras near clip planes' corners
		local right, forward, up, currentCamPos = GetCamMatrix(cam)
		local vertOffset, horiOffset = right * 0.125, up * 0.07
		table.insert(rayCastResults, { RayCast(camFocusPoint, newPos + vertOffset + horiOffset, ignoreEnt) })
		table.insert(rayCastResults, { RayCast(camFocusPoint, newPos + vertOffset - horiOffset, ignoreEnt) })
		table.insert(rayCastResults, { RayCast(camFocusPoint, newPos - vertOffset - horiOffset, ignoreEnt) })
		table.insert(rayCastResults, { RayCast(camFocusPoint, newPos - vertOffset + horiOffset, ignoreEnt) })
	else
		-- use a single raycast to the new position
		table.insert(rayCastResults, { RayCast(camFocusPoint, newPos, ignoreEnt) })
	end

	local radius = currentRadius
	for i, rayCastResult in ipairs(rayCastResults) do
		if (rayCastResult[1]) then
			local dist = #(camFocusPoint - rayCastResult[2])
			if (dist < radius) then
				radius = dist
			end
		end
	end

	-- recalc the offset with the new radius
	offset = offset * (radius / currentRadius)

	return camFocusPoint + offset
end

-- need instant result, no async possible / shorten function call
function RayCast(from, to, ignoreEntity)
	local _, hit, hitPosition = GetShapeTestResult(StartExpensiveSynchronousShapeTestLosProbe(from, to, -1, ignoreEntity, 0))
	return hit, hitPosition
end



-- define exports
exports("StartOrbitCam", StartOrbitCam)
exports("UpdateCamPosition", UpdateCamPosition)
exports("EndOrbitCam", EndOrbitCam)
