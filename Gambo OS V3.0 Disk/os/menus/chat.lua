os.pullEvent = os.pullEventRaw

image = paintutils.loadImage("/os/backgrounds/gos.nfp")
paintutils.drawImage(image, 1, 1)
term.setBackgroundColor(colors.gray)
term.setTextColor(2)

term.setCursorPos(1,1)
term.clear()

print("Please type the name of the chat you would like to join. Gambo OS has its own chat. To use it just")
term.setCursorPos(1,3)
print("type 'Gambo_OS_Chat'.")
term.setCursorPos(1,4)
print(" ")
term.write("chat> ")

chat = read()

term.clear()
term.setCursorPos(1,1)

print("Please type what you want your username to be.")
term.setCursorPos(1,3)
print(" ")
term.write("username> ")

username = read()

term.clear()
term.setCursorPos(1,1)
shell.run("background","chat","join",chat,username)
shell.run("os/menus/desktop")
return