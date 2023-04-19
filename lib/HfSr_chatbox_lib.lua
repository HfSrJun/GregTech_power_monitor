local io=require("io")
require("./lib/HfSr_event_lib")
require("./lib/HfSr_file_lib")

local chat_keyword={}
chat_handler=""
keyword_file="keyword.txt"
keyword_file_index_sign="index:"
keyword_file_partly_sign="partly:"
keyword_file_ignore_sign="//"

function recv_message(_,_,name,text)
    for i,t in pairs(chat_keyword) do
        for _,word in pairs(t) do
            if string.find(word,keyword_file_partly_sign)==1 then
                if string.find(text,string.gsub(word,keyword_file_partly_sign,"",1)) then
                    chat_handler(i,name,text)
                    break
                end
            else
            	if word==text then
                    chat_handler(i,name,text)
                    break
                end
            end
        end
    end
    new_listener("chat_message",recv_message)
end
local function read_keyword()
	if not file_exist(keyword_file) then
	    return false
	end
    local file=io.open(keyword_file,'r')
    local line=file:read()
    local index
    while line do
        if string.find(line,keyword_file_ignore_sign)==1 then
            goto continue
        end
    	if string.find(line,keyword_file_index_sign)==1 then
            index=string.gsub(line,keyword_file_index_sign,"",1)        
            if not find_table(chat_keyword,index) then
                chat_keyword[index]={}
            end
            goto continue
        end
        table.insert(chat_keyword[index],line)
        ::continue::
        line=file:read()
    end
    return true
end

function get_chat_keyword(index)
    if find_table(chat_keyword,index) then
        return chat_keyword[index]
    else
    	return false
    end
end
function add_chat_keyword(index,word)
    if not find_table(chat_keyword,index) then
        chat_keyword[index]={}
    end
    if find_table(chat_keyword[index],nil,word) then
        return false
    else
        table.insert(chat_keyword[index],word)
        return true
    end
end

read_keyword()
new_listener("chat_message",recv_message)
--[[
index_sign标记index，其下为它的keyword
partly_sign标记这个keyword进行部分匹配
ignore_sign标记注释
--]]