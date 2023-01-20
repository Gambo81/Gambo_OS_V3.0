os.pullEvent = os.pullEventRaw
term.setCursorPos(1,1)
term.clear()
print("Please type the name of your Notepad file or a new name to make a new Notepad file.")
term.setCursorPos(1,3)
print(" ")
term.write("name> ")

    local name=read()
        shell.run("cd", "User/Notepad")
        shell.run("edit",name)
        shell.run("cd","/")
        shell.run("/os/menus/notepad")
        return