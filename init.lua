customiserver ={}

--[[
--registro de privilegio (it's useful?')
minetest.register_privilege("customiserver", { description = "Permite usar customiserver .", give_to_singleplayer= false, })
]]--

--Registrar propiedades
customiserver.reg_props = function(player)
    local pmeta = player:get_meta()
    local data = { nick = player:get_player_name(), colour = "white" }
    pmeta:set_string("customiserver_data", minetest.serialize(data))
    local detail = minetest.deserialize(pmeta:get_string("customiserver_data"))
end

--Cambiar colores en el chat
minetest.register_on_chat_message(function(name, message)
    local pmeta = minetest.get_player_by_name(name):get_meta()
    local nick = minetest.deserialize(pmeta:get_string("customiserver_data")).nick
    local text = minetest.colorize(minetest.deserialize(pmeta:get_string("customiserver_data")).colour,"["..nick.."] > "..message)
    minetest.chat_send_all(text)
    return true
end)

--Actualizar nametag
customiserver.update_nametag = function(player)
local detail = minetest.deserialize(player:get_meta():get_string("customiserver_data"))
player:set_nametag_attributes({text = minetest.colorize(detail.colour,detail.nick)})
end

--Crear registro de las nuevas propiedades para jugador nuevo
minetest.register_on_newplayer(function(player)
customiserver.reg_props(player)
end)

--Verificar si un jugador existente tiene las propiedades y agragarlas de ser falso
minetest.register_on_joinplayer(function(player)
    local pmeta = player:get_meta():get_string("customiserver_data")
    local detail = minetest.deserialize(pmeta)
    if pmeta == nil or pmeta == "" then
        customiserver.reg_props(player)
    else
        customiserver.update_nametag(player)
    end
end)

--Comando para cambiar el color del chat
minetest.register_chatcommand("chat_color", {
    privs = {
        interact = true,
    },
    func = function(name, param)
        local pmeta = minetest.get_player_by_name(name):get_meta()
        local detail = minetest.deserialize(pmeta:get_string("customiserver_data"))
        local data = { nick = detail.nick, colour = param }
        pmeta:set_string("customiserver_data", minetest.serialize(data))
        customiserver.update_nametag(minetest.get_player_by_name(name))
        return true, minetest.colorize(minetest.deserialize(pmeta:get_string("customiserver_data")).colour,"Has cambiado el color del chat!")
    end,
})

--Comando para cambiar nickname 
minetest.register_chatcommand("nickname", {
    privs = {
        interact = true,
    },
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        local pmeta = minetest.get_player_by_name(name):get_meta()
        local detail = minetest.deserialize(pmeta:get_string("customiserver_data"))
        if param == "del" then
            local data = { nick = name, colour = detail.colour }
            pmeta:set_string("customiserver_data", minetest.serialize(data))
            customiserver.update_nametag(player)
            minetest.chat_send_player(name, "Nickname Borrado")
        else
            if string.len(param)>10 then
                minetest.chat_send_player(name, "El nombre no debe exceder los 10 carácteres")
            else
                if minetest.player_exists(param) then
                    minetest.chat_send_player(name, "No puedes usar el nombre de un jugador como nickname")
                else
                    local data = { nick = param, colour = detail.colour }
                    pmeta:set_string("customiserver_data", minetest.serialize(data))
                    customiserver.update_nametag(player)
                    return true, minetest.colorize(minetest.deserialize(pmeta:get_string("customiserver_data")).colour,"Has cambiado tu nickname!")
                end
            end
        end

    end,
})

minetest.register_craftitem("customiserver:lupa", {
description = "Te dice el nombre de un jugador",
inventory_image = "lupa.png",
wield_image = "lupa.png",
stack_max = 1,
on_use = function(itemstack, user, pointed_thing)
    if pointed_thing.type == "object" and minetest.is_player(pointed_thing.ref) then
        minetest.chat_send_player(user:get_player_name(),"this player is: "..pointed_thing.ref:get_player_name())
    end
end
})
