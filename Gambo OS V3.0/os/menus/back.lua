os.pullEvent = os.pullEventRaw
shell.run("cd", "/")
image = paintutils.loadImage("/os/backgrounds/background.nfp")
image = paintutils.loadImage("/os/backgrounds/gos.nfp")
paintutils.drawImage(image, 1, 1)
term.setBackgroundColor(colors.gray)
shell.run("os/menus/utils")
return