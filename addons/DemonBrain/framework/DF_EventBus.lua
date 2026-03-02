-- ============================================================
-- DemonFramework - EventBus (Owner-safe version)
-- ============================================================

local DF = DemonFramework

DF.Events = DF.Events or {}
local EventBus = DF.Events

EventBus._listeners = {}

-- ---------------------------------------------------------------------------
-- Subscribe
-- ---------------------------------------------------------------------------

function EventBus:Subscribe(eventName, handler, owner)

    assert(type(eventName) == "string", "Event name must be string")
    assert(type(handler) == "function", "Handler must be function")

    self._listeners[eventName] = self._listeners[eventName] or {}

    table.insert(self._listeners[eventName], {
        handler = handler,
        owner = owner,
    })
end

-- ---------------------------------------------------------------------------
-- Unsubscribe specific handler
-- ---------------------------------------------------------------------------

function EventBus:Unsubscribe(eventName, handler)

    local listeners = self._listeners[eventName]
    if not listeners then return end

    for i = #listeners, 1, -1 do
        if listeners[i].handler == handler then
            table.remove(listeners, i)
        end
    end
end

-- ---------------------------------------------------------------------------
-- Unsubscribe all handlers by owner
-- ---------------------------------------------------------------------------

function EventBus:UnsubscribeOwner(owner)

    for eventName, listeners in pairs(self._listeners) do

        for i = #listeners, 1, -1 do
            if listeners[i].owner == owner then
                table.remove(listeners, i)
            end
        end

        if #listeners == 0 then
            self._listeners[eventName] = nil
        end
    end
end

-- ---------------------------------------------------------------------------
-- Publish
-- ---------------------------------------------------------------------------

function EventBus:Publish(eventName, payload)

    local listeners = self._listeners[eventName]
    if not listeners then return end

    for _, listener in ipairs(listeners) do

        local ok, err = pcall(listener.handler, payload)

        if not ok and DF.Logger then
            DF.Logger:Error("Event error: " .. tostring(err), "EventBus")
        end
    end
end