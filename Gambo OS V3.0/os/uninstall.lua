os.pullEvent = os.pullEventRaw
term.clear()
term.setCursorPos(1,1)
term.write("Are you sure?")

local x, y = 2,4
local x2, y2 = 2,6
local choice1 = " Yes "
local choice2 = " No "

image = paintutils.loadImage("/os/backgrounds/gos.nfp")
paintutils.drawImage(image, 1, 1)
term.setBackgroundColor(colors.gray)
term.setTextColor(2)
term.setCursorPos(x,y)
write(choice1)
term.setCursorPos(x2,y2)
write(choice2)
term.setCursorPos(1,1)
term.write("Gambo OS:")
term.setCursorPos(1,2)
shell.run("id")
shell.run("cd", "/")

while true do
    local event, button, cx, cy = os.pullEvent()
        if event == "mouse_click" then
            if cx >= x and cx < choice1:len() and cy == y and button == 1 then
                term.setCursorPos(28,6)
                shell.run("delete","os")
                shell.run("delete","startup")
                shell.run("delete","lib")
                shell.run("delete","back.lua")
                shell.run("delete",".settings")
                os.reboot()
            elseif cx >= x2 and cx < choice2:len() and cy == y2 and button == 1 then
                shell.run("os/menus/desktop")
                return
            end
        end
end
