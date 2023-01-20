os.pullEvent = os.pullEventRaw
term.setCursorPos(1,1)
term.clear()
print("Please type the name of the Notepad file that you want to be deleted. REMEMBER TO ADD .lua.")
term.setCursorPos(1,3)
print(" ")
term.write("name> ")

    local name=read()
        shell.run("cd", "/User/notepad")
        shell.run("delete",name)
        shell.run("cd","/")
        shell.run("/os/menus/notepad")
        return