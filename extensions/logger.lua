-- Extension Example: Logger

local logger = {}

local fs = require 'fs'
local fw

local log
local function saveLog()
    fs.writeFileSync('./log.log', log)
end

local function wlog(s)
    log = log  .. s .. '\n'
end

-- callbacks
function logger.config()
    return {
        name = 'Logger',
        author = 'BluRayFox',
        version = '0.1'
    }
end

function logger.init(f)
    fw = f
    log = fs.readFileSync('./log.log') or ''
end

function logger.onServerStart(...)
    wlog('----------')
    wlog('Server Started')
end

function logger.onServerRequest(req, res)
    local m = [[New Server Request: 
    Method: %s
    ULR: %s
    From: %s
    Rate Limited: %s
]]

    wlog(m:format(req.method:upper(), req.url, req.socket:address().ip, req.rateLimited or 'Unknown'))
end

function logger.onRouteAdded(route)
    wlog('New Route Added: '.. "'" .. route .. "'")
end

function logger.onServerClose(...)
    wlog('Server Closed.')
    wlog('')
    saveLog()
end

return logger