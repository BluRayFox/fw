# fw
Luvit Web Framework
## How to use?
```lua
local fw = require('./fw')  -- require the module
-- .enableDebug() -- Debug prints and debug data

.addRoute('/', function(req, res) -- add routes
    res:finish('Hi!')
end)

.addRoute('/test/:param', function(req, res) -- params
    res:finish(req.params.param)
end)

-- Add Extensions (ORDER MATTERS!)
-- .addExtension(require './extensions/niko-debot')  
.addExtension(require './extensions/rate-limit')
.addExtension(require './extensions/logger')

--          Port HTTPS
.startServer(80, false)
```
