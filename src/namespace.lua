local mt = {}

local function include(self, t)
    if(type(t) == "table") then 
        for k, v in pairs(t) do
            if(type(v) == "table" and type(k) == "number" and v.name ~= "name") then 
                if(v.class) then 
                    self[v.name] = v.class
                else 
                    self[v.name] = v 
                end
                _G[v.name] = nil


                v.namespace = self
            elseif (k ~= "name") then
                self[k] = v
            end 
        end 
    end 
    return self 
end 

local function newNamespace(this, name)
    assert(not _G[name], "")
    assert(type(name) == "string")

    local new = {} 

    new.name = name 

    setmetatable(new, mt)

    _G[name] = new

    return function (t)
        return include(new, t)
    end 
end 

local namespace = {}
setmetatable(namespace, mt)
mt.__call = newNamespace
mt.__index = {
    include = include 
}

return namespace