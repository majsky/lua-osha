local factorio = {}

local function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end


local function getServerRoot()
    return _G.config.serversDir .. "/" .. _G.args.instance
end

local function _exec(args)
    local binPath =  getServerRoot() .. "/bin/x64/factorio "
    local openPop = assert(io.popen(binPath .. args, 'r'))
    local output = openPop:read('*all')
    openPop:close()
    return output
end

local function getDate()
    local openPop = assert(io.popen("date --iso-8601=minutes", 'r'))
    local output = openPop:read('*all')
    openPop:close()
    return trim(output)
end

function factorio.getVersion()
    return _exec("--version"):match("^Version: (.+) %(")
end

function factorio.applyUpdate(updatePath, version)
    _exec("--apply-update " .. updatePath)

    if version then
        return version == factorio.getVersion()
    end
end

function factorio.backup()
    local filename = _G.config.backup.path .. "/" .. args.instance .. "-" .. getDate() .. ".tar"
    local cmd = _G.config.backup.command
        :gsub("@FILE", filename)
        :gsub("@SERVERSDIR", _G.config.serversDir)
        :gsub("@INSTANCE", _G.args.instance)

        os.execute(cmd)
end

function factorio.isEmpty()
    local cmd = string.gsub("tmux send-keys -t factorio-@INST '/players o' 'C-m'; sleep 1; tmux capture-pane -t factorio-@INST -p", "@INST", _G.args.instance)

    local handle = assert(io.popen(cmd, "r"))

    local output = {}
    for line in handle:lines() do
        table.insert(output, line)
    end

    local count = nil
    for i = #output, 1, -1 do
        count = output[i]:match("Online players %((%d)%)")

        if count then
            count = tonumber(count)
            break
        end
    end

    return count == 0
end

function factorio.notice()
    local cmd = string.gsub("tmux send-keys -t factorio-@INST 'Updates avaiable.' 'C-m'", "@INST", _G.args.instance)
    os.execute(cmd)
end

function factorio.stop()
    local cmd = string.gsub("tmux send-keys -t factorio-@INST 'C-c'", "@INST", _G.args.instance)
    os.execute(cmd)
end

return factorio
