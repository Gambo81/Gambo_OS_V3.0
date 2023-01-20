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
    shell.run("cd", "/os")
    shell.run("uninstall")
    return
else
    print("You are being locked out.")
    sleep(1)
    shell.run("os/menus/desktop")
    return
end