local correctString = "potatobraingames"
local correctNumber = "4194303"

local function startGame()
    print("Welcome to the guessing game!")

    print("Please guess the string:")
    local guessString = io.read()
    if guessString ~= correctString then
        print("Wrong guess! Try again.")
        return startGame()
    end

    print("Please guess the number:")
    local guessNumber = io.read()
    if guessNumber ~= correctNumber then
        print("Wrong guess! Try again.")
    else
        print("Congratulations! You guessed correctly.")
    end
end

startGame()