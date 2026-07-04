local function compile_route(path_template)
  local params = {}
  for param in path_template:gmatch(":(%w+)") do
    table.insert(params, param)
  end

  local pattern = "^" .. path_template:gsub(":%w+", "([^/]+)") .. "$"
  return pattern, params
end

local router = {}

function router.new()
    local self = setmetatable({}, {__index = router})

    self.routes = {}

    return self
end

function router:addRoute(path_template, handler)
  local pattern, param_names = compile_route(path_template)
  table.insert(self.routes, {
    pattern = pattern,
    param_names = param_names,
    handler = handler
  })
end

function router:match(url_path)
  for _, route in ipairs(self.routes) do
    local matches = { url_path:match(route.pattern) }
    
    if #matches > 0 or url_path == route.pattern:sub(2, -2) then
      local params = {}
      for i, param_name in ipairs(route.param_names) do
        params[param_name] = matches[i]
      end
      return route.handler, params
    end
  end
  return nil, nil
end

return router