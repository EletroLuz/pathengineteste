-- Import menu elements
local menu = require("menu")

-- Variáveis globais
local plugin_enabled = false
local target_object = nil

-- Função para encontrar o objeto mais próximo
local function find_nearest_object()
    local player_pos = get_player_position()
    local nearest_obj = nil
    local min_distance = math.huge

    local objects = actors_manager.get_ally_actors()
    for _, obj in ipairs(objects) do
        if obj and obj:get_skin_name():find("usz_rewardGizmo") then
            local obj_pos = obj:get_position()
            local distance = player_pos:dist_to(obj_pos)
            if distance < min_distance then
                min_distance = distance
                nearest_obj = obj
            end
        end
    end

    return nearest_obj
end

-- Função para mover o jogador até o objeto
local function move_to_object()
    if not target_object then
        target_object = find_nearest_object()
        if not target_object then
            console.print("No target object found.")
            return
        end
    end

    local player_pos = get_player_position()
    local obj_pos = target_object:get_position()
    local distance = player_pos:dist_to(obj_pos)

    if distance < 2.0 then
        console.print("Reached target object.")
        target_object = nil
    else
        -- Criar o caminho usando o motor do jogo
        local path = pathfinder.create_path_game_engine(obj_pos)
        
        -- Obter o próximo waypoint no caminho
        local next_waypoint = pathfinder.get_next_waypoint(player_pos, path, 1.0)
        
        -- Mover-se imediatamente para o próximo waypoint
        pathfinder.force_move(next_waypoint)
    end
end

-- Função chamada periodicamente para atualizar o movimento
on_update(function()
    if plugin_enabled then
        move_to_object()
    end
end)

-- Função para renderizar o menu
on_render_menu(function()
    if menu.main_tree:push("Pathfinder Test") then
        -- Renderiza o checkbox para habilitar/desabilitar o plugin
        local enabled = menu.plugin_enabled:get()
        if enabled ~= plugin_enabled then
            plugin_enabled = enabled
            if plugin_enabled then
                console.print("Pathfinder Test ativado")
            else
                console.print("Pathfinder Test desativado")
            end
        end
        menu.plugin_enabled:render("Ativar Pathfinder Test", "Ativa ou desativa o teste de pathfinding")

        menu.main_tree:pop()
    end
end)