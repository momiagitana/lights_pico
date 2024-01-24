
function draw_game()
    cls()
    ctrl:draw()
end

function update_game()
    if g_game_state == "init_lvl" then
        g_game_state = ctrl:randomize_lvl()
    elseif g_game_state == "playing" then
        handle_game_input()
        ctrl:update_timer()
    end
end


function handle_game_input()
    if not ctrl._finished == true then
        if btnp(❎) then
            ctrl:rotate()
        end
        if btnp(🅾️) then
            ctrl:rotate(true)
        end
        if btnp(1) then
            ctrl:move({3})
        end
        if btnp(0) then
            ctrl:move({6})
        end
        if btnp(2) then
            ctrl:move({1, 2})
        end
        if btnp(3) then
            ctrl:move({5, 4})
        end
    else
        if btnp(❎) then
            if ctrl._single_game == true then
                init_menu()
            else
                next_lvl()
            end
        end
    end
end

center_x = 63
center_y = 63
width=16
dy = 16

function opposite_leg(dir)
    if (dir == 1) return 4
    if (dir == 2) return 5
    if (dir == 3) return 6
    if (dir == 4) return 1
    if (dir == 5) return 2
    if (dir == 6) return 3
end

function set_actual_nbgs_one(_nodes, to_check) --this function needs to be called for every node
    pot_ngbs = _nodes[to_check]._potencial_ngbs

    ngbs = {}
    for dir=1, 6 do
        a = contains(_nodes[to_check]._legs, dir)
        neighbour = pot_ngbs[dir]
        b = neighbour != -1 and contains(_nodes[neighbour]._legs, opposite_leg(dir))
        if a and b then
            add(ngbs, neighbour)
        end
    end
    _nodes[to_check]._actual_ngbs = ngbs
end

function calc_row_type(row, _rows)
    mid_row = ceil(_rows/2)
    if (row < mid_row) return "ascending"
    if (row > mid_row) return "descending"
    return "midle"
end

function init_node_count(lvl)
    sum = 0
    for row_size = lvl.first, lvl.mid do
        sum += row_size * 2
    end
    sum -= lvl.mid
    return sum
end

function init_rows(lvl)
    return (lvl.mid - lvl.first) * 2 + 1
end

level_controller=entity:new({
    _nodes={},
    _selected=1,
    _finished=false,
    _init_step=0,
    _node_for_init=1,
    _first_row_count = 0,
    _mid_row_count = 0,
    _node_count = 0,
    _rows = 0,
    _midle_row = 0,
    _time = 0,
    _last = 0,
    _single_game = true,
    _lvl = 0,

    init=function(_ENV, lvl) --todo: organize
        _init_step = 0
        _selected = 1
        _node_for_init=1
        _finished = false
        _lvl = lvl
        if lvl == record_mode then
            _single_game = false
            _lvl = 1
        end

        lvl = lvls[_lvl]
        _first_row_count = lvl.first
        _mid_row_count = lvl.mid
        _node_count = init_node_count(lvl)
        _rows = init_rows(lvl)
        _midle_row = ceil(_rows/2)
        if _single_game == true then
            _time = 0
        end
        _last = time()

        _nodes = create_nodes(_ENV)
        set_actual_nbgs_all(_ENV)
        -- randomize_lvl(_ENV) -- main randomizes so it can be displayed
        _nodes[ceil((#_nodes)/2)]:toggle_on()
        _nodes[_selected]:toggle_select()
        run_bfs(_ENV)
    end,

    create_nodes=function(_ENV)
        _nodes = {}
        for row = 1, _rows do
            amount = _mid_row_count - abs(_midle_row - row)
            y = center_y - (dy * (_midle_row - row))
            x = (128 - width * amount) / 2 + 6 -- todo 6 = side arm len
            for n = 1, amount do
                add(_nodes, node:new({_x=x, _y=y, _row=row, _legs={1,2,3,4,5,6}}))
                x += width
            end
        end
        set_potencial_ngbs(_ENV)
        return _nodes
    end,

    randomize_lvl=function(_ENV)
        state = "init_lvl"
        if _init_step == 0 then
            done = delete_some_random_stepped(_ENV)
            if (not done) return state
        elseif _init_step == 1 then
            done = delete_max_possible_stepped(_ENV)
            if (not done) return state
        elseif _init_step == 2 then
            done = spin_stepped(_ENV)
            if (not done) return state
        end

        _init_step += 1
        if (_init_step == 3) then
            state = "playing"
            run_bfs(_ENV)
        end
        return state
    end,

    -- delete_some_random=function(_ENV)
    --     while run_bfs(_ENV) do
    --         i = (ceil(rnd(#_nodes)))
    --         leg  = (ceil(rnd(6)))--todo g_legs
    --         remove_leg(_ENV, i, leg)
    --     end
    --     add_leg(_ENV, i, leg)
    -- end,

    delete_some_random_stepped=function(_ENV)
        i = (ceil(rnd(#_nodes)))
        leg  = (ceil(rnd(6)))--todo g_legs
        remove_leg(_ENV, i, leg)

        res = run_bfs(_ENV)
        if not res then
            add_leg(_ENV, i, leg)
            return true
        end
        return false
    end,

    -- delete_max_possible=function(_ENV)
    --     for node=1, #_nodes do
    --         test_legs = {1, 2, 3, 4, 5, 6}
    --         while #test_legs != 0 do
    --             leg = test_legs[ceil(rnd(#test_legs))]
    --             del(test_legs, leg)
    --             remove_leg(_ENV, node, leg)
    --             if (not run_bfs(_ENV)) add_leg(_ENV, node, leg)
    --         end
    --     end
    -- end,

    delete_max_possible_stepped=function(_ENV)
        if (_node_for_init > #_nodes) return true

        test_legs = {1, 2, 3, 4, 5, 6}
        while #test_legs != 0 do
            leg = test_legs[ceil(rnd(#test_legs))]
            del(test_legs, leg)
            remove_leg(_ENV, _node_for_init, leg)
            if (not run_bfs(_ENV)) add_leg(_ENV, _node_for_init, leg)
        end
        _node_for_init += 1
        return false
    end,

    -- spin=function(_ENV)
    --     for node=1, #_nodes do
    --         _nodes[node]:spin(ceil(rnd(5)))
    --     end
    --     set_actual_nbgs_all(_ENV)
    -- end,

    spin_stepped=function(_ENV)
        _node_for_init -= 1
        if (_node_for_init < 1) return true

        _nodes[_node_for_init]:spin(ceil(rnd(5)))
        set_actual_nbgs_all(_ENV)
        return false
    end,

    remove_leg=function(_ENV, i, leg)
        del(_nodes[i]._legs, leg)
        set_actual_nbgs_all(_ENV)
    end,

    add_leg=function(_ENV, i, leg)
        node = _nodes[i]
        legs = node._legs
        add(legs, leg)
        set_actual_nbgs_all(_ENV)
    end,

    run_bfs=function(_ENV)
        turn_all_off(_ENV)
        mid_node = ceil((#_nodes)/2)
        visited = {mid_node}
        queue = {mid_node}

        while #queue > 0 do
            curr = deli(queue, 1) -- pop first
            _nodes[curr]._on = true
            ngbs = _nodes[curr]._actual_ngbs
            for ngb in all(ngbs) do
                if not contains(visited, ngb) then
                    add(queue, ngb)
                    add(visited, ngb)
                end
            end
        end
        return all_on(_ENV)
    end,

    turn_all_off=function(_ENV)
        for i=1, #_nodes do
            _nodes[i]._on = false
        end
    end,

    all_on=function(_ENV)
        for i=1, #_nodes do
            if (_nodes[i]._on == false) return false
        end
        return true
    end,

    update_timer=function(_ENV)
        if not _finished and _single_game == false then
            _time += time() - _last
            _last = time()
        end
    end,

    print_time=function(_ENV)
        if _single_game == false then
            s = flr(_time)
            ms = flr((_time - s) * 100)
            print(s.."."..ms, 105, 4, white)
        end
    end,

    draw=function(_ENV)
        print_time(_ENV)
        for node in all(_nodes) do
            node:draw()
        end
        if _finished == true then
            draw_you_won(_ENV)
        end
    end,

    draw_you_won=function(_ENV)
        print("you won!", 2, 4, red)
        next = "back to menu"
        if (_single_game == false) next = "continue"
        print("❎: "..next, 2, 120, red)
    end,

    rotate=function(_ENV, back)
        _nodes[_selected]:rotate(back)
        set_actual_nbgs_all(_ENV)
        if (run_bfs(_ENV)) _finished = true
    end,

    move=function(_ENV, dirs)
        for dir in all(dirs) do
            ngb = _nodes[_selected]._potencial_ngbs[dir]
            if ngb != -1 then
                _nodes[_selected]:toggle_select()
                _selected = ngb
                _nodes[_selected]:toggle_select()
                return
            end
        end
    end,

    generate_potencial_ngbs=function(_ENV, row_size, node, type)
        local ngbs={}
        row = _nodes[node]._row

        l = node - 1
        r = node + 1
        tl = node - row_size
        tr = node - row_size + 1
        bl = node + row_size
        br = node + row_size + 1
        if type == "descending" then
            tl -= 1
            tr -= 1
            bl -= 1
            br -= 1
        end
        if type == "midle" then
            bl -= 1
            br -= 1
        end

        if (not (exists(_ENV, tl) and row == _nodes[tl]._row + 1)) tl = -1
        if (not (exists(_ENV, tr) and row == _nodes[tr]._row + 1)) tr = -1
        if (not (exists(_ENV, r)  and row == _nodes[r]._row))      r = -1
        if (not (exists(_ENV, br) and row == _nodes[br]._row - 1)) br = -1
        if (not (exists(_ENV, bl) and row == _nodes[bl]._row - 1)) bl = -1
        if (not (exists(_ENV, l)  and row == _nodes[l]._row))      l = -1

        add(ngbs, tl)
        add(ngbs, tr)
        add(ngbs, r)
        add(ngbs, br)
        add(ngbs, bl)
        add(ngbs, l)
        return ngbs
    end,

    set_potencial_ngbs=function(_ENV)
        for i=1, #_nodes do
            row = _nodes[i]._row
            amount = _mid_row_count - abs(_midle_row - row)
            row_type = calc_row_type(row, _rows)
            ngbs = generate_potencial_ngbs(_ENV, amount, i, row_type)
            _nodes[i]._potencial_ngbs = ngbs
        end
    end,

    set_actual_nbgs_all=function(_ENV)
        for i=1, #_nodes do
            set_actual_nbgs_one(_nodes, i)
        end
    end,

    exists=function(_ENV, node)
        if (node <= 0) return false
        if (node > _node_count) return false
        return true
    end,

})
