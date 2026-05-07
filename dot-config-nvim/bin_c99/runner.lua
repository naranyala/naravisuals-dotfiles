
local command = "./dirscan /home/naranyala/.local/share/nvim/lazy/"
-- local result = os.execute(command)
--
--
-- local command = "echo Hello from the CLI"
local file_handle = io.popen(command, "r")

if file_handle then
    -- Read the entire output into a string
    local output = file_handle:read("*a")
    
    -- Close the file handle
    file_handle:close()

    print("CLI Output:")
    print("--------------------")
    print(output)
else
    print("❌ Failed to run the command or create the pipe.")
end
