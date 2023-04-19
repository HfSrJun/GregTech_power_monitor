Y0=1

function time_cn(c_char)
    local temp=os.date()
    local clock_str=string.sub(temp,-8)
    if c_char then
        local H=string.sub(clock_str,1,2)
        local M=string.sub(clock_str,4,5)
        local S=string.sub(clock_str,7,8)
        return H.."时"..M.."分"..S.."秒"
    else
        return clock_str
    end
end

function date_cn(to_days,c_char)
    if to_days==nil then
        to_days=false
    end
    if c_char==nil then
        c_char=false
    end

    local month_d={31,30,31,30,31,30,31,31,30,31,30,31}
    local days=0
    local temp=os.date()
    local YY=tostring(tonumber(string.sub(temp,7,-10))-70+Y0)
    local MM=string.sub(temp,4,5)
    local DD=string.sub(temp,1,2)    
    if to_days then
        for i=1,tonumber(MM)-1 do
            days=days+month_d[i]
        end
        days=days+tonumber(DD)
    end
    
    if c_char then
        if to_days then
            return(YY.."年第"..days.."日 "..time_cn(true))
        else
            return(YY.."年"..MM.."月"..DD.."日 "..time_cn(true))
        end
    else
        if to_days then
            return(YY.."."..days.." "..time_cn(false))
        else
            return(YY.."."..MM.."."..DD.." "..time_cn(false))
        end
    end
end
function format_time(sec)
    sec=math.floor(sec)
    local hour=sec//3600
    sec=sec%3600
    local min=sec//60
    sec=sec%60
    str=hour.."时"..min.."分"..sec.."秒"
    return str
end
function format_bignum(num,mode)--0:standard 1:kMGTPEZ 2:10pow
    local tail={"k","M","G","T","P","E","Z"}
    if mode==0 then
        return tostring(num)
    end
    if mode==1 then
        local temp=num
        local i=0
        while i<=7 do
            i=i+1
            temp=temp/1000
            if temp<1 then
                break
            end
        end
        i=i-1
        if i==0 then
            return tostring(num)
        else
            local a=math.floor(num/1000^i)
            local b=math.floor((num/(1000^(i-1)))%1000)
            return tostring(a).."."..tostring(b)..tail[i]
        end
    end
    if mode==2 then
        local i=0
        while true do
            if num/10^i<1 then
                break
            end
            i=i+1
        end
        i=i-1
        return string.format("%.3f",num/10^i).."x10^"..i
    end
end