shell.run("copy","disk/os","os")
shell.run("copy","disk/startup","startup")
shell.run("copy","disk/user","user")
shell.run("copy","disk/lib","lib")
shell.run("copy","disk/back.lua","back.lua")
shell.run("set shell.allow_disk_startup","false")
peripheral.find("drive")
os.pullEvent("disk_eject")
os.reboot()