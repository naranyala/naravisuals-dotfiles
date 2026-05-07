
function generate_plugins_info()
 local plugins_list = {}
    
    -- Check if Lazy is available
    if not pcall(require, "lazy") then
        return {}
    end

    -- Get plugins from Lazy config
    local lazy_config = require("lazy.core.config")
    local plugins = lazy_config.plugins

    -- Build plugin list
    for _, plugin in pairs(plugins) do
        if plugin.enabled ~= false then  -- Only include enabled plugins
            local location = plugin.dir or plugin.install_path or "unknown"
            plugins_list[#plugins_list + 1] = {
                name = plugin.name,
                location = location
            }
        end
    end

    return plugins_list
end

vim.api.nvim_create_user_command('PluginsInfo', function()
    local info = generate_plugins_info()
    -- print(info)

    local json_str = vim.inspect(info)
    print(json_str)

end, {})
