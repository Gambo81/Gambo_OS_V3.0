os.pullEvent = os.pullEventRaw
term.setCursorPos(1,1)
term.clear()
print("Please type the name of your paint file or a new name to make a new paint file.")
term.setCursorPos(1,3)
print(" ")
term.write("name> ")

    local name=read()
        shell.run("cd", "user/paint")
        shell.run("paint",name)
        shell.run("cd","/")
        shell.run("/os/menus/paint")
        return