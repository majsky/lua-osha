package = "osha"
version = "scm-1"
source = {
    url = "git+https://github.com/majsky/lua-osha.git"
}
description = {
    summary = "A factorio server autoupdate script",
    homepage = "https://github.com/majsky/lua-osha",
    license = "DWYW"
}
dependencies = {
    "lua >= 5.1, < 5.4",
    "http >= 0.4",
    "dkjson >= 2.8",
    "argparse >= 0.7.1"
}
build = {
    type = "builtin",
    modules = {
        ["osha"] = "osha.lua",
        ["osha.factorio"] = "osha/factorio.lua",
        ["osha.updater"] = "osha/updater.lua"
    }
}
