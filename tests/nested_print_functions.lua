local t = {
    a = print("a"),
    b = print("b"),
    c = {
        d = print("d"),
        e = print("e"),
        f = {
            g = print("g"),
            h = print("h")
        }
    },
    i = function() print("i") end,
    j = function() print("j") end,
    k = {
        l = function() print("l") end,
        m = function() print("m") end,
        n = {
            o = function() print("o") end,
            p = function() print("p") end
        }
    }
}

t.i()
t.j()
t.k.l()
t.k.m()
t.k.n.o()
t.k.n.p()

-- This will print
-- a
-- b
-- d
-- e
-- g
-- h
-- i
-- j
-- l
-- m
-- o
-- p