local argparse = require("argparse")
local json = require("dkjson")

local update = require("osha.updater")
local factorio = require("osha.factorio")

local function parseArgs()
    local parser = argparse("osha", "Factorio headless-server autoupdater")
    parser:argument("instance", "Factorio server instance name")
    parser:option("--config", "Config file.", "osha.json")
    parser:flag("-c --check", "Checks for updates")
    parser:flag("-b --backup", "Create new backup and exit")


    _G.args = parser:parse()
end

local function loadConfig()
    local fh = io.open(_G.args.config, "r")
    local strConfig = fh:read("*a")
    fh:close()
    
    _G.config = json.decode(strConfig)
end

local function updateAvail()
    return update.getLatestVersion() ~= factorio.getVersion()
end

local function download(url, outputPath)
    local cmd = config.downloadCommand:gsub("@URL", url):gsub("@FILE", outputPath)

    local status = os.execute(cmd)

    return status
end

local function applyUpdate(update)
    local updatePath = "/tmp/factorio_update_" .. update.from .. "-" .. update.to .. ".zip"

    print("Downloading update " .. update.from .. "->" .. update.to)
    if not download(update.url, updatePath) then
        print("Download failed")
        os.exit(1, true)
    end

    print("Applying update")
    if not factorio.applyUpdate(updatePath, update.to) then
        print("Applying failed.")
    end
end

return function()
    parseArgs()
    loadConfig()

    if args.backup then
        factorio.backup()
        os.exit(0, true)
    end

    if updateAvail() then
        if args.check then
            print("Update avaiable")
            print("Latest: " .. update.getLatestVersion())
            print("Server: " .. factorio.getVersion())
            os.exit(1, true)
        end

        if not factorio.isEmpty() then
            factorio.notice()
            os.exit(0, true)
        end

        local updates = update.getUpdatePackages(factorio.getVersion())
        print(#updates .. " update" .. ((#updates > 1) and "s" or "") .. " avaiable")

        factorio.backup()
        for _, update in ipairs(updates) do
            applyUpdate(update)
        end
    end

    print("Up to date.")
end
