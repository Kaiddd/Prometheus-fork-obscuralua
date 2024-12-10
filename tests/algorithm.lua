-- Bubble Sort Algorithm in Lua

local function bubbleSort(arr)
    local n = #arr
    local swapped
    repeat
        swapped = false
        for i = 1, n-1 do
            if arr[i] > arr[i+1] then
                arr[i], arr[i+1] = arr[i+1], arr[i]
                swapped = true
            end
        end
        n = n - 1
    until not swapped
    return arr
end

-- Test the function
local arr = {64, 34, 25, 12, 22, 11, 90}
print(table.concat(bubbleSort(arr), ", "))

-- Expected Output: 11, 12, 22, 25, 34, 64, 90