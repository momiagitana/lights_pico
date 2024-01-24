
function draw_ldb()
    ldb:draw()
end

function update_ldb()
    if btnp(❎) then
        if ldb._state == "adding" then
            ldb:select()
        else
            init_menu()
        end
    end
    if btnp(🅾️) then
        if ldb._state == "adding" then
            ldb:delete()
        else
            init_menu()
        end
    end
    if btnp(1) then
        -- ctrl:move({3})
    end
    if btnp(0) then
        -- ctrl:move({6})
    end
    if btnp(2) then
        ldb:up()
    end
    if btnp(3) then
        ldb:down()
    end
end

g_name_len = 3

leaderboard=entity:new({
    _state = "displaying",
    _scores = {},
    _name = "",
    _n_indx = 1,
    _current_letter = "a",
    _score = 0,
    _mem_amount = 0,

    load=function(_ENV)
        _scores = {}
        _mem_amount = dget(0)
        -- log("mem_amount: ".._mem_amount)

        for each=1, _mem_amount do
            name_indx  = indx_to_name(each)
            score_indx = indx_to_score(each)
            name = number_to_name(dget(name_indx))
            -- log(name)
            score = dget(score_indx)
            insert_ordered(_scores, name, score)
            -- _scores[name] = score
        end
    end,

    init_for_adding=function(_ENV, score)
        load(_ENV)
        _state = "adding"
        _score = score
    end,

    init_for_displaying=function(_ENV, score)
        load(_ENV)
    end,

    draw=function(_ENV)
        cls()
        if _state == "adding" then
            draw_adding(_ENV)
        elseif _state == "displaying" then
            draw_displaying(_ENV)
        end
    end,

    draw_adding=function(_ENV)
        print("⬆️ and ⬇️ to write your name", 10, 10, white)
        x = 10
        y = 50
        for i = 1, g_name_len do
            char = '_'
            if (i <= #_name) char = _name[i]
            clr = white
            if (i == _n_indx) char = _current_letter clr = red
            print(char, x, y, clr)
            x += 6
        end
        x += 10
        print("score: ".._score, x, y, white)

        bottom_text = "❎: save - 🅾️: erase"
        if (#_name < 2) bottom_text = "❎: select - 🅾️: erase"
        print(bottom_text, 10, 120, white)
    end, --todo fix bug letters when deleting

    draw_displaying=function(_ENV)
        print("behold the leaderboard", 10, 10, white)

        x = 20
        y = 30
        -- log(#_scores)
        for i=1, min(#_scores, 9) do --todo: 9=max scores to display
            k = _scores[i][1]
            v = _scores[i][2]
            -- log(k)
            -- log(v)
            print(k..": "..v, x, y, white)
            y += 10
        end
        print("❎ or 🅾️: back to menu", 10, 120, white)
    end,

    select=function(_ENV)
        _name = _name.._current_letter
        if _n_indx < g_name_len then
            _n_indx += 1
        elseif _n_indx == g_name_len then -- todo: and #name == g_n_l ?
            save_score(_ENV)
            _state = "displaying"
        end
    end,

    delete=function(_ENV)
        if #_name > 0 then
            _name = sub(_name, 1, #_name - 1)
            _n_indx -= 1
        end
    end,

    save_score=function(_ENV)
        insert_ordered(_scores, _name, _score)
        -- _scores[_name] = _score
        _mem_amount += 1
        dset(0, _mem_amount)
        dset(indx_to_name(_mem_amount), name_to_num(_name))
        dset(indx_to_score(_mem_amount), _score)
    end,

    up=function(_ENV)
        _current_letter = chr(ord(_current_letter) + 1)
        if (ord(_current_letter) > ord("z")) _current_letter = "a"
    end,

    down=function(_ENV)
        _current_letter = chr(ord(_current_letter) - 1)
        if (ord(_current_letter) < ord("a")) _current_letter = "z"
    end,

})

function name_to_num(name)
    local num = 0
    for i = 1, #name do
        local char = sub(name, i, i)
        num = num * 26 + (ord(char) - ord("a") + 1)
    end
    return num
end

function number_to_name(num)
    local name = ""
    letters = 3
    while letters > 0 do
        local remainder = num % 26
        if remainder == 0 then remainder = 26 end
        name = chr(ord("a") + remainder - 1) .. name
        num = (num) / 26
        letters -= 1
    end
    return name
end

function indx_to_name(indx)
    return ((indx * 2) - 1)
end

function indx_to_score(indx)
    return (indx * 2)
end

function insert_ordered(list, name, score)
    -- log("inserting")
    i = 1
    while i <= #list and list[i][2] <= score do
        i += 1
    end
    -- log("index: "..i.." name: "..name.." score: "..score)
    add(list, {name, score}, i)
end