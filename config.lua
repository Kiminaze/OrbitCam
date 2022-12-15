
Config = {}

-- prevents camera from glitching inside geometry - requires more performance
Config.usePreciseMethod = true

-- default min and max radius the camera will orbit at (in meters)
Config.minRadius = 2.0
Config.maxRadius = 7.0

-- steps for scrolling from min to max (and vice versa)
Config.radiusStepLength = 0.5

-- how fast the transition to and from the camera should be (in milliseconds)
Config.transitionSpeed = 1000

-- sets the speed multiplier for the camera angle
Config.mouseSpeed		= 8.0
Config.controllerSpeed	= 1.5

-- auto toggles the camera when the player is dead (only works when using the baseevents resource)
Config.deathCam = true
