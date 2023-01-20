os.pullEvent = os.pullEventRaw

term.setBackgroundColor(colors.gray)
term.setTextColor(2)

term.clear()
term.setCursorPos(1,1)

--password
password = "localadmin"

term.write("Password: ")
local passwordread=read("*")
if (passwordread==password) then
    term.clear()
    shell.run("os/menus/utils2")
    return
else
    print("Retry.")
    sleep(1)
    shell.run("os/utils/lockscreen")
end