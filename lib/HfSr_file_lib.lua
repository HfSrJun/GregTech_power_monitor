local os=require("os")

function find_table(tab,key,val)
    for i,v in pairs(tab) do
        if i==key and val==nil then
            return tab[i]
        end
        if key==nil and v==val then
            return i
        end
        if i==key and v==val then
            return true
        end
    end
    return false
end

function file_exist(path)
    local file = io.open(path, "rb")
    if file then file:close() end
    return file ~= nil
end
function path_exist(path)
    return os.execute("cd ".."\""..path.."\" 1>/dev/null 2>/dev/null")
end
function new_path(path)
    os.execute("mkdir "..path)
end
function auto_clean_file(file,max_size,del)
    if del==nil then
        del=false
    end
	local del_f=io.open(file,'r')
	if del_f:seek("end")>max_size then
        if del then
            os.execute("rm".."\""..file.."\" 1>/dev/null 2>/dev/null")
        else
		    del_f=io.open(file,'w')
		end
		del_f:close()		
		return true
	else
		del_f:close()
		return false
	end
end