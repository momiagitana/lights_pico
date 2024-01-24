white=7
grey=6
yellow=10
orange=9
red=8
pink=15
l_blue=12

rad=3
leg_h=rad*2
top_leg_dx = 2
bottom_leg_dx = 3
legs_start={
	{0,0},
	{rad,0},
	{rad,ceil(rad/2)},
	{rad,rad},
	{0,rad},
	{0,ceil(rad/2)}
}

legs_end_d={
	{-top_leg_dx,-leg_h},
	{top_leg_dx,-leg_h},
	{leg_h,0},
	{bottom_leg_dx,leg_h},
	{-bottom_leg_dx,leg_h},
	{-leg_h,0}
}

node=entity:new({
    _x=64,
    _y=64,
    _row=0,
	_legs={1,2,3,4,5,6},
	_id=0,
	_potencial_ngbs={},
	_actual_ngbs={},
	_on=false,
    _selected=false,

    toggle_select=function(_ENV)
        _selected = not _selected
    end,

    update=function(_ENV)
	end,

    spin=function(_ENV, amount)
        while amount != 0 do
            rotate(_ENV)
            amount -= 1
        end
    end,

	rotate=function(_ENV, back)
        back = back or false
        dir = 1
        if (back) dir = -1
        rot={}
		for leg in all(_legs) do
            leg += (1 * dir)
			if (leg > 6) leg = 1
			if (leg < 1) leg = 6
            add(rot, leg)
		end
        _legs = rot
	end,

    toggle_on=function(_ENV)
        _on = not _on
    end,

	draw=function(_ENV)
        for leg in all(_legs) do
            s = legs_start[leg]
            x1=_x+s[1]
            y1=_y+s[2]
            d = legs_end_d[leg]
            x2=x1+d[1]
            y2=y1+d[2]
            line(x1,y1,x2,y2,white)
        end
        clr=grey
        if (_on) clr=yellow
        if (_selected) clr=red
        if (_on and _selected) clr=orange
        ovalfill(_x,_y,_x+rad,_y+rad,clr)
	end,
})