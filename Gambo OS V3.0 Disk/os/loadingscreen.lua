os.pullEvent = os.pullEventRaw
term.clear()
term.setCursorPos(1,1)
function printCentered( y, s, c)
    local w,h = term.getSize()
    local x = math.floor((w - string.len(s)) / 2)
    term.setCursorPos(x,y)
    term.clearLine()
    term.write( s )
end

term.setBackgroundColor(colors.gray)
term.setTextColor(2)
printCentered( 4,"     _____                  _              ____   _____ ")
sleep(0.3)
printCentered( 5,"    / ____|                | |            / __ \\ / ____|")
sleep(0.3)
printCentered( 6,"    | |  __  __ _ _ __ ___ | |__   ___   | |  | | (___  ")
sleep(0.3)
printCentered( 7,"    | | |_ |/ _` | '_ ` _ \\| '_ \\ / _ \\  | |  | |\\___ \\ ")
sleep(0.3)
printCentered( 8,"    | |__| | (_| | | | | | | |_) | (_) | | |__| |____) |")
sleep(0.3)
printCentered( 9,"    \\______|\\__,_|_| |_| |_|_.__/ \\___/   \\____/|_____/ ")
sleep(0.3)
load = "##############################################"
for i = 1, #load,2 do
    printCentered( 15, load:sub(1, i))
    printCentered( 16, math.floor(((i+1)/#load)*100).."%")
    sleep(0.1)
end
sleep(1)
shell.run("os/menus/desktop")
return