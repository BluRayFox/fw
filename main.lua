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

.loadCert('cert.pem', 'key.pem')    -- paths to certs
.bindTo({ host = '127.0.0.1', port = 443 })

--          Port HTTPS
.startServer(true)