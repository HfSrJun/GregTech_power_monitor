local event=require("event")

local listener={}

function new_listener(signal,recall)
	local temp=event.listen(signal,recall)
    table.insert(listener,temp)
    return temp
end
function new_timer(interval,recall,times)
	local temp=event.timer(interval,recall,times)
    table.insert(listener,temp)
    return temp
end
function event_pull(signal,time)
    if time==nil then
        return event.pull(signal)
    else
        return event.pull(time,signal)
    end
end
function event_kill(id)
    event.cancel(id)
end
function event_clean()
	for _,id in ipairs(listener) do
        if type(id)=="number" then
            event.cancel(id)
        end
    end
end