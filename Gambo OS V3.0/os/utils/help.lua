os.pullEvent = os.pullEventRaw
term.clear()
term.setCursorPos(1, 1)
print("This menu has been made to help you navigate Gambo OS.")
term.setCursorPos(1, 3)
print(" ")
term.setCursorPos(1, 4)
print("When you are in the command line you can use 'ls' so see all of the files and folders. You can use 'cd' and then the name of the folder you want to enter to enter a folder. You can use 'edit' and then the name of the file to edit the file. Rember to be in the right folder to use the edit file.")

os.pullEvent("mouse_click") 
    term.setTextColor(colors.white)
    shell.run("cd","/")
    shell.run("/os/menus/utils")
    return