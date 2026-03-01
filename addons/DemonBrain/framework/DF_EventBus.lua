-- DemonFramework EventBus (stub)

local DF = DemonFramework

DF.EventBus = DF.EventBus or {}

local EventBus = DF.EventBus

EventBus._listeners = {}

function EventBus:Register(eventName, callback)
    if not self._listeners[eventName] then
        self._listeners[eventName] = {}
    end

    table.insert(self._listeners[eventName], callback)
end

function EventBus:Emit(eventName, ...)
    local listeners = self._listeners[eventName]
    if not listeners then return end

    for _, callback in ipairs(listeners) do
        callback(...)
    end
end