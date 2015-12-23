--

local class = {}

class.instanceof = function( ess, to )
    local mt1 = getmetatable(ess)
    local mt2 = getmetatable(to)

    return mt1 and mt2 and mt1.__instanceof == mt2.__class
end

class.clone = function( ess, cache )
    if type(ess) ~= "table" then
        return ess
    end

    local mt = getmetatable(ess)

    if mt and mt.__class then -- class
        return ess
    elseif mt and mt.__instanceof then -- instance
        return mt.__clone(ess, cache)
    else -- simple table
        cache = cache or {}

        if cache[ess] then
            return cache[ess]
        end

        local copy = {}
        cache[ess] = copy

        for k,v in pairs(ess) do
            copy[class.clone(k, cache)] = class.clone(v, cache)
        end

        setmetatable(copy, mt)

        return copy
    end
end

class.name = function( instance )
    local mt = getmetatable(instance)
    return mt and (mt.__class or mt.__instanceof)
end

-- local c = class:Test{ a=1, b="", ... }:extends{ ParentClass, OtherParent, ... }
setmetatable(class, {
    __index = function( _, name )
        local c = {} -- class
        local c_mt = {} -- class metatable
        local i_mt = {} -- instance metatable

        c_mt.__i_mt = i_mt
        c_mt.__class = name
        i_mt.__instanceof = name
        i_mt.__c_mt = c_mt

        c.parents = {}

        setmetatable(c, c_mt)

        function c:new( fields )
            local instance = setmetatable({}, i_mt)

            if type(fields) == "table" then
                for k,v in pairs(fields) do
                    rawset(instance, k, v)
                end
            end

            instance:init(fields)

            return instance
        end

        function c:extends( parents )
            if type(parents) ~= "table" then
                error("class "..tostring(name)..": extends: arg#1 must be a table")
            end

            for k,v in pairs(parents) do
                local mt = getmetatable(v)
                if not mt or not mt.__class then
                    error("class "..tostring(name)..": extends: arg#1: key#"..tostring(k)..": invalid class")
                end
            end

            c.parent = parents[1] -- self.parent.init(self) - for single inheritance
            c.parents = parents -- self.parents[2].init(self)

            return c
        end

        function c:init()
        end

        function c_mt:__call( _, fields )
            for k,v in pairs(fields) do
                rawset(c, k, v)
            end
            return c
        end

        function c_mt:__index( name )
            for _,v in pairs(c.parents) do
                if v[name] ~= nil then
                    c[name] = class.clone(v[name])
                    return c[name]
                end
            end
        end

        function i_mt:__index( name )
            if c[name] ~= nil then
                self[name] = class.clone(c[name])
                return self[name]
            end
        end

        function i_mt:__clone( cache )
            cache = cache or {}
            local copy = c:new{}
            for k,v in pairs(self) do
                copy[class.clone(k, cache)] = class.clone(v, cache)
            end
            return copy
        end

        return c
    end,
})

return class
