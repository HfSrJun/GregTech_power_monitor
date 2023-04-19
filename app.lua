--copyright 2023 HfSr
print("开始启动程序")
require("./lib/HfSr_formation_lib")
require("./lib/HfSr_logger_lib")
require("./lib/HfSr_event_lib")
require("./lib/HfSr_permittion_lib")
require("./lib/HfSr_chatbox_lib")
require("data_update")
require("alarm")
local component=require("component")
local os=require("os")
local event=require("event")

mach=component.proxy(component.get("7d24e85b-ad82-4423-acc7-d288f6482fe1"))
cb=component.proxy(component.get("98d6333f-8e41-463b-88c9-19fdd0385162"))

local cb_name="§e电§a容§c库§7§o"
local exit_key=8
local num_formation=1 --0:standard 1:kMGTPEZ 2:10pow
local log_interval=60
local EU_logfile="EU.log"
local max_log_size=500000

Y0=1
log_filepath="./log/"
log_filename="program.log"

local function handle_message(index,name,text)
    if not check_permittion(name,"admin") then
        logger_f(name.."访问被拒绝")
        logger_c(name.."访问被拒绝")
        cb.say("没有权限")
        return
    end
    if index=="add" then
print("add user")
        logger_f(name.."添加用户"..string.sub(text,13),"settings","WARN")
        logger_c(name.."添加用户"..string.sub(text,13),"settings","WARN")
        local done=add_user(string.sub(text,13),"admin")
        if done then
            cb.say("用户"..string.sub(text,13).."已添加")
            logger_f("用户"..string.sub(text,13).."已添加","user","WARN")
            logger_c("用户"..string.sub(text,13).."已添加","user","WARN")
        else
            cb.say("用户"..string.sub(text,13).."已存在")
            logger_f("用户"..string.sub(text,13).."已存在","user","ERR")
            logger_c("用户"..string.sub(text,13).."已存在","user","ERR")
        end
        return
    end
    if index=="remove" then
        logger_f(name.."删除用户"..string.sub(text,13),"settings","WARN")
        logger_c(name.."删除用户"..string.sub(text,13),"settings","WARN")
        local done=remove_user(string.sub(text,13),"admin")
        if done then
            cb.say("用户"..string.sub(text,13).."已删除")
            logger_f("用户"..string.sub(text,13).."已删除","user","WARN")
            logger_c("用户"..string.sub(text,13).."已删除","user","WARN")
        else
            cb.say("用户"..string.sub(text,13).."不存在")
            logger_f("用户"..string.sub(text,13).."不存在","user","ERR")
            logger_c("用户"..string.sub(text,13).."不存在","user","ERR")
        end
        return
    end
    if index=="user" then
        logger_f(name.."查询用户列表","user","INFO")
        logger_c(name.."查询用户列表","user","INFO")
        cb.say("用户列表为:")
        local sum=0
        for _,n in pairs(get_user_list("admin")) do
            cb.say(n)
            sum=sum+1
        end
        cb.say("总计"..sum.."人")
        return
    end
    if index=="disable" then
        logger_f(name.."禁用警报","settings","WARN")
        logger_c(name.."禁用警报","settings","WARN")
        cb.say("警报禁用")
        alarm_disabled=true
        return
    end
    if index=="enable" then
        logger_f(name.."启用警报","settings","WARN")
        logger_c(name.."启用警报","settings","WARN")
        cb.say("警报启用")
        alarm_disabled=false
        return
    end
    logger_f(name.."查询信息")
    logger_c(name.."查询信息")
    if alarming=="normal" then
        cb.say("§a电容库正常运行")
        cb.say("总容量:"..format_bignum(EU_capacity,num_formation).."EU")
        cb.say("当前电量:§a"..format_bignum(EU,num_formation).."§7EU  电量百分比:§a"..string.format("%.2f",EU_usage*100).."%")
    else
        if alarming=="yellow" then
            cb.say("§e电容库电量不足  黄色警报")
            cb.say("总容量:"..format_bignum(EU_capacity,num_formation).."EU")
            cb.say("当前电量:§e"..format_bignum(EU,num_formation).."§7EU  电量百分比:§e"..string.format("%.2f",EU_usage*100).."%")
        end
        if alarming=="red" then
            cb.say("§c电容库电量不足  红色警报")
            cb.say("总容量:"..format_bignum(EU_capacity,num_formation).."EU")
            cb.say("当前电量:§c"..format_bignum(EU,num_formation).."§7EU  电量百分比:§c"..string.format("%.2f",EU_usage*100).."%")
        end
        if alarming=="maintain" then  
            local x,y,z=mach.getCoordinates()
            cb.say("§c电容库需要维护  §7坐标位于X:"..x.." Y:"..y.." Z:"..z)
            cb.say("总容量:"..format_bignum(EU_capacity,num_formation).."EU")
            cb.say("当前电量:§c"..format_bignum(EU,num_formation).."§7EU  电量百分比:§c"..string.format("%.2f",EU_usage*100).."%")
        end
    end
    cb.say("被动损耗速率:"..format_bignum(EU_leak,num_formation).."EU/tick")
    cb.say("输入速率:"..format_bignum(EU_input,num_formation).."EU/tick  输出速率:"..format_bignum(EU_output,num_formation).."EU/tick")
    if EU_time==0 then
        cb.say("充放电平衡")
    else 
        if EU_time>0 then
            cb.say("正在充电，约"..format_time(EU_time).."后充满")
        else
            cb.say("正在放电，约"..format_time(-EU_time).."后耗尽")
        end
    end
    if alarm_disabled then
        cb.say("故障与电量警报禁用")
    else
        cb.say("故障与电量警报启用")
    end
end

local function clean_log()
    if auto_clean_file(log_filepath..EU_logfile,max_log_size) then
        logger_f("EU日志清空","logger","LOG")
        logger_c("EU日志清空","logger","LOG")
    end
    if auto_clean_file(log_filepath..log_filename,max_log_size) then
        logger_f("程序日志清空","logger","LOG")
        logger_c("程序日志清空","logger","LOG")
    end
end
local function exit()
	write_user_list("admin.txt","admin")
    event_clean()
    os.exit()
end
local function EU_logger()
    logger_f("EU_capacity:"..EU_capacity.."EU","EU LOG","LOG",EU_logfile)
    logger_f("EU:"..EU.."EU("..string.format("%.2f",EU_usage*100).."%)","EU LOG","LOG",EU_logfile)
    logger_f("EU_input:"..EU_input.."EU  EU_output:"..EU_output.."EU","EU LOG","LOG",EU_logfile)
    logger_f("EU_time:"..EU_time.."("..format_time(EU_time)..")","EU LOG","LOG",EU_logfile)
    logger_f("EU_log:"..date_cn(true,false).." log_interval:"..log_interval.."s\n","EU LOG","LOG",EU_logfile)
end

cb.setName(cb_name)
read_user_list("admin.txt","admin")
new_timer(0.5,update_data,math.huge)
new_timer(log_interval,EU_logger,math.huge)
new_timer(1,clean_log,math.huge)
chat_handler=handle_message


--io.read()
--exit()

logger_f("程序启动")
print("程序启动完成 按退格键关闭\n")
print("指令列表")
print("\"partly:\"代表支持部分匹配")
print()
print("#查询:")
for _,v in ipairs(get_chat_keyword("ask")) do
    print(v)
end
print()
print("#禁用警报:")
for _,v in ipairs(get_chat_keyword("disable")) do
    print(v)
end
print()
print("#启用警报:")
for _,v in ipairs(get_chat_keyword("enable")) do
    print(v)
end
print()
print("#查询用户列表:")
for _,v in ipairs(get_chat_keyword("user")) do
    print(v)
end
print()
print("#添加用户(后接用户名):")
for _,v in ipairs(get_chat_keyword("add")) do
	local t=string.gsub(v,"partly:","")
    print(t)
end
print()
print("#删除用户(后接用户名):")
for _,v in ipairs(get_chat_keyword("remove")) do
    local t=string.gsub(v,"partly:","")
    print(t)
end
print()

while true do
    _,_,key=event_pull("key_up")
    if key==exit_key then
        logger_f("程序结束")
        exit()
    end
end