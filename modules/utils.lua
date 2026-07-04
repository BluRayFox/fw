local utils = {}

local url = require('url')
local ocular = require 'ocular'

function utils.urlToTable(u)
    local parsed = url.parse(u).pathname

    local segments = {}

    for segment in parsed:gmatch("[^/]+") do
        table.insert(segments, segment)
    end

    return segments
end

return utils