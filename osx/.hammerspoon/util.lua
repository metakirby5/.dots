local consts = require('consts')

-- Most functions that take one or more arguments
-- and are not curriers are curried.

-- Tables+
function T(t)
  return setmetatable(t or {}, { __index = table })
end
setmetatable(table, {
  __index = {
    -- Shallow copy
    copy = function(self)
      copied = T{}
      for k, v in ipairs(self) do
        copied[k] = v
      end
      return copied
    end,

    -- Combine tables
    merge = function(self, ...)
      return (function(arr, ...)
        merged = self:copy()
        for _, t in ipairs({arr, ...}) do
          for k, v in pairs(t) do
            merged[k] = v
          end
        end
        return merged
      end):curry(...)
    end,

    -- Concatenate arrays
    extend = function(self, ...)
      return (function(arr, ...)
        extended = self:copy()
        for _, t in ipairs({arr, ...}) do
          for _, v in ipairs(t) do
            extended[#extended + 1] = v
          end
        end
        return extended
      end):curry(...)
    end,

    -- Apply a function over each element
    map = function(self, ...)
      return (function(func)
        local mapped = {}

        -- Ensure lua won't think mapped will be empty
        for i, v in ipairs(self) do
          mapped[i] = consts.NULL
        end

        for i, v in ipairs(self) do
          mapped[i] = func(v)
        end
        return mapped
      end):curry(...)
    end,
  },
})

-- Functions+
debug.setmetatable(function() end, {
    -- Arity (http://stackoverflow.com/a/20177245)
    __len = function(self)
        return debug.getinfo(self, 'u').nparams
    end,

    __index = {
      -- Single-time partial application
      later = function(self, ...)
        local args = T{...}
        return function()
          return self(args:unpack())
        end
      end,

      -- Argument-based partial application
      curry = function(self, ...)
        local args = T{...}

        -- Already reached arity?
        if not (#args < #self) then
          return self(args:unpack())
        end

        return function(...)
          args = args:extend({...})
          if #args < #self then
            return self:curry(args:unpack())
          end
          return self(args:unpack())
        end
      end,

      -- Call with packed arguments
      withPacked = function(self, ...)
        return (function(args)
          return self(table.unpack(args))
        end):curry(...)
      end,

      map = function(self, ...)
        return (function(arr, ...)
          args = T{arr, ...}

          -- Get # of items to map
          local nargs = math.max(table.unpack(args:map(function(list)
            return #list
          end)))

          local mapped = {}
          for i = 1, nargs do
            -- Gather the ith arg of each arg list
            ithArgs = args:map(function(list)
              return list[i]
            end)
            mapped[i] = self(table.unpack(ithArgs, 1, #args))
          end
          return mapped
        end):curry(...)
      end,

      filter = function(self, ...)
        return (function(arr)
          local filtered = {}
          for _, v in ipairs(arr) do
            if self(v) then
              filtered[#filtered + 1] = v
            end
          end
          return filtered
        end):curry(...)
      end,
    },
})

-- Scala-style switch(case) {...}
local function switch(...)
  return (function(case, caseTable)
    local selection = caseTable[case]
    if selection ~= nil then
      return selection
    end

    return caseTable[consts.DEFAULT]
  end):curry(...)
end

return {
  T = T,
  switch = switch,
}
