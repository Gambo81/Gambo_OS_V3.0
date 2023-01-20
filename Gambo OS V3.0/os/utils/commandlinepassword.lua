os.pullEvent = os.pullEventRaw

term.setBackgroundColor(colors.gray)
term.setTextColor(2)

--password
password = "localadmin"

term.clear()
term.setCursorPos(1,1)

term.write("Password: ")
local passwordread=read("*")
if (passwordread==password) then
    term.clear()
    shell.run("startup/commandline")
    shell.run("cd", "/user")
    return
else
    print("You are being locked out.")
    sleep(1)
    shell.run("os/menus/utils")
    return
end
