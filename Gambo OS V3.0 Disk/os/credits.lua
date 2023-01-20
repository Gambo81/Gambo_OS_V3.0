os.pullEvent = os.pullEventRaw
term.setCursorPos(1,1)
term.clear()
print("MCJack123: Battleship.")
print("Open AI: Calculator.")
print("HPWebcamAble: File explorer.")
print("Commandcracker: youcube.")

os.pullEvent("mouse_click") 
    term.setTextColor(colors.white)
    shell.execute("os/menus/desktop")
    return