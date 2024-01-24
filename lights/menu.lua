

function draw_menu()
    cls()
    m:draw()
end

function update_menu()
    handle_menu_input()
end

function handle_menu_input()
    if btnp(2) then
        m:move("up")
    end
    if btnp(3) then
        m:move("down")
    end

    if btnp(❎) then
        if m._state == "options" and m._selected != 0 then
            if m._options[m._selected] == "relax mode" then
                m._state = "relax mode"
            elseif m._options[m._selected] == "record mode" then
                init_game(record_mode)
            elseif m._options[m._selected] == "leaderboard" then
                show_leaderboard()
            end
        elseif m._state == "relax mode"  and m._lvl_selected != 0 then
            init_game(m._lvl_selected)
        end
    elseif btnp(🅾️) and m._state == "relax mode" then
        m._state = "options"
    end
end


menu=entity:new({
    _state = "options",

    _options={
        "relax mode",
        "record mode",
        "leaderboard",
        "instructions"
    },

    _lvls_text={
        "3x3",
        "5x4",
        "5x5",
        "7x5",
        "7x6",
        "7x7",
        "7x8",
    },

    _selected = 0,
    _lvl_selected = 1,

    move=function(_ENV, dir)
        if _state == "options" then
            move_menu(_ENV, dir)
        elseif _state == "relax mode" then
            move_lvl(_ENV, dir)
        end
    end,

    move_menu=function(_ENV, dir)
        if (dir == "up")   _selected -= 1
        if (dir == "down") _selected += 1

        if (_selected < 1)         _selected = #_options
        if (_selected > #_options) _selected = 1
    end,

    move_lvl=function(_ENV, dir)
        if (dir == "up")   _lvl_selected -= 1
        if (dir == "down") _lvl_selected += 1

        if (_lvl_selected < 1)           _lvl_selected = #_lvls_text
        if (_lvl_selected > #_lvls_text) _lvl_selected = 1
    end,

	draw=function(_ENV)
        print("LIGHTS", 10, 10, white)
        print("BY zavale", 20, 20, white)

        actions = "❎: select"
        if (_state == "relax mode") actions = actions.." - 🅾️: back"
        print(actions, 10, 118, white)

        x = 20
        y = 35
        for i = 1, #_options do
            clr = white
            if (i == _selected) clr = red
            print(_options[i], x, y, clr)
            y += 10
        end

        print_selected(_ENV)
	end,

    print_selected=function(_ENV)
        if _options[_selected] == "relax mode" then
            print_levels(_ENV)
        elseif _options[_selected] == "record mode" then
            print_record_mode(_ENV)
        elseif _options[_selected] == "leaderboard" then
            print_leaderboard(_ENV)
        elseif _options[_selected] == "instructions" then
            print_instructions(_ENV)
        end
    end,

    print_levels=function(_ENV)
        x = 90
        y = 35
        for i = 1, #_lvls_text do
            clr = grey
            if (i == _lvl_selected) clr = pink
            print(_lvls_text[i], x, y, clr)
            y += 10
        end
    end,

    print_leaderboard=function(_ENV)
        x = 20
        y = 85
        clr = orange
        print("see the best times", x, y, clr)
    end,

    print_record_mode=function(_ENV)
        x = 20
        y = 85
        clr = pink
        print("play all levels", x, y, clr)
        print("and compete for", x + 10, y + 10, clr)
        print("the fastest time", x + 20, y + 20, clr)
    end,

    print_instructions=function(_ENV)
        x = 80
        y = 35
        clr = l_blue
        print("move:", x, y, clr)
        print("⬆️⬇️⬅️➡️", x, y + 10, clr)
        print("rotate:", x, y + 25, clr)
        print("❎🅾️", x, y + 35, clr)
        x = 10
        y = 85
        print("rotate the nodes", x, y, clr)
        print("and connect them to", x + 5, y + 10, clr)
        print("expand the yellow light", x + 10, y + 20, clr)
        -- print("rotate the nodes,", x, y, clr)
        -- print("connect them,", x + 5, y + 10, clr)
        -- print("expand the yellow light", x + 10, y + 20, clr)
    end,
})