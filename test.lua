--

local class = require "class"

--

local Animal = class:Animal {
    eyes = 144,
    ugly = true,
}

function Animal:init()
    print("Animal inited, name: "..self.name)
end

function Animal:die()
    print(self.name.." is dead now.")
end

--

local Koala = class:Koala {
    eyes = 2,
}:extends{ Animal }

function Koala:init()
    Koala.parent.init(self)
    print("Koala inited, name: "..self.name)
end

function Koala:say_hi()
    print(self.name.." says: Koalition!")
end

--

local ko = Koala:new{ name="Bimbo" }

print("ko.eyes: ", ko.eyes)
print("ko.ugly: ", ko.ugly)
print("ko.test: ", ko.test)

ko:say_hi()
ko:die()
