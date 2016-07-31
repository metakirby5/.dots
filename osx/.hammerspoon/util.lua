local consts = require('consts')

local function switch(case)
  return function(caseTable)
    local selection = caseTable[case]
    if selection ~= nil then
      return selection
    end

    return caseTable[consts.DEFAULT]
  end
end

-- Fully curry a function so that it can be executed without arguments.
local function fullCurry(func, ...)
  local args = {...}
  return function()
    return func(table.unpack(args))
  end
end

-- Prepare `func` to be called with an array that repesents the arguments.
local function unpacked(func)
  return function(args)
    func(table.unpack(args))
  end
end

local function mapOne(func, array)
  local mapped = {}

  -- Ensure lua won't think mapped will be empty
  for i, v in ipairs(array) do
    mapped[i] = consts.NULL
  end

  for i, v in ipairs(array) do
    mapped[i] = func(v)
  end
  return mapped
end

local function map(func, ...)
  -- Get # of items to map
  local nargs = math.max(table.unpack(mapOne(function(list)
    return #list
  end, {...})))

  local mapped = {}
  for i = 1, nargs do
    -- Gather the ith arg of each arg list
    args = mapOne(function(list)
      return list[i]
    end, {...})
    mapped[i] = func(table.unpack(args, 1, #{...}))
  end
  return mapped
end

local function filter(func, array)
  local filtered = {}
  for _, v in ipairs(array) do
    if func(v) then
      filtered[#filtered + 1] = v
    end
  end
  return filtered
end

return {
  switch = switch,
  fullCurry = fullCurry,
  unpacked = unpacked,
  map = map,
  filter = filter,
}
