if not tbsrequire then
    local cache_lib = {}

    rawset(_G, "tbsrequire", function(path)
        local path = path .. ".lua"
		print("Attempting to load: " .. path) -- Debug statement
        if cache_lib[path] then
            return cache_lib[path]
        else
            local func, err = loadfile(path)
            if not func then
                error("error loading module '"..path.."': "..err)
            else
                cache_lib[path] = func()
                return cache_lib[path] 
            end
        end
    end)
end

--Thank you Skydusk