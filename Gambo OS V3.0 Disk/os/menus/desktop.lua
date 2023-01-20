os.pullEvent = os.pullEventRaw
term.clear()
term.setCursorPos(1,1)

local x, y = 2,4
local x2, y2 = 2,6
local x3, y3 = 2,8
local x4, y4 = 2,12
local x5, y5 = 2,14
local x6, y6 = 2,18
local choice1 = " Utils "
local choice2 = " Fun "
local choice3 = " chat "
local choice4 = " Shutdown "
local choice5 = " Uninstall "
local choice6 = " Credits "

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
term.setCursorPos(1,1)
term.write("Gambo OS V3.0:")
term.setCursorPos(33,1)
shell.run("id")

while true do
    local event, button, cx, cy = os.pullEvent()
        if event == "mouse_click" then
            if cx >= x and cx < choice1:len() and cy == y and button == 1 then
                term.setCursorPos(28,6)
                shell.run("os/menus/utils")
                return
            elseif cx >= x2 and cx < choice2:len() and cy == y2 and button == 1 then
                shell.run("os/menus/fun")
                return
            elseif cx >= x3 and cx < choice3:len() and cy == y3 and button == 1 then
                shell.run("os/menus/chat")
                return
            elseif cx >= x4 and cx < choice4:len() and cy == y4 and button == 1 then
                term.setCursorPos(28,6)
                os.shutdown()
                return
            elseif cx >= x5 and cx < choice5:len() and cy == y5 and button == 1 then
                term.setCursorPos(28,6)
                shell.run("os/uninstallpassword")
            elseif cx >= x6 and cx < choice6:len() and cy == y6 and button == 1 then
                term.setCursorPos(28,6)
                shell.run("os/credits")
                return
            end
        end
end