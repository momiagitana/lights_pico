function log(t, o)
    o = o or false --dont override by default
    printh(t, "log", o)
end

function contains(table, val)
    for i=1,#table do
       if table[i] == val then
          return true
       end
    end
    return false
end

function log_table(tbl)
    for i=1, #tbl do
        log(tbl[i])
    end
end