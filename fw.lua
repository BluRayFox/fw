getfenv(0).require = require -- luvit fix

package.path = './modules/?.lua;'
    .. './?/init.lua'
    .. package.path

local http = require 'http'
local https = require 'https'
local path = require 'path'
local url = require 'url'
local json = require 'json'
local q = require 'querystring'
local fs = require 'fs'

local ocular = require 'ocular'
local utils = require 'utils'
local router = require 'router' .new()

local fw = {}
fw.version = '0.1'
fw.config = {}
fw.bind = { host = '127.0.0.1', port = 8080 }
fw.cert = {}
fw.rateLimited = {}
fw.debug = false
fw.extensions = {}
fw.extensionNextID = 1
fw.showExtensionWarning = true

-- Debug Print.
local function dprint(...)
    if fw.debug then
        print(...)
    end
end

local function fireextensionCb(cbName, ...)
    -- print(ocular.look(fw.extensions))
    for name, ext in pairs(fw.extensions) do
        if ext.extension[cbName] then
            local success, err = pcall(ext.extension[cbName], ...)
            if not success then
                print(('Unable to process callback for %s: %s'):format(name, err))
            end

        end
    end
end

function fw.setConfig(config)
    fw.config = config
    return fw
end

function fw.addRoute(route, f)
    
    local env = {}
    setmetatable(env, {__index = _G})

    env.print = function(...)
        local msg = '[%s]: %s'
        local args = {...}

        msg = msg:format(route, table.concat(args, '  '))
        
        io.write(msg .. '\n')
        io.flush()
    end

    env.dprint = dprint

    setfenv(f, env)
    router:addRoute(route, f)

    return fw
end

-- Load cerificates
function fw.loadCert(c, k)
    local cert, key = fs.readFileSync(c), fs.readFileSync(k)
    fw.cert.cert = cert
    fw.cert.key = key
    return fw
end

function fw.bindTo(data)
    
    local d = {}
    d.host = data.host or '127.0.0.1'
    d.port = data.port

    fw.bind = d


    return fw
end

function fw.startServer(useHttps)

    local function cb(req, res)
        -- error('Force error crash')
        local pathname = url.parse(req.url).pathname
        local handler, params = router:match(pathname)

        dprint(('%s -> [%s]'):format(req.method:upper(), pathname))
        fireextensionCb('onServerRequest', req, res)

        if res.headersSent then
            print('Looks like one of the extensions already handled the response.')
            return
        end

        if not handler then
            res.statusCode = 404
            res:finish('404: Not Found')
            return
        else
            req.params = params
            handler(req, res)
        end
    end

    local cbWrapper = function(req, res)
        local success, err = pcall(cb, req, res)

        if not success then
            print('Unable to complete the callback: '..err..'; Server will return 500 status code.')
            res.statusCode = 500
            res:finish('500: Server Unable to Process the Request.')
        end
    end


    local server
    if useHttps then
        server = https.createServer(fw.cert, cbWrapper)
    else
        server = http.createServer(cbWrapper)
    end

    server:listen(fw.bind.port, fw.bind.host, function()

        process:on('sigint', function()
            dprint("\nCtrl+C detected! Cleaning up...")
            
            server:close(function(...)
                fireextensionCb('onServerClose', ...)
                dprint("Server closed. Exiting process.")
                
                process:exit(0)
            end)
        end)

        fireextensionCb('onServerStart', fw.bind.port, fw.bind.host)
       
        print(('Running Server on %s://localhost%s!'):format(
        
        useHttps and 'https' or 'http',
        useHttps and (fw.bind.port == 433 and '' or (':' .. fw.bind.port)) or (fw.bind.port == 80 and '' or (':' .. fw.bind.port))
    
    ))
    end)

    fw.server = server


    return fw
end

function fw.stopServer()
    fw.server:close()
    fw.server = nil

    return fw
end

function fw.enableDebug()
    fw.debug = true

    dprint('Debug enabled')

    return fw
end

function fw.addExtension(ext)
    local extension

    local ID = fw.extensionNextID

    if type(ext) == "string" then
        extension = loadstring(ext)()
    elseif type(ext) == 'function' then
        extension = ext()
    elseif type(ext) == 'table' then
        extension = ext
    else
        error('unsupported type', 2)
    end
    
    if fw.showExtensionWarning then
        fw.showExtensionWarning = false
        print('It seems like youre using extensions. \nWhen using extensions, keep in mind: order is important.')
    end

    local config = {}

    if extension.config then
        config = extension.config() or {}
    end

    local name = config.name or ('Unknownextension'..ID)
    fw.extensions[config.name] = {config = config, extension = extension}

    if extension.init then
        extension.init(fw, ID)
    end


    return fw
end


return fw

