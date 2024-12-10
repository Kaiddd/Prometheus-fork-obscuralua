local antiTamperBegun = false
local antiTamperPcall, antiTamperPcallRet = true, nil
local fakeAntiTamperRandomRet = 3
local randomLineNumberGenerations, randomLineNumberGeneration = 0, nil
local isAntiTamperPcall, antiTamperPcalls = false, 0
local isAntiTamperSubPcall = false

local oldPcall = pcall
local fakePcall; fakePcall = function(f, ...)
    local ret

    if (isAntiTamperSubPcall) then
        return unpack(antiTamperPcallRet)
    end

    if (antiTamperBegun) then
        if (antiTamperPcall) then
            ret = {oldPcall(f, ...)}

            antiTamperPcall = false
            antiTamperPcallRet = ret
        elseif (isAntiTamperPcall) then
            antiTamperPcalls = antiTamperPcalls + 1
            if (antiTamperPcalls <= fakeAntiTamperRandomRet) then
                isAntiTamperPcall = false

                isAntiTamperSubPcall = true
                ret = {oldPcall(f, ...)}
                isAntiTamperSubPcall = false
            end
        end
    end

    if (ret == nil) then
        ret = {oldPcall(f, ...)}
    end

    return unpack(ret)
end

local oldMath = math
local fakeMath; fakeMath = setmetatable({}, {
	__index = function(self, idx)
		--print("math", idx)

		local ret = oldMath[idx]

		if (idx == "random") then
			return function(min, max)
                --print("random", min, max)

                local res = ret(min, max)

				if (min == 3) and (max == 65) and (not antiTamperBegun) then
					antiTamperBegun = true

                    return fakeAntiTamperRandomRet
				end

                if (min == 0) and (max == 10000) and (antiTamperBegun) then
                    --print("HERE")
                    randomLineNumberGenerations = randomLineNumberGenerations + 1
                    if (randomLineNumberGenerations <= fakeAntiTamperRandomRet) then
                        --print(res)
                        isAntiTamperPcall = true
                        randomLineNumberGeneration = res
                    end
                end

				return res
			end
		end

		return ret
	end
})

local oldDebug = debug
local fakeDebug; fakeDebug = setmetatable({}, {
	__index = function(self, idx)
		--print("debug", idx)

		local ret = oldDebug[idx]

		if (idx == "sethook") then
			return function(...) end -- fuck your hook
		end

		return ret
	end
})

local oldEnv = getfenv()
local fakeEnv; fakeEnv = setmetatable({}, {
	__index = function(self, idx)
		--print(idx)

		local ret = oldEnv[idx]

		if (idx == "getfenv") then -- bro really tried to escape 😭
			return function(lvl)
				if (lvl == nil) or (type(lvl) == "number" and lvl <= 1) then
					return fakeEnv
				end

				return ret(lvl)
			end
		end

		if (idx == "debug") then
			return fakeDebug
		end

        if (idx == "pcall") then
            return fakePcall
        end

		if (idx == "math") then
			return fakeMath
		end

		if (idx == "io") then
			return {
				read = {
					error("stop")
				}
			}
		end

		return ret
	end
})