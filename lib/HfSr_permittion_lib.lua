require("./lib/HfSr_file_lib")
local io=require("io")


local user_list={}

function add_permittion_level(level)
    if find_table(user_list,level) then
        return false
    else
        user_list[level]={}
        return true
    end
end

function add_user(name,level)
    add_permittion_level(level)
    if not find_table(user_list[level],nil,name) then
        table.insert(user_list[level],name)
        return true
    else
        return false
    end
end
function remove_user(name,level)
    local i=find_table(user_list[level],nil,name)
    if type(i)=="number" then
        table.remove(user_list[level],i)
        return true
    else
        return false
    end
end
function read_user_list(filename,level)
    add_permittion_level(level)
    local file=io.open(filename,'r')
    local line=file:read()
    while line do
        if not check_permittion(line,level) then
            table.insert(user_list[level],line)
        end
        line=file:read()
    end
end
function write_user_list(filename,level)
    local file=io.open(filename,'w')
    for _,n in pairs(user_list[level]) do
        file:write(n.."\n")
    end
    file:close()
end

function get_permittion_level(name)
    local levels={}
    for l,t in pairs(user_list) do
        if find_table(t,nil,name) then
            table.insert(levels,l)
        end
    end
    return levels
end

function check_permittion(name,level)
	if not find_table(user_list,level) then
        return false
    end
    if find_table(user_list[level],nil,name) then
        return true
    else
        return false
    end
end

function get_user_list(level)
    return user_list[level]
end