
-- localise frequently used Lua globals
local math_cos, math_sin, math_min, math_max, table_insert = math.cos, math.sin, math.min, math.max, table.insert
local tinyPi <const> = math.pi / 180.0

-- localise frequently used natives
local GetShapeTestResult, StartExpensiveSynchronousShapeTestLosProbe, IsInputDisabled, GetDisabledControlUnboundNormal, GetDisabledControlNormal, DoesEntityExist, 
GetEntityCoords, PlayerPedId, GetCamMatrix, DisableFirstPersonCamThisFrame, DisableControlAction, SetCamCoord, PointCamAtCoord, SetFocusPosAndVel
= GetShapeTestResult, StartExpensiveSynchronousShapeTestLosProbe, IsInputDisabled, GetDisabledControlUnboundNormal, GetDisabledControlNormal, DoesEntityExist, 
GetEntityCoords, PlayerPedId, GetCamMatrix, DisableFirstPersonCamThisFrame, DisableControlAction, SetCamCoord, PointCamAtCoord, SetFocusPosAndVel

-- init default camera values
local cam			= nil
local trackedEntity	= nil
local camFocusPoint	= vector3(0, 0, 0)
local entityOffset	= nil
local autoOrbit		= nil

local minRadius, maxRadius	= defaultMinRadius, defaultMaxRadius
local currentRadius			= (minRadius + maxRadius) * 0.5

local angleY, angleZ = 0.0, 0.0

-- list of controls that should be disabled during camera operation
local disabledControls = { 14, 15, 16, 17, 81, 82, 99 }



-- raycast - need instant result, no async possible
local function RayCast(from, to, ignoreEntity)
	local _, hit, hitPosition = GetShapeTestResult(StartExpensiveSynchronousShapeTestLosProbe(from.x, from.y, from.z, to.x, to.y, to.z, -1, ignoreEntity, 2))
	return hit, hitPosition
end

local function ProcessNewPosition()
	-- calculate angle from player camera input
	local speedMult = IsInputDisabled(0) and mouseSpeed or controllerSpeed
	if (not autoOrbit) then
		angleZ = angleZ - GetDisabledControlUnboundNormal(1, 1) * speedMult	-- around Z axis (left / right)
	else
		angleZ = angleZ - autoOrbit											-- around Z axis (left / right) (with autoOrbit)
	end
	angleY = angleY + GetDisabledControlUnboundNormal(1, 2) * speedMult		-- around Y axis (up / down)
	angleY = math_max(math_min(angleY, 89.0), -89.0)						-- limit up / down angle to less than 90°

	-- calculate orbit height
	currentRadius = currentRadius + (GetDisabledControlNormal(0, 16) - GetDisabledControlNormal(0, 17)) * radiusStepLength
	currentRadius = math_max(math_min(currentRadius, maxRadius), minRadius)

	if (trackedEntity and DoesEntityExist(trackedEntity)) then
		camFocusPoint = GetEntityCoords(trackedEntity) + entityOffset
	end
	
	-- do the thing with the math (calculate the orbit position)
	local cosY = math_cos(angleY * tinyPi)
	local offset = vector3(math_cos(angleZ * tinyPi) * cosY, math_sin(angleZ * tinyPi) * cosY, math_sin(angleY * tinyPi)) * currentRadius

	local newPos = camFocusPoint + offset

	local ignoreEnt = trackedEntity or PlayerPedId()
	-- use raycasts to the new position offset by the cameras near clip planes' corners
	local right, _, up = GetCamMatrix(cam)
	local verticalOffset, horizontalOffset = right * 0.125, up * 0.07
	local rayCastResults = {}
	rayCastResults[1] = { RayCast(camFocusPoint, newPos + verticalOffset + horizontalOffset, ignoreEnt) }
	rayCastResults[2] = { RayCast(camFocusPoint, newPos + verticalOffset - horizontalOffset, ignoreEnt) }
	rayCastResults[3] = { RayCast(camFocusPoint, newPos - verticalOffset - horizontalOffset, ignoreEnt) }
	rayCastResults[4] = { RayCast(camFocusPoint, newPos - verticalOffset + horizontalOffset, ignoreEnt) }

	local radius = currentRadius
	for i = 1, #rayCastResults do
		if (rayCastResults[i][1]) then
			local dist = #(camFocusPoint - rayCastResults[i][2])
			if (dist < radius) then
				radius = dist
			end
		end
	end

	-- recalc the offset with the new radius
	offset = offset * (radius / currentRadius)

	return camFocusPoint + offset
end

-- process camera controls
local function ProcessCamControls()
	-- disable 1st person and some controls
	DisableFirstPersonCamThisFrame()
	for i, control in ipairs(disabledControls) do
		DisableControlAction(0, control, true)
	end

	-- calculate new position
	local newPos = ProcessNewPosition()

	-- set position of cam and focus
	SetCamCoord(cam, newPos.x, newPos.y, newPos.z)
	PointCamAtCoord(cam, camFocusPoint.x, camFocusPoint.y, camFocusPoint.z)
	SetFocusPosAndVel(camFocusPoint.x, camFocusPoint.y, camFocusPoint.z, 0.0, 0.0, 0.0)
end

local function LogError(text, ...)
	print(("^1[ERROR] %s^0"):format(text):format(...))
end



-- start camera
local function StartOrbitCam(position, entity, _minRadius, _maxRadius, transitionSpeed)
	if (cam) then
		LogError("There is already an active camera!")
		return
	end

	-- set new focus point
	ClearFocus()
	if (entity) then
		trackedEntity = entity
		entityOffset = position
		camFocusPoint = GetEntityCoords(trackedEntity) + entityOffset
	else
		camFocusPoint = position
	end

	minRadius = _minRadius or defaultMinRadius
	maxRadius = _maxRadius or defaultMaxRadius
	currentRadius = (minRadius + maxRadius) * 0.5

	local rot = GetGameplayCamRot(2)
	angleY = -rot.x
	angleZ = rot.z - 90

	-- setup camera
	cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", camFocusPoint.x, camFocusPoint.y, camFocusPoint.z, 0, 0, 0, GetGameplayCamFov())
	SetCamActive(cam, true)
	RenderScriptCams(true, true, transitionSpeed or defaultTransitionSpeed, true, false)

	SetCamNearClip(cam, 0.05)

	TriggerEvent("OrbitCam:camStarted", position, entity)

	-- start camera processing
	CreateThread(function()
		while (cam ~= nil) do
			ProcessCamControls()

			Wait(0)
		end
	end)
end
exports("StartOrbitCam", StartOrbitCam)

-- destroy camera
local function EndOrbitCam(transitionSpeed)
	if (cam == nil) then
		LogError("There is no active camera!")
		return
	end

	ClearFocus()

	RenderScriptCams(false, true, transitionSpeed or defaultTransitionSpeed, true, false)
	DestroyCam(cam, false)

	cam = nil
	trackedEntity = nil
	autoOrbit = nil

	TriggerEvent("OrbitCam:camStopped")
end
exports("EndOrbitCam", EndOrbitCam)

-- update camera focus position
local function UpdateCamPosition(position, entity, _minRadius, _maxRadius)
	if (cam == nil) then
		LogError("There is no active camera!")
		return
	end

	if (entity) then
		trackedEntity = entity
		entityOffset = position
		camFocusPoint = GetEntityCoords(trackedEntity) + entityOffset
	else
		camFocusPoint = position
	end

	minRadius = _minRadius or defaultMinRadius
	maxRadius = _maxRadius or defaultMaxRadius
end
exports("UpdateCamPosition", UpdateCamPosition)

-- set automatic orbit speed
local function SetAutoOrbitSpeed(speed)
	if (speed ~= nil and type(speed) ~= "number") then
		LogError("Parameter \"speed\" needs to be a number or nil to reset!")
		return
	end

	autoOrbit = speed
end
exports("SetAutoOrbitSpeed", SetAutoOrbitSpeed)

-- check if orbit cam is active
local function IsOrbitCamActive()
	return cam ~= nil
end
exports("IsOrbitCamActive", IsOrbitCamActive)

-- check if entity is being tracked
local function IsEntityBeingTracked(entity)
	return entity and entity == trackedEntity or trackedEntity ~= nil
end
exports("IsEntityBeingTracked", IsEntityBeingTracked)

-- get entity being tracked
local function GetTrackedEntity()
	return trackedEntity
end
exports("GetTrackedEntity", GetTrackedEntity)
