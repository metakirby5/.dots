local consts = require('consts')

-- Tables+
function T(t)
  return setmetatable(t or {}, { __index = table })
end
setmetatable(table, {
  __index = {
    copy = function(self)
      copied = {}
      for k, v in ipairs(self) do
        copied[k] = v
      end
      return copied
    end,
    join = function(self, ...)
      joined = self:copy()
      for _, t in ipairs({...}) do
        for _, v in ipairs(t) do
          joined[#joined + 1] = v
        end
      end
      return joined
    end,
  },
})

-- Functions+
debug.setmetatable(function() end, {
    -- http://stackoverflow.com/a/20177245
    __len = function(self)
        return debug.getinfo(self, 'u').nparams
    end,
    __index = {
      curry = function(self, ...)
        local args = T{...}
        return function(...)
          if #{...} == 0 then
            return self(table.unpack(args))
          end
          return self:curry(table.unpack(args:join({...})))
        end
      end,
    },
})

local function switch(case)
  return function(caseTable)
    local selection = caseTable[case]
    if selection ~= nil then
      return selection
    end

    return caseTable[consts.DEFAULT]
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
  T = T,
  switch = switch,
  unpacked = unpacked,
  map = map,
  filter = filter,
}
