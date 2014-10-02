local facing = 0
local coords = {0, 0, 0}
local currentSlot = 1

turtle.select(1)


function readKVPairs(file)
  f = io.open(file, "r")
  kvPairs = {}
  for line in f:lines() do
    if line ~= nil then
      for k, v in string.gmatch(line, "(%w+)=(.*)") do
        kvPairs[k] = v
      end
    end
  end
  f:close()
  return kvPairs
end

function getFacing()
  return facing
end

function getCoords()
  return coords
end

local function saveCoords()
  f = io.open("_location", "w")
  f:write("x="..coords[1].."\ny="..coords[2].."\nz="..coords[3].."\nfacing="..facing)
  f:close()
end

function loadCoords()
  kvpairs = readKVPairs("_location")
  coords[1] = tonumber(kvpairs["x"])
  coords[2] = tonumber(kvpairs["y"])
  coords[3] = tonumber(kvpairs["z"])
  facing = tonumber(kvpairs["facing"])
end

function resetCoords()
  coords = {0, 0, 0}
  saveCoords()
end

function printCoords()
  print("[", coords[1], ",", coords[2], ",", coords[3], "]")
end

local function updateCoords(verticalMove)
  if verticalMove then
    coords[3] = coords[3] + verticalMove
  else
    if facing % 2 == 0 then
      coords[2] = coords[2] + 1 - facing 
    else 
      coords[1] = coords[1] + 2 -facing
    end
  end
  saveCoords()
end


local function updateFacing(direction)
  facing = facing + direction
  while facing > 3 do facing = facing - 4 end
  while facing < 0 do facing = facing + 4 end
end 

function refuel(slot)
  local slot = 1
  while turtle.getFuelLevel() < 1 do
    if slot == 17 then 
      break
    end
    if not turtle.refuel(slot) then
      slot = slot + 1
    end
  end
  select(currentSlot)

  return true
end

local function move(distance, moveFunction, onMove)
  if not distance then distance = 1 end

  for moveCount = 1, distance do 
    if moveFunction() then
      if moveFunction == turtle.up then
        verticalMove = 1
      elseif moveFunction == turtle.down then
        verticalMove = -1
      else
       verticalMove = nil
      end

      updateCoords(verticalMove)
    else
      return false
    end
    if onMove then
      onMove()
    end
  end
  return true
end

function forward(distance, onMove)
  return move(distance, turtle.forward, onMove)
end

function up(distance, onMove)
  return move(distance, turtle.up, onMove)
end

function down(distance, onMove)
  return move(distance, turtle.down, onMove)
end

function turnLeft()
  if turtle.turnLeft() then
    updateFacing(-1)
    return true
  else
    return false
  end
end

function turnRight()
  if turtle.turnRight() then
    updateFacing(1)
    return true
  else
    return false
  end
end

function turnTo(targetFacing)
  targetFacing = targetFacing % 4
  -- fixme 
  while facing ~= targetFacing do
    if not turnLeft() then
      return false
    end
  end
  return true
end

function select(slot)
  if turtle.select(slot) then
    currentSlot = slot
    return true
  else
    return false
  end
end

function getSelectedSlot()
  return currentSlot
end

function goTo(xTarget, yTarget)
  dx = xTarget - getCoords()[1]
  dy = yTarget - getCoords()[2]

  if dx < 0 then
    turnTo(3)
  else
    turnTo(1)
  end

  print(dx)
  print(dy)

  if not forward(math.abs(dx)) then
    print("failed to dx")
    return false
  end

  if dy < 0 then
    turnTo(2)
  else
    turnTo(0)
  end

  if not forward(math.abs(dy)) then
    print("failed to dy")
    return false
  end
  turnTo(0)
  return true
end
