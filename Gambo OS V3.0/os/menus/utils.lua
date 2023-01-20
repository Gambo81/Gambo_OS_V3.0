os.pullEvent = os.pullEventRaw
term.clear()
term.setCursorPos(1,1)

local x, y = 2,4
local x2, y2 = 2,6
local x3, y3 = 2,8
local x4, y4 = 2,10
local x5, y5 = 2,12
local x6, y6 = 2,16
local x7, y7 = 2,18
local choice1 = " Command Line "
local choice2 = " File Explorer "
local choice3 = " Lock screen "
local choice4 = " Calculator "
local choice5 = " Help "
local choice6 = " Page 2 "
local choice7 = " Back "

image = paintutils.loadImage("/os/backgrounds/gos.nfp")
paintutils.drawImage(image, 1, 1)
term.setBackgroundColor(colors.gray)
term.setTextColor(2)
term.setCursorPos(x,y)
write(choice1)
term.setCursorPos(x2,y2)
write(choice2)
term.setCursorPos(x3,y3)
write(choice3)
term.setCursorPos(x4,y4)
write(choice4)
term.setCursorPos(x5,y5)
write(choice5)
term.setCursorPos(x6,y6)
write(choice6)
term.setCursorPos(x7,y7)
write(choice7)
term.setCursorPos(1,1)
term.write("Gambo OS V3.0:")
term.setCursorPos(33,1)
shell.run("id")

while true do
    local event, button, cx, cy = os.pullEvent()
        if event == "mouse_click" then
            if cx >= x and cx < choice1:len() and cy == y and button == 1 then
                term.setCursorPos(28,6)
                shell.run("os/utils/commandlinepassword")
                return
            elseif cx >= x2 and cx < choice2:len() and cy == y2 and button == 1 then
                shell.run("os/utils/fileexplorerpassword")
                return
            elseif cx >= x3 and cx < choice3:len() and cy == y3 and button == 1 then
                shell.run("/os/utils/lockscreen")
                return
            elseif cx >= x4 and cx < choice4:len() and cy == y4 and button == 1 then
                term.setCursorPos(28,6)
                shell.run("background", "os/utils/calculator")
                shell.run("/os/menus/utils")
                return
            elseif cx >= x5 and cx < choice5:len() and cy == y5 and button == 1 then
                term.setCursorPos(28,6)
                shell.run("os/utils/help")
                return
            elseif cx >= x6 and cx < choice6:len() and cy == y6 and button == 1 then
                term.setCursorPos(28,6)
                shell.run("os/menus/utils2")
                return
            elseif cx >= x7 and cx < choice7:len() and cy == y7 and button == 1 then
                term.setCursorPos(28,6)
                shell.run("os/menus/desktop")
                return
            end
        end
end
