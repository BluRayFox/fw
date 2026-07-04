-- Extension Example: Rate Limiter

local rateLimiter = {}

local fw

-- Settings
local LimitTime  = 60 -- Penalty duration in seconds
local MaxRequestsPerSec = 6 -- Max requests allowed per second

-- Data
local rateLimitedIPs = {} -- Tracks WHO is banned and UNTIL when
local requests = {}       -- Tracks IP request counts: { [ip] = { timestamp = X, count = Y } }

local function isLimited(ip)
    local banExpiration = rateLimitedIPs[ip]
    if not banExpiration then return false end

    local now = os.time()
    if now > banExpiration then 
        rateLimitedIPs[ip] = nil -- Ban expired, clear it
        return false 
    end

    return true
end

local function limit(ip)
    rateLimitedIPs[ip] = os.time() + LimitTime
end

function rateLimiter.config()
    return {
        name = 'RateLimiter',
        author = 'BluRayFox',
        version = '0.1'
    }
end

function rateLimiter.init(f)
    fw = f
end

function rateLimiter.onServerRequest(req, res)
    local ip = req.socket and req.socket:address().ip or "unknown_ip"
    local now = os.time()

    if isLimited(ip) then
        res.statusCode = 429
        res:finish('429 Too Many Requests. You are rate limited.')
        req.rateLimited = true
        return
    end

    if not requests[ip] or requests[ip].timestamp ~= now then
        requests[ip] = { timestamp = now, count = 1 }
    else
        requests[ip].count = requests[ip].count + 1
    end
    if requests[ip].count > MaxRequestsPerSec then
        limit(ip)
        requests[ip] = nil
        res.statusCode = 429
        res:finish('429 Too Many Requests. You are rate limited.')
        req.rateLimited = true
    else
        req.rateLimited = false
    end
end

return rateLimiter
