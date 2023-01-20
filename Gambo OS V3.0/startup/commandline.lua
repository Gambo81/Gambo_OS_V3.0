os.pullEvent = os.pullEventRaw

image = paintutils.loadImage("os/backgrounds/gos.nfp")
paintutils.drawImage(image, 1, 1)
term.setBackgroundColor(colors.gray)
term.setTextColor(2)

term.clear()
term.setCursorPos(1,1)
io.close()

print("Command line.")
print("Type back to exit to the desktop.")
print("---------------------------------")
term.setCursorPos(1,4)
