local alarm_usage_1=0.5
local alarm_usage_2=0.2
local alarm_time_1=1800
local alarm_time_2=300
local alarm_interval_1=120
local alarm_interval_2=30
local check_interval=5

alarming="normal"
local alarm_waiting=false
local checking=false
local last_alarm="normal"
local alarm_event_id
alarm_disabled=false

local function alarm_level()
    if maintain then
        return "maintain"
    end
    if (EU_usage<=alarm_usage_2 and EU_time<=0) or (EU_time<0 and EU_time>-alarm_time_2) then
        return "red"
    end
    if (EU_usage<=alarm_usage_1 and EU_time<=0) or (EU_time<0 and EU_time>-alarm_time_1) then
        return "yellow"
    end
    return "normal"
end
local function reset_alarm()   
    if type(alarm_event_id)=="number" then
        event_kill(alarm_event_id)
        alarm_event_id=nil
    end
    alarm_waiting=false
end
local function trigger_alarm(level)
    reset_alarm()
    alarm_waiting=true
    if level=="yellow" then
        alarm_event_id=new_timer(alarm_interval_1,reset_alarm,1)
    else
        alarm_event_id=new_timer(alarm_interval_2,reset_alarm,1)
    end
    alarm()
    last_alarm=level
end
function alarm_check()
    alarming=alarm_level()
    local triggered=false
    if alarm_disabled then
        return
    end
    if alarming=="maintain" then
        if alarm_waiting then
            if last_alarm~="maintain" then
                trigger_alarm("maintain")
                triggered=true
            end
        else
            trigger_alarm("maintain")
            triggered=true
        end
    end
    if alarming=="red" then
        if alarm_waiting then
            if last_alarm=="yellow" or last_alarm=="normal" then
                trigger_alarm("red")
                triggered=true
            end
        else
            trigger_alarm("red")
            triggered=true
        end
    end
    if alarming=="yellow" then
        if alarm_waiting then
            if last_alarm=="normal" then
                trigger_alarm("yellow")
                triggered=true
            end
        else
            trigger_alarm("yellow")
            triggered=true
        end
    end
end
function alarm()
    if alarming=="normal" then
        last_alarm="normal"
        return false
    end
    if alarming=="maintain" then
        last_alarm="maintain"
        local x,y,z=mach.getCoordinates()
        logger_f("电容库需要维护","alarm","WARN")
        logger_c("电容库需要维护","alarm","WARN")
        cb.say("§c电容库故障  需要维护")
        cb.say("坐标位于 X:"..x.." Y:"..y.." Z:"..z)
        cb.say("报警间隔:"..alarm_interval_2.."秒")
        cb.say("输入\""..get_chat_keyword("disable")[1].."\"禁用警报，输入\""..get_chat_keyword("enable")[1].."\"重新启用警报")
        return true
    end
    if alarming=="red" then
        last_alarm="red"
        logger_f("电量红色警报:"..format_bignum(EU,num_formation).."EU("..string.format("%.2f",EU_usage*100).."%) 剩余"..format_time(-EU_time),"alarm","WARN")
        logger_c("电量红色警报:"..format_bignum(EU,num_formation).."EU("..string.format("%.2f",EU_usage*100).."%) 剩余"..format_time(-EU_time),"alarm","WARN")
        cb.say("§c电量红色警报")
        cb.say("剩余电量:§c"..format_bignum(EU,num_formation).."§7EU  §c"..string.format("%.2f",EU_usage*100).."%")
        cb.say("预计剩余时间:§e"..format_time(-EU_time))
        cb.say("阈值:剩余电量低于§c"..string.format("%.2f",alarm_usage_2*100).."%§7，或可用时间小于§c"..format_time(alarm_time_2))
        cb.say("报警间隔:"..alarm_interval_2.."秒")
        cb.say("输入\""..get_chat_keyword("disable")[1].."\"禁用警报，输入\""..get_chat_keyword("enable")[1].."\"重新启用警报")
        return true
    end
    if alarming=="yellow" then
    	last_alarm="yellow"
        logger_f("电量黄色警报:"..format_bignum(EU,num_formation).."EU("..string.format("%.2f",EU_usage*100).."%) 剩余"..format_time(-EU_time),"alarm","WARN")
        logger_c("电量黄色警报:"..format_bignum(EU,num_formation).."EU("..string.format("%.2f",EU_usage*100).."%) 剩余"..format_time(-EU_time),"alarm","WARN")
        cb.say("§e电量黄色警报")
        cb.say("剩余电量:§e"..format_bignum(EU,num_formation).."§7EU  §e"..string.format("%.2f",EU_usage*100).."%")
        cb.say("预计剩余时间:§e"..format_time(-EU_time))
        cb.say("阈值:剩余电量低于§e"..string.format("%.2f",alarm_usage_1*100).."%§7，或可用时间小于§e"..format_time(alarm_time_1))
        cb.say("报警间隔:"..alarm_interval_1.."秒")
        cb.say("输入\""..get_chat_keyword("disable")[1].."\"禁用警报，输入\""..get_chat_keyword("enable")[1].."\"重新启用警报")
        return true
    end
end

new_timer(1,alarm_check,math.huge)