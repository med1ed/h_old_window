local ini = {};

function ini.load(fileName)
	if type(fileName) ~= "string" then system.log_warning( "Parameter \"fileName\" must be a string."); return; end
	local file = io.open(fileName, "r");
	local data = {};
	local section;
	for line in file:lines() do
		local tempSection = line:match("^%[([^%[%]]+)%]$");
		if(tempSection)then
			section = tonumber(tempSection) and tonumber(tempSection) or tempSection;
			data[section] = data[section] or {};
		end
		local param, value = line:match("^([%w|_]+)%s-=%s-(.+)$");
		if(param and value ~= nil)then
			if(tonumber(value))then
				value = tonumber(value);
			elseif(value == "true")then
				value = true;
			elseif(value == "false")then
				value = false;
			end
			if(tonumber(param))then
				param = tonumber(param);
			end
			data[section][param] = value;
		end
	end
	file:close();
	return data;
end

function ini.save(fileName, data)
	if type(fileName) ~= "string" then system.log_warning("Parameter \"fileName\" must be a string."); return; end
	if type(data) ~= "table" then system.log_warning("Parameter \"data\" must be a table."); return; end
	local file = io.open(fileName, "w+b");
	local contents = "";
	for section, param in pairs(data) do
		contents = contents .. ("[%s]\n"):format(section);
		for key, value in pairs(param) do
			contents = contents .. ("%s=%s\n"):format(key, tostring(value));
		end
		contents = contents;
	end
	file:write(contents);
	file:close();
end

return ini;