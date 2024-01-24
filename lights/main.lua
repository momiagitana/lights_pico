pal(0,129,1)

menuitem(1, "menu",
    function()
        init_menu()
    end
)

function _init()
    cartdata("zavale_lights_02")
    log("", true)
    -- set_record()
    init_menu()
end

function init_game(lvl)
    ctrl=level_controller:new({})
    ctrl:init(lvl)
    g_game_state = "init_lvl"
    _update = update_game
    _draw = draw_game
end

function init_menu()
    m=menu:new({})
    _draw = draw_menu
    _update = update_menu
end

function next_lvl()
    if ctrl._lvl < #lvls then
        ctrl:init(ctrl._lvl + 1)
        g_game_state = "init_lvl"
    else
        s = flr(ctrl._time)
        ms = flr((ctrl._time - s) * 100)
        set_record(tonum(s.."."..ms))
    end
end

function show_leaderboard()
    ldb=leaderboard:new({})
    ldb:init_for_displaying(score)
    _draw = draw_ldb
    _update = update_ldb
end

function set_record(score)
    ldb=leaderboard:new({})
    ldb:init_for_adding(score)
    _draw = draw_ldb
    _update = update_ldb
end
