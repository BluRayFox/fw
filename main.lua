local fw = require('./fw')

-- .enableDebug() -- Debug prints and debug data

.addRoute('/', function(req, res)
    res:finish('Hi!')
end)

.addRoute('/test/:param', function(req, res) -- Params
    res:finish(req.params.param)
end)

-- Add Extensions (ORDER MATTERS!)
-- .addExtension(require './extensions/niko-debot')
.addExtension(require './extensions/rate-limit')
.addExtension(require './extensions/logger')

--          Port HTTPS
.startServer(80, false)