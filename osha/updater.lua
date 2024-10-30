local request = require ("http.request")
local json = require("dkjson")

local updater = {}

local _URLS = {
    LAST = "https://factorio.com/api/latest-releases",
    AVAIL = "https://updater.factorio.com/get-available-versions",
    GETLINK = "https://updater.factorio.com/get-download-link?username=@USER@&token=@TOKEN@&package=@PACKAGE@&from=@FROM@&to=@TO@&apiVersion=2"
}

local function _get(url)
    local req = request.new_from_uri(url)

    local headers, stream = req:go(10)
    if headers == nil then
        error(tostring(stream))
    end

    local body, err = stream:get_body_as_string()
    if not body and err then
        error(tostring(err))
    end

    return json.decode(body)
end

local latestVersion
function updater.getLatestVersion()
    if not latestVersion then
        latestVersion = _get(_URLS.LAST).stable.headless
    end

    return latestVersion
end

function updater.getUpdateLink(from, to)
    local url = _URLS.GETLINK
        :gsub("@USER@", _G.config.auth.username)
        :gsub("@TOKEN@", _G.config.auth.token)
        :gsub("@PACKAGE@", "core-linux_headless64")
        :gsub("@FROM@", from)
        :gsub("@TO@", to)

    return _get(url)[1]
end

function updater.getUpdatePackages(from)
    local packageList = _get(_URLS.AVAIL)["core-linux_headless64"]

    local updates = {}
    local lastUpdate = from

    while lastUpdate ~= updater.getLatestVersion() do
        for k, v in pairs(packageList) do
            if v.from and lastUpdate == v.from then
                v.url = updater.getUpdateLink(v.from, v.to)
                table.insert(updates, v)
                lastUpdate = v.to
                break
            end
        end
    end

    return updates
end

return updater
