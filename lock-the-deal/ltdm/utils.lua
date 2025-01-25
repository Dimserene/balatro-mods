function LTDM.utils.keybind_activate(self)
    print("Hello World!")
end


function LTDM.utils.check_keybind(self)
    local parent = self.parent()
    local status = 0 -- 0 sucess, 1 key invalid, 2 key exists

    -- Check for keybind value
    local keybind = parent.mod.config.lock_keybind
    if string.len(keybind or "") ~= 1 then
        return 1
    end

    -- Do nothing
    if keybind:lower() == parent.state.lock_keybind then return 0 end

    -- Check for keybind on SMODS global
    for _, v in pairs(SMODS.Keybinds --[=[@as SMODS.Keybind[]]=]) do
        if v.key_pressed == keybind:lower() then status = 2; break end
    end

    return status
end


function LTDM.utils.update_lock_keybind(self)
    local parent = self.parent()
    local mconfig = parent.mod.config

    if not mconfig.lock_default_keybind then return end

    -- keybind not initialized when mod is loaded
    if not parent.state.keybind and mconfig.lock_keybind_enable then
        parent.state.keybind = SMODS.Keybind({
            action = function () self:keybind_activate() end,
            key_pressed = parent.state.lock_keybind,
            event = 'pressed',
        })

        return true
    end

    -- update keybind
    if parent.state.keybind then parent.state.keybind.key_pressed = parent.state.lock_keybind end
end


function LTDM.utils.save_config(self)
    local parent = self.parent()
    local mconfig = parent.mod.config

    -- don't save empty or invalid keybinds
    if parent.utils:check_keybind() ~= 0 then
        mconfig.lock_keybind = parent.state.lock_keybind:upper()
    end

    SMODS.save_mod_config(parent.mod)
end


function LTDM.utils.generate_uuid()
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    local uuid = template:gsub("[xy]", function (c)
        return string.format("%x", (c == "x" and math.random(0, 15) or math.random(8, 11)))
    end)

    return uuid
end


function LTDM.utils.get_ehnacement_key(ability)
    -- Check for ability
    if not ability then return nil end

    local key = nil
    for k, v in ipairs(G.P_CENTERS) do
        -- Check for valid card
        if v.name == ability.name and v.set == "Enhanced" then
            key = k

            break
        end
    end

    return key
end


function LTDM.utils.copy_table(stable)
    local output = {}
    for k, v in pairs(stable) do
        if type(v) == 'table' then
            output[k] = LTDM.utils.copy_table(v)
        else
            output[k] = v
        end
    end

    return output
end


function LTDM.utils.debug(self, msg, funcv)
    local parent = self.parent()
    local message = (msg and funcv and "%s:%d %s() - %s") or (funcv and "%s:%d %s()") or ""

    local func = (type(funcv) == "function" and debug.getinfo(funcv)) or funcv
    if func then
        message = string.format(message, func.short_src, func.linedefined, func.name or "anonymous", msg)
    else
        message = msg or ""
    end

    sendDebugMessage(message, parent.mod_id)
end
