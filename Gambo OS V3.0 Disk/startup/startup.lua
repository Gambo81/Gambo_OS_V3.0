os.pullEvent = os.pullEventRaw

term.setBackgroundColor(colors.gray)
term.setTextColor(2)

term.clear()
term.setCursorPos(1,1)

--username and password
username = "localadmin"
password = "localadmin"

term.write("Put your usename here: ")
local usernameread=read()
if (usernameread==username) then
    print("Step one complete")
    sleep(1)
else
    print("You are being locked out.")
    sleep(1)
    os.reboot()
end

term.write("Password: ")
local passwordread=read("*")
if (passwordread==password) then
    print("Welcome")
    sleep(1)
    term.clear()
    shell.run("os/loadingscreen")
    return
else
    print("You are being locked out.")
    sleep(1)
    os.reboot()
end