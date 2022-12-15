
## Support

If you require any form of support after acquiring this resource, the right place to ask is our 
Discord Server: https://discord.kiminaze.de

Make sure to react to the initial message with the tick and your language to get access to all 
the different channels.

Please do not contact anyone directly unless you have a really specific request that does not 
have a place in the server.


## What exactly is the “OrbitCam” and what can you do with it?

The OrbitCam is a script that allows you to have a separate camera that can orbit a given point or 
entity. This is very useful for certain occasions where the default camera is useless or where you 
need some more control over the camera angle.

When the player is dead, you can no longer move the camera in the base game. This allows you to 
change that.
You could also start a camera when a player is sitting on some benches where the default camera 
would usually glitch into the player.

Showcase video:

https://www.youtube.com/watch?v=IrrPiBaRS18


## Features

- Orbit the camera around a given point or entity.
- Can follow entities with an offset.
- Zooming in and out.
- Configurable min and max radius and zooming steps in between.
- Configurable transition speed between gameplay and orbit cam.
- Switch between performance and precision mode (less or more accurate collision detection for the camera).
- Works on mouse + keyboard and controller!
- Comes with three exports for starting, stopping and updating the camera (more below).
- When using the script "baseevents": Automatically starts a camera when the player dies.


## Performance

|             Status              | Performance  |
| ------------------------------- | -----------: |
| **Idle**                        |      0.00 ms |
| **Active camera** (performance) | 0.06-0.07 ms |
| **Active camera** (precision)   | 0.09-0.10 ms |


## Export usage

### Start the camera
```lua
exports["OrbitCam"]:StartOrbitCam(position, entity, minRadius, maxRadius)
```
| Parameter     | Type         | Description                                                                             |
| ------------- | ------------ | --------------------------------------------------------------------------------------- |
| **position**  | vector3      | The position to start on.                                                               |
| **entity**    | entityHandle | The entity to follow. Parameter **position** will be used as an offset. Can be omitted. |
| **minRadius** | float        | Minimum radius the camera will orbit at. Can be omitted.                                |
| **maxRadius** | float        | Maximum radius the camera will orbit at. Can be omitted.                                |

### Stop the camera
```lua
exports["OrbitCam"]:EndOrbitCam()
```

### Update camera position
```lua
exports["OrbitCam"]:UpdateCamPosition(position, entity, minRadius, maxRadius)
```
| Parameter     | Type         | Description                                                                             |
| ------------- | ------------ | --------------------------------------------------------------------------------------- |
| **position**  | vector3      | The position to switch to.                                                              |
| **entity**    | entityHandle | The entity to follow. Parameter **position** will be used as an offset. Can be omitted. |
| **minRadius** | float        | Minimum radius the camera will orbit at. Can be omitted.                                |
| **maxRadius** | float        | Maximum radius the camera will orbit at. Can be omitted.                                |
