require("./lib/HfSr_formation_lib")
require("./lib/HfSr_file_lib")
local io=require("io")
local colors=require("colors")

log_filename="log.log"
log_filepath="./"

function logger_c(text,from,level,col)
    if from==nil then
        from="LOG"
    end
    if level==nil then
        level="INFO"
    end
    if col==nil then
        col=colors.white
    end
    print("["..date_cn(true,false).."] ["..from.."/"..level.."] "..text)
end

function logger_f(text,from,level,filename)
    if not path_exist(log_filepath) then
        new_path(log_filepath)
    end
	local log_file=io.open(log_filepath..log_filename,'a')
	if type(filename)=="string" then
		log_file:close()
    	log_file=io.open(log_filepath..filename,'a')
    end
    if from==nil then
        from="LOG"
    end
    if level==nil then
        level="INFO"
    end
    log_file:write("["..date_cn(true,false).."] ["..from.."/"..level.."] "..text.."\n")
    log_file:close()
end
function auto_clean_log(filename,max_size)
	if not path_exist(log_filepath) then
        new_path(log_filepath)
    end
    return auto_clean_file(log_filepath..filename,max_size,false)
end