-- WIP
-- Anubis like thingy

local niko = {}

local utils = require 'utils'
local fw 

local passed = {}
local blocked = {}

function niko.config()
    return {
        name = 'Niko',
        author = 'BluRayFox',
        version = '0.1'
    }
end

function niko.init(f)
    fw = f

    fw
    .addRoute('/niko/api/test', function(req, res)
        res:finish('lol')
    end)

end

function niko.onServerRequest(req, res)
    local ip = req.socket:address().ip
    local segments = utils.urlToTable(req.url)

    if segments[1] ~= 'niko' and segments[2] ~= 'api' then
        if not passed[ip] then
            res:finish('You are not passed the check yet!')
        elseif blocked[ip] then
            res:finish('You did not passed the bot check!')
        end
    end

end

return niko