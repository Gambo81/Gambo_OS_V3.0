os.pullEvent = os.pullEventRaw
term.setCursorPos(1,1)
term.clear()
print("Please type the name of the paint file that you want to be deleted. REMEMBER TO ADD .nfp.")
term.setCursorPos(1,3)
print(" ")
term.write("name> ")

    local name=read()
        shell.run("cd", "/user/paint")
        shell.run("delete",name)
        shell.run("cd","/")
        shell.run("/os/menus/paint")
        return