local component=require("component")

EU_capacity=0
EU=0
EU_leak=0
EU_input=0
EU_output=0
EU_usage=0
EU_time=0
maintain=false

function update_data()
    local temp_table=mach.getSensorInformation()
    EU_capacity=mach.getEUMaxStored()
    EU_leak=string.gsub(string.sub(temp_table[4],15,-5),",","")
    EU_leak=tonumber(EU_leak)
    
    EU=mach.getEUStored()
    if EU>0 then
        EU=EU+EU_leak
    end
    EU_input=string.gsub(string.sub(temp_table[7],12,-18),",","")
    EU_input=tonumber(EU_input)
    EU_output=string.gsub(string.sub(temp_table[8],13,-18),",","")
    EU_output=tonumber(EU_output)
    if EU_output==0 and EU_input<EU_leak then
        EU_output=EU_input
    else
        EU_output=EU_output+EU_leak        
    end
    EU_usage=EU/EU_capacity
    if EU_input>EU_output then
        EU_time=(EU_capacity-EU)/(EU_input-EU_output)/20
    else 
        if EU_input<EU_output then
            EU_time=-EU/(EU_output-EU_input)/20
        else
            EU_time=0
        end
    end
    if string.find(temp_table[9],"perfect")==nil then
        maintain=true
    else
        maintain=false
    end
end