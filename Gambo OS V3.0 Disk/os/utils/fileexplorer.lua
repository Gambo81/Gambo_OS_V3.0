os.pullEvent = os.pullEventRaw

--[[
HPWebcamAble Presents...
File Manager

=== Description ====
This program adds a user interface for file browsing


==== Documentation ====
ComputerCraft Forum:
http://www.computercraft.info/forums2/index.php?/topic/24579-file-manager-20-history-run-w-args-grayscale-support/

Youtube Video:
NOTE: This video is for Version 1.0, and is a little outdated now
https://www.youtube.com/watch?v=pdaWStx-rwA


==== Installation and Use ====
Pastebin Code: jKZBPFTs

pastebin get <code> fm

Then run 'fm' (Or what you called it)


==== Update History ====
Pastebin will always have the most recent version

|2.0.1| <- This program
  -Fixed detection of grayscale computers in CC 1.76

|2.0|
  -Rewrite of almost entire program!
  -Auto adjusts to display on almost any screen size
  -Dipslay items as a list, or tiles
  -Right click menu
  -Click a selected item to open it
  -Assign programs that should be used to run file endings
    *For example: Use 'edit' to open .txt files
  -Run programs with arguments (finally...)

|Before 2.0|
  -Old, but still on PB:
  http://pastebin.com/uz2f7Xbe
]]

--=== Variables ===--
local version = "2.0.1"
local w,h = term.getSize()
local settings = {
  colors = {
    ["Full Color"] = {
      headingText = colors.white,
      headingBack = colors.blue,
      back = colors.white,
      text = colors.black,
      selected = colors.lightBlue,
      selectedText = colors.white,
      folder = colors.yellow,
      folderText = colors.white,
      file = colors.lightGray,
      fileText = colors.white,
      inputBack = colors.black,
      inputText = colors.white,
      menuBack = colors.gray,
      menuButtons = { text = colors.black, textSelected = colors.white, default = colors.lime, cancel = colors.red, disabled = colors.lightGray},
    },
    ["Gray Scale"] = {
      headingText = colors.white,
      headingBack = colors.black,
      back = colors.white,
      text = colors.black,
      selected = colors.lightGray,
      selectedText = colors.white,
      folder = colors.gray,
      folderText = colors.white,
      file = colors.lightGray,
      fileText = colors.white,
      inputBack = colors.black,
      inputText = colors.white,
      menuBack = colors.gray,
      menuButtons = { text = colors.white, textSelected = colors.white, default = colors.black, cancel = colors.black, disabled = colors.black},
    },
    ["Black and White"] = {
      -- WIP
    }
  }
}
local colorType

local displayViews = { "List" , "Tiles" }
local curView = displayViews[1]

local showText

--Directory stuff
local curPath = {}
local dir
local pathFolders
local pathFiles
local selected
local numSelect = 0
local pathHistory = {{""}}
local historyPos = 1

--Page stuff
local perPage = 0
local pages = 0
local page = 0

--Screen constraints
local minY = 3
local maxY = h-1
local minX = 1
local maxX = w-1

--Types of items (File Endings)
local items = {
  {
    name = "File",
    create = function(path)
      local f = fs.open(path,"w")
      if not f then return false end
      f.close()
      return true
    end,
    equals = function(name)
      local temp = split(name,".")
      return #temp < 2
    end,
    open = function(path)
      runProgram(path)
    end
  },
  {
    name = "Folder",
    create = function(path)
      fs.makeDir(path)
      return fs.exists(path) and fs.isDir(path)
    end,
    equals = function(path)
      return fs.isDir(path)
    end
  }
}
local itemsByName = {}
for i = 1, #items do
  itemsByName[items[i].name] = i
end

--Key states
local shiftHeld = false
local ctrlHeld = false

--List view variables
local midPage

--Screen API Vars
local screens = {}
local curScreen
local default = {
  object = {
    test = "default",
    name = "default",
    minX = 1,
    maxX = 7,
    minY = 1,
    maxY = 3,
    colors = {
      text = {
        on = colors.white,
        off = colors.white
      },
      back = {
        on = colors.lime,
        off = colors.red
      }
    },
    hasClickArea = true,
    state = true
    --action isn't here, it isn't necesarry for the program to work
  },
  clickArea = {
    name = "default",
    minX = 1,
    maxX = 5,
    minY = 1,
    maxY = 3,
    state = true
    --Again, action is left out
  }
}


--=== Functions ===-- 
local function printC(text,y,onlyCalc)--Prints text centered at y
  y = tonumber(y)
  if not y or not text then error("expected string,number got "..type(text)..","..type(y),2) end
  local tLenght = #tostring(text)
  local sStart = math.ceil(w/2-tLenght/2)
  local sEnd = sStart + tLenght
  term.setCursorPos(sStart,y)
  term.write(text)
  return sStart,sEnd
end

local function split(sString,sep)
  if sep == nil then sep = "%s" end
  local t={}
  for str in string.gmatch(sString, "([^"..sep.."]+)") do
    table.insert(t,str)
  end
  return t
end

local function scrollRead(x,y,nLength,insertText) --This is a simple scrolling-read function I made
  if insertText then
    insertText = tostring(insertText)
    cPos = #insertText+1
    cInput = insertText
  else
    cPos = 1
    cInput = ""
  end
  term.setCursorBlink(true)
  while true do
    term.setCursorPos(x,y)
    term.write(string.rep(" ",nLength))
    term.setCursorPos(x,y)
    if string.len(cInput) > nLength-1 then
      term.write(string.sub(cInput,(nLength-1)*-1))
    else
      term.write(cInput)
    end
    if cPos > nLength-1 then
      term.setCursorPos(x+nLength-1,y)
    else  
     term.setCursorPos(x+cPos-1,y)
    end
    local event,p1 = os.pullEvent()
    if event == "char" then
      cInput = string.sub(cInput,1,cPos)..p1..string.sub(cInput,cPos+1)
      cPos = cPos + 1                  
    elseif event == "key" then
      if p1 == keys.enter then
        break
      elseif p1 == keys.backspace then
        if cPos > 1 then
          cInput = string.sub(cInput,1,cPos-2)..string.sub(cInput,cPos)
          cPos = cPos - 1
        end
      elseif p1 == keys["end"] then
        cPos = string.len(cInput)+1
      end    
    end
  end
  term.setCursorBlink(false)
  return cInput
end

local bytesInKiloByte = 1024
local function toKiloBytes(nBytes)
  return math.ceil(nBytes / bytesInKiloByte)
end

local function getSize(path,shrink)
  if not fs.exists(path) then return 0 end
  if fs.isDir(path) then return 0 end
  local size = fs.getSize(path)
  if size == 0 then return "1 Byte" end
  if size < bytesInKiloByte then return size.." Byte"..(size > 0 and "s" or "") end
  return toKiloBytes(size)..(shrink and " KB" or " KiloBytes")
end

--Functions from my Screen API
local function assert(statement,errorText,errorLevel)
  if not statement then
    error(errorText,errorLevel+1)
  end
end

local function fillTable(toFill,fillWith) --Used by the API
  for a,b in pairs(fillWith) do
    if type(b) == "table" then
      if not toFill then toFill = {} end
      toFill[a] = fillTable(toFill[a],b)
    else
      if not toFill then toFill = {} end
      toFill[a] = toFill[a] or b
    end
  end
  return toFill
end
 
--Misc--
function checkPos(x,y,screen)
  screen = screen or curScreen
  assert(screens[screen],"screen '"..screen.."' doesn't exsist",2)
  x = tonumber(x)
  y = tonumber(y)
  assert(x and y,"expected number,number",2)
  local insideArea = {}
  for name,data in pairs(screens[screen].clickAreas) do
    if x >= data.minX and x <= data.maxX and y >= data.minY and y <= data.maxY and data.state == true then
      if data.action then
        return data.action()
      else
        return "click_area",name
      end
    end
  end
  for name,data in pairs(screens[screen].objects) do
    if data.hasClickArea and data.state ~= "off" and x >= data.minX and x <= data.maxX and y >= data.minY and y <= data.maxY then
      if data.action then
        return data.action()
      else
        return "object",name
      end
    end
  end
end
 
function handleEvents(screen,useRaw)
  screen = screen or curScreen
  assert(screens[screen],"screen '"..screen.."' doesn't exsist",2)
  local pull = os.pullEvent
  if useRaw == true then
    pull = os.pullEventRaw
  end
  local eArgs = {pull()}
  if eArgs[1] == "mouse_click" then
    local cType,name = checkPos(eArgs[3],eArgs[4],screen)
    if type(name) == "string" then
      return cType,name,eArgs[2]
    end
  end
  return unpack(eArgs)
end
 
function setDefaultObject(newDefaultObject)
  assert(type(newDefaultObject) == "table","expected table, got "..type(newDefaultObject),2)
  newDefaultObject = fillTable(newDefaultObject,default.object)
  default.object = newDefaultObject
end
 
function setDefaultClickArea(newDefaultClickArea)
  assert(type(newDefaultClickArea) == "table","expected table, got "..type(newDefaultClickArea),2)
  newDefaultClickArea = fillTable(newDefaultClickArea,default.clickArea)
  default.clickArea = newDefaultClickArea
end
 
--Screens--
function addScreen(name,backColor,setToCurScreen)
  assert(name,"expected name",2)
  assert(screens[name] == nil,"screen '"..name.."' already exsits",2)
  screens[name] = {
    background = backColor or colors.white,
    objects = {},
    clickAreas = {}
  }
  if setToCurScreen then curScreen = name end
end
 
function setScreen(name)
  assert(screens[name] ~= nil,"screen doesn't exist",2)
  curScreen = name
end
 
function draw(name,place)
  name = name or curScreen
  assert(screens[name] ~= nil,"screen doesn't exist",2)
  place = place or term
  assert(type(place) == "table","place should be a table, or nil",2)
  place.setBackgroundColor(screens[name].background)
  place.clear()
  for objName,objData in pairs(screens[name].objects) do
    if objData.state ~= "off" then
      drawObject(objName,name,place)
    end
  end
end
 
function getScreen(name)
  name = name or curScreen
  assert(screens[name] ~= nil,"screen doesn't exist",2)
  return screens[name]
end
 
--Click Areas--
function addClickArea(clickAreaInfo,screen)
  screen = screen or curScreen
  assert(screens[screen] ~= nil,"screen doesn't exist",2)
  assert(type(clickAreaInfo) == "table","expected table, got "..type(clickAreaInfo),2)
  clickAreaInfo = fillTable(clickAreaInfo,default.clickArea)
  assert( screens[screen].clickAreas[clickAreaInfo.name] == nil,"a click area with the name '"..clickAreaInfo.name.."' already exsists")
  screens[screen].clickAreas[clickAreaInfo.name] = clickAreaInfo
end
 
function toggleClickArea(name,screen)
  screen = screen or curScreen
  assert(screens[screen] ~= nil,"screen doesn't exist",2)
  assert(screens[screen].clickAreas[name] ~= nil,"Click Area '"..name.."' doesn't exsist",2)
  screens[screen].clickAreas[name].state = not screens[screen].clickAreas[name].state
  return screens[screen].clickAreas[name]
end
 
--Objects--
function addObject(objectInfo,screen)
  screen = screen or curScreen
  assert(screens[screen] ~= nil,"screen '"..screen.."' doesn't exist",2)
  assert(type(objectInfo) == "table","expected table, got "..type(objectInfo),2)
  objectInfo = fillTable(objectInfo,default.object)
  assert(screens[screen].objects[objectInfo.name] == nil,"an object with the name '"..objectInfo.name.."' already exsists")
  screens[screen].objects[objectInfo.name] = objectInfo
end
 
function drawObject(name,screen,place)
  screen = screen or curScreen
  assert(screens[screen] ~= nil,"screen doesn't exist",2)
  assert(screens[screen].objects[name] ~= nil,"Object '"..name.."' doesn't exsist",2)
  place = place or term
  assert(type(place) == "table","place should be a table, or nil",2)
  local objData = screens[screen].objects[name]
  assert(type(objData.state) == "boolean","Object '"..name.."' is off, and can't be drawn",2)
  if objData.state == true then
    place.setBackgroundColor(objData.colors.back.on)
    place.setTextColor(objData.colors.text.on)
  else
    place.setBackgroundColor(objData.colors.back.off)
    place.setTextColor(objData.colors.text.off)
  end
  for i = 0, objData.maxY-objData.minY do
    place.setCursorPos(objData.minX,objData.minY+i)
    place.write(string.rep(" ",objData.maxX-objData.minX+1))
  end
  if objData.text then
    local xPos = objData.minX+math.ceil((objData.maxX-objData.minX+1)/2) - math.ceil(#tostring(objData.text)/2)
    local yPos = objData.minY+(objData.maxY-objData.minY)/2
    place.setCursorPos(xPos,yPos)
    place.write(objData.text)
  end  
end
 
function toggleObjectState(name,screen)
  screen = screen or curScreen
  assert(screens[screen] ~= nil,"screen doesn't exist",2)
  assert(screens[screen].objects[name] ~= nil,"Object '"..name.."' doesn't exsist",2)
  if screens[screen].objects[name].state ~= true and screens[screen].objects[name].state ~= false then
    screens[screen].objects[name].state = true
  else
    screens[screen].objects[name].state = not screens[screen].objects[name].state
  end
  return screens[screen].objects[name].state
end
 
function getObjectState(name,screen)
  screen = screen or curScreen
  assert(screens[screen] ~= nil,"screen doesn't exist",2)
  assert(screens[screen].objects[name] ~= nil,"Object '"..name.."' doesn't exsist",2)
  return screens[screen].objects[name].state
end
 
function changeObjectText(name,newText,screen)
  screen = screen or curScreen
  assert(screens[screen] ~= nil,"screen doesn't exist",2)
  assert(screens[screen].objects[name] ~= nil,"Object '"..name.."' doesn't exsist",2)
  assert(type(newText) == "nil" or type(newText) == "string","expected string,string or string,nil, got string"..type(newText))
  screens[screen].objects[name].text = newText
end
 
function toggleObject(name,screen)
  screen = screen or curScreen
  assert(screens[screen] ~= nil,"screen doesn't exist",2)
  assert(screens[screen].objects[name] ~= nil,"Object '"..name.."' doesn't exsist",2)
  if type(screens[screen].objects[name].state) == "boolean" then
    screens[screen].objects[name].state = "off"
  else
    screens[screen].objects[name].state = true
  end
  return screens[screen].objects[name].state
end
 
function setObjectText(name,setText,screen)
  screen = screen or curScreen
  assert(screens[screen] ~= nil,"screen doesn't exist",2)
  assert(screens[screen].objects[name] ~= nil,"Object '"..name.."' doesn't exsist",2)
  screens[screen].objects[name].text = setText
end
--End of Screen API

local function getPath(name)
  local toReturn = table.concat(curPath,"/")
  if name then 
    toReturn = toReturn.."/"..name 
  elseif #curPath == 0 then
    return ""
  end
  return toReturn
end

local function getCol(index,...)
  local args = {...}
  local col = settings.colors[colorType][index]
  if type(col) == "table" then
    col = col[args[1]]
  end
  if type(col) ~= "number" then
    error("Color Scheme '"..colorType.."' doesn't have the color '"..index.."'",2)
  end
  return col
end

local function textColor(...)
  term.setTextColor( getCol(...) )
end

local function backColor(...)
  term.setBackgroundColor( getCol(...) )
end

local viewSizeCalc = {
  Tiles = function()
    
  end,
  List = function()
    maxY = h-1
    maxX = w-1
    perPage = maxY-minY
    midPage = math.ceil(w/2)
    pages = math.ceil(#dir/perPage)
    if pages < 1 then pages = 1 end
    page = 1
    setScreen("screen_List")
    for i = 1, perPage do
      screens.screen_List.clickAreas[tostring(i)] = nil
      addClickArea({
        name = tostring(i),
        minX = minX,
        maxX = maxX,
        minY = minY+i-1,
        maxY = minY+i-1
      })
    end
  end
}

local viewDrawScreen = {
  Tiles = function()
    
  end,
  List = function()
    for i = 1, perPage do
      local curIndex = i+perPage*(page-1)
      if curIndex > #dir then break end
      local cur = dir[curIndex]
      local back = getCol("back")
      local text = getCol("text")
      if cur.name == selected then back = getCol("selected") text = getCol("selectedText") end
      term.setCursorPos(minX,minY+i-1)
      term.setBackgroundColor(cur.back) term.write(" ") backColor("back") term.write(" ")
      local toWrite = cur.name
      if #toWrite > midPage-(minX+2) then
        toWrite = toWrite:sub(1,midPage-(minX+2)-3).."..."
      end
      term.setBackgroundColor(back) term.setTextColor(text) term.write( toWrite..string.rep(" ",maxX-2-#toWrite) )
      local size = getSize(getPath(cur.name),true)
      if size ~= 0 then
        term.setCursorPos(midPage+1,minY+i-1) term.write(size)
      end
    end
  end
}

local function sortDir()
  selected = nil numSelect = 0
  dir = fs.list(getPath())
  pathFolders,pathFiles = {},{}
  for i = 1, #dir do
    local fullPath = getPath(dir[i])
    if fs.isDir( fullPath ) then
      table.insert(pathFolders,dir[i])
    else
      table.insert(pathFiles,dir[i])
    end
  end
  dir = {}
  for i = 1, #pathFolders do table.insert(dir,{name = pathFolders[i],text = getCol("folderText"),back = getCol("folder"),type = "Folder"}) end
  for i = 1, #pathFiles do table.insert(dir,{name = pathFiles[i],text = getCol("fileText"),back = getCol("file"),type = "File"}) end
end

local function drawScreen()
  setScreen("main")
  backColor("back")
  term.clear()
  paintutils.drawLine(1,1,w,1,getCol("headingBack"))
  textColor("headingText")
  printC( getPath() == "" and "Root - File Manager "..version or "/"..getPath() ,1)
  backColor("back")
  textColor("text")
  printC("Page "..page.." of "..pages,h)
  screens.main.objects.page_up.state = page > 1
  drawObject("page_up")
  screens.main.objects.page_down.state = page < pages
  drawObject("page_down")
  screens.main.objects.back.state = historyPos > 1
  drawObject("back")
  screens.main.objects.forward.state = historyPos < #pathHistory
  drawObject("forward")
  screens.main.objects.level_up.state = (getPath() ~= "")
  drawObject("level_up")
  viewDrawScreen[ curView ]()
  textColor("text") backColor("back")
  if showText then 
    printC(showText,h-1) 
  elseif selected then
    printC(selected,h-1)
  else
    printC("Press 'h' for controls",h-1)
  end
end

local function pageUp()
  if page > 1 then page = page-1 drawScreen() end
end

local function pageDown()
  if page < pages then page = page+1 drawScreen() end
end

local doSizeCalc = nil -- Thanks for this tip, Lignum :)

local function back()
  if historyPos > 1 then
    historyPos = historyPos - 1
    curPath = pathHistory[historyPos]
    sortDir()
    doSizeCalc()
    drawScreen()
  end
end

local function forward()
  if historyPos < #pathHistory then
    historyPos = historyPos + 1
    curPath = pathHistory[historyPos]
    sortDir()
    doSizeCalc()
    drawScreen()
  end
end

local changePath = nil
local function up()
  if getPath() ~= "" then
    local temp = {unpack(curPath)}
    table.remove(temp,#temp)
    changePath(temp)
    selected = nil numSelect = 0
    sortDir()
    doSizeCalc()
    drawScreen()
  end
end

doSizeCalc = function()
  w,h = term.getSize()
  screens.main.objects = {}
  setScreen("main")
  addObject({
    name = "page_down", text = "v",
    minX = w, maxX = w,
    minY = h-2, maxY = h-2,
    colors = { back = { on = getCol("menuButtons","default"), off = getCol("menuButtons","disabled")}},
    action = pageDown
  })
  addObject({
    name = "page_up", text = "^",
    minX = w, maxX = w,
    minY = 3, maxY = 3,
    colors = { back = { on = getCol("menuButtons","default"), off = getCol("menuButtons","disabled")}},
    action = pageUp
  })
  addObject({
    name = "back", text = "<",
    minX = 3, maxX = 3,
    minY = 2, maxY = 2,
    colors = { back = { on = getCol("menuButtons","default"), off = getCol("menuButtons","disabled")}},
    action = back
  })
  addObject({
    name = "forward", text = ">",
    minX = 5, maxX = 5,
    minY = 2, maxY = 2,
    colors = { back = { on = getCol("menuButtons","default"), off = getCol("menuButtons","disabled")}},
    action = forward
  })
  addObject({
    name = "level_up", text = "Go Up",
    minX = 7, maxX = 11,
    minY = 2, maxY = 2,
    colors = { back = { on = getCol("menuButtons","default"), off = getCol("menuButtons","disabled")}},
    action = up
  })
  viewSizeCalc[ curView ]()
end

changePath = function(newPath)
  while historyPos < #pathHistory do
    table.remove(pathHistory,#pathHistory)
  end
  curPath = newPath
  if curPath[1] == "" then table.remove(curPath,1) end
  table.insert(pathHistory,curPath)
  historyPos = #pathHistory
  sortDir()
  showText = nil
end

local function openDir(name)
  if fs.isDir(getPath(name)) then
    selected = nil
    numSelect = 0
    local temp = {unpack(curPath)}
    table.insert(temp,name)
    changePath(temp)
    doSizeCalc()
    showText = nil
    drawScreen()
    return true
  end
  return false
end

local function enterDir()
  backColor("headingBack") textColor("headingText")
  local input = scrollRead(1,1,w,getPath())
  if fs.isDir(input) then
    changePath(split(input,"/"))
    doSizeCalc()
  else
    showText = "Not a valid path"
  end
  drawScreen()
end

local function runProgram(path,...)
  if multishell then
    shell.run("fg",path,...)
  else
    term.setBackgroundColor(colors.black) term.setTextColor(colors.white) term.clear() term.setCursorPos(1,1)
    shell.run(path,...)
    term.setCursorBlink( false )
    print( "Press enter to continue" )
    repeat
      local event,key = os.pullEvent("key")
    until key == keys.enter
    drawScreen()
  end
end

local function properties()
  local path,name
  if selected then
    path = getPath(selected)
    name = selected
  else
    path = getPath()
    name = fs.getName(path)
  end
  
  local function drawPropertiesScreen()
    backColor("back") term.clear()
    paintutils.drawLine(1,1,w,1,getCol("headingBack"))
    textColor("headingText")
    printC("Properties",1)
    backColor("back") textColor("text")
    term.setCursorPos(2,3) term.write("Name: "..name)
    local writePath = path
    if writePath == "" then
      writePath = "/"
    end
    term.setCursorPos(2,4) term.write("Path: "..writePath)
    term.setCursorPos(2,6) term.write("Type: ")
    if fs.isDir(path) then
      term.write("Folder")
    else
      term.write("File")
      term.setCursorPos(2,7) term.write("Size: "..getSize(path))
    end
    local attributes = {}
    if fs.isReadOnly(path) then table.insert(attributes,"Read-Only") end
    if name == shell.getRunningProgram() then table.insert(attributes,"Running") end
    if #attributes > 0 then
      term.setCursorPos(2,8) term.write("Attributes: "..table.concat(attributes,","))
    end
    printC("Click anywhere or hit a key to close",h)
  end
  
  drawPropertiesScreen()
  repeat
    local event = os.pullEvent()
  until event == "mouse_click" or event == "key"
  doSizeCalc()
  drawScreen()
end

local function window(heading,height,width)
  width = width or #heading + 4
  local windowMinY = math.ceil(h/2-height/2)
  local minX = math.ceil(w/2-width/2)
  if heading then
    term.setCursorPos(minX,windowMinY) textColor("headingText") backColor("headingBack")
    term.write(string.rep(" ",width)) printC(heading,windowMinY)
  end
  backColor("menuBack")
  for i = 1, height do
    term.setCursorPos(minX,windowMinY+i)
    term.write(string.rep(" ",width))
  end
  return minX,minX+width,windowMinY
end

local function option(heading,choices,width,cancel)
  if cancel then
    table.insert(choices,{text = "Cancel",color = getCol("menuButtons","cancel")})
  end
  local _,_,windowMinY = window(heading,(#choices*2)+1,width)
  if screens[name] then screens[name] = nil end
  addScreen("option",colors.white,true)
  local largest = 0
  for i = 1, #choices do
    if #choices[i].text > largest then
      largest = #choices[i].text
    end
  end
  largest = largest + 2
  local pos = 2
  local minButtonX = math.floor(w/2 - largest/2)
  for i = 1, #choices do
    addObject({
      text = choices[i].text,
      name = tostring(i),
      minX = minButtonX,
      maxX = minButtonX+largest,
      minY = windowMinY+pos,
      maxY = windowMinY+pos,
      colors = {
        text = { on = getCol("menuButtons","textSelected"), off = getCol("menuButtons","text")},
        back = {
          on = getCol("selected"),
          off = (choices[i].color or getCol("menuButtons","default"))
        }
      }
    })
    toggleObjectState(tostring(i))
    drawObject(tostring(i))
    pos = pos+2
  end
  toggleObjectState("1")
  drawObject("1")
  local selectButton = 1
  while true do
    local event = {os.pullEvent()}
    if event[1] == "mouse_click" then
      local _,name = checkPos(event[3],event[4])
      if name then selectButton = tonumber(name) break end
    elseif event[1] == "key" then
      if event[2] == keys.down then
        if selectButton < #choices then
          toggleObjectState(tostring(selectButton))
          drawObject(tostring(selectButton))
          selectButton = selectButton+1
          toggleObjectState(tostring(selectButton))
          drawObject(tostring(selectButton))
        end
      elseif event[2] == keys.up then
        if selectButton > 1 then
          toggleObjectState(tostring(selectButton))
          drawObject(tostring(selectButton))
          selectButton = selectButton-1
          toggleObjectState(tostring(selectButton))
          drawObject(tostring(selectButton))
        end
      elseif event[2] == keys.enter then
        break
      end
    end
  end
  screens.option = nil
  doSizeCalc()
  drawScreen()
  return selectButton
end

local function getInput(heading,insertText,requireText)
  os.queueEvent("Distraction") os.pullEvent("Distraction")
  heading = heading or "Enter Text"
  local windowMinX,windowMaxX,windowMinY = window(heading,3)
  backColor("inputBack") textColor("inputText")
  local input
  repeat
    input = scrollRead(windowMinX+1,windowMinY+2,windowMaxX-windowMinX-2,insertText)
  until input ~= "" or not requireText
  doSizeCalc()
  drawScreen()
  return input
end

local function displayList(heading,elements)
  local listTop = 3
  local listBottom = h-2
  local listLeft = 2
  local perPage = listBottom-listTop
  local tLines = {}
  
  for e = 1, #elements do
    if e ~= 1 then table.insert(tLines," ") end
    table.insert(tLines,elements[e][1])
    for a = 1, #elements[e][2] do
      table.insert(tLines,"  "..elements[e][2][a])
    end
  end
  
  pages = math.ceil(#tLines/perPage)
  
  local function redrawList()
    backColor("back") term.clear()
    paintutils.drawLine(1,1,w,1,getCol("headingBack"))
    textColor("headingText") printC(heading,1)
    for i = 1, #tLines do
      if i > perPage then break end
      local cur = i+perPage*(page-1)
      if cur > #tLines then break end
      textColor("text") backColor("back")
      term.setCursorPos(listLeft,listTop+i-1)
      term.write(tLines[cur])
    end
    printC("Hit 'enter' to continue",h)
  end
  
  redrawList()
  while true do
    local event = {os.pullEvent()}
    if event[1] == "key" then
      if event[2] == keys.enter then
        if page < pages then
          page = page + 1
          redrawList()
        else
          doSizeCalc()
          drawScreen()
          return
        end
      end
    end
  end
end

local function runProgArgs(path)
  local args = split(getInput("Enter Args - Separate each with a space",nil,true))
  runProgram(path,unpack(args))
end

local function rename()
  if not fs.isReadOnly(getPath(selected)) then
    local input = getInput("  Rename Item  ",selected,true)
    if fs.exists(getPath(input)) then
      showText = "Already exists!"
    else
      fs.move( getPath(selected) , getPath(input) )
      selected = nil
      numSelect = 0
      sortDir()
    end
  else
    showText = "This item is read-only"
  end
  drawScreen()
end

local function create()
  if not fs.isReadOnly(getPath()) then
    local options = {}
    for i = 1, #items do
      options[i] = {text = items[i].name}
    end
    local choice = option("Create...",options,nil,true)
    if choice ~= #options then
      local input = getInput(" Enter ".. items[choice].name .." Name ",nil,true)
      local itemPath = getPath(input)
      if not fs.exists(itemPath) then
        if not fs.isReadOnly(getPath()) then
          if not items[choice].create( itemPath ) then
            showText = "Unable to create "..items[choice].name
          end
        else
        end
      else
        showText = input.." already exists"
      end
      sortDir()
    end
  else
    showText = "This folder is read-only"
  end
  drawScreen()
end

local function delete()
  if not fs.isReadOnly(getPath(selected)) then
    if option("Delete selected item?",{{text = "Delete"},{text = "Cancel"}}) == 1 then
      fs.delete(getPath(selected))
      sortDir()
    end     
  else
    showText = "This item is read-only"
  end
  drawScreen()
end

local function selectView()
  local temp = {}
  for i = 1, #displayViews do
    table.insert(temp,{text = displayViews[i]})
  end
  local choice = option("Select View (Current:"..curView..")",temp)
  screens["screen_"..curView] = nil
  curView = displayViews[choice]
  doSizeCalc()
  drawScreen()
end

local function help()
  displayList("File Manager Help",{
    {"General",
      {
        "Click / Use arrows to select an item",
        "Click / Enter to open selected item",
        "< and > / Forward and Back to navigate history",
        "Go Up / 'u' to go up a level",
        "Ctrl + (Click / Enter) to run with arguments"
      }
    },
    {"Mouse Controls",
      {
        "Left click to select an item",
        "Left click selected item to open or run",
        "Right Click background for options",
        "Right Click an item for options",
        "Click 'v' / '^' or scroll to navagate pages"
      }
    },
    {"Keyboard Controls",
      {
        "'x' to quit",
        "'o' for selected item options",
        "'o' with nothing selected for more options",
        "'c' to create an item",
        "'Tab' to enter a path",
        "Page Up / Down to navagate pages",
        "'e' to edit current item (Files only)",
        "'p' for selected item's Properties",
        "'r' to rename selected item",
        "'d' to delete selected item",
        "'u' to go up a level",
        "'Enter' to run or open",
        "Left / Right Arrow to navagate history",
      }
    }
  })
end

local function itemOptions()
  local temp = {
    {text = "Run"},
    {text = "Run with args"},
    {text = "Edit"},
    {text = "Rename"},
    {text = "Delete"},
    {text = "New..."},
    {text = "Properties"}
  }
  local choice = option(nil,temp,22,true)
  if choice == 1 then
    runProgram(selected)
  elseif choice == 2 then
    runProgArgs(getPath(selected))
  elseif choice == 3 then
    runProgram("edit",selected)
  elseif choice == 4 then
    rename()
  elseif choice == 5 then
    delete()
  elseif choice == 6 then
    create()
  elseif choice == 7 then
    properties()
  end
end

local function dirOptions()
  local temp = {
    {text = "View..."},
    {text = "New..."},
    {text = "Controls"},
    {text = "Properties"},
    {text = "Quit File Manager"}
  }
  local choice = option(nil,temp,22,true)
  if choice == 1 then
    selectView()
  elseif choice == 2 then
    create()
  elseif choice == 3 then
    help()
  elseif choice == 4 then
    properties()
  elseif choice == 5 then
    error("Terminated")
  end
end


--=== Program ===--
--Determine which color scheme to use
if term.isColor() then
  colorType = "Full Color"
elseif _CC_VERSION or _HOST then
  colorType = "Gray Scale"
else -- Must be using a CC version before Gray Scale
  print("Black and White displays are not supported at this time")
  print("You'll need to use and Advanced (Gold) Computer")
  return
  --colorType = "Black and White"
end

--Main Loop
local function main()
  addScreen("main",colors.white,true)
  addScreen("screen_List",colors.white)
  sortDir()
  doSizeCalc()
  drawScreen()
  while true do
    local event = { os.pullEvent() }
    
    if event[1] == "mouse_click" then
      if event[4] == 1 then
        enterDir()
      elseif not checkPos(event[3],event[4],"main") then
        local element,name = checkPos(event[3],event[4],"screen_List")
        if name then
          local cur = tonumber(name)+perPage*(page-1)
          if cur <= #dir then
            if event[2] == 1 then
              if cur == numSelect then
                if not openDir(selected) then
                  if ctrlHeld then
                    runProgArgs(getPath(selected))
                  else
                    runProgram(getPath(selected))
                  end
                end
              else
                selected = dir[cur].name
                numSelect = cur
                drawScreen()
              end
            elseif event[2] == 2 then
              selected = dir[cur].name
              numSelect = cur
              drawScreen()
              itemOptions()
            end
          else
            selected = nil
            numSelect = nil
            drawScreen()
            if event[2] == 2 then dirOptions() end
          end
        else
          selected = nil
          numSelect = nil
          drawScreen()
        end
      end
    elseif event[1] == "key" then
      if event[2] == keys.down then
        if not selected and #dir ~= 0 then
          numSelect = 1
          selected = dir[numSelect].name
          page = 1
          drawScreen()
        elseif numSelect < #dir then
          numSelect = numSelect+1
          selected = dir[numSelect].name
          local selectedPage = math.ceil(numSelect/perPage)
          if selectedPage ~= page then page = selectedPage end
          drawScreen()
        end
      elseif event[2] == keys.up then
        if not selected and #dir ~= 0 then
          numSelect = 1
          selected = dir[numSelect].name
          drawScreen()
        elseif numSelect > 1 then
          numSelect = numSelect-1
          selected = dir[numSelect].name
          local selectedPage = math.ceil(numSelect/perPage)
          if selectedPage ~= page then page = selectedPage end
          drawScreen()
        end
      elseif event[2] == keys.enter then
        if selected then
          if not openDir(selected) then
            if ctrlHeld then
              runProgArgs(getPath(selected))
            else
              runProgram(getPath(selected))
            end
          end
        end
      elseif event[2] == keys.leftShift then
        shiftHeld = true
      elseif event[2] == keys.leftCtrl then
        ctrlHeld = true
      elseif event[2] == keys.pageUp then
        pageUp()
      elseif event[2] == keys.pageDown then
        pageDown()
      elseif event[2] == keys.tab then
        enterDir()
      elseif event[2] == keys.x then
        error("Terminated")
      elseif event[2] == keys.e then
        os.pullEvent("char") -- Get that stray 'e' char event
        runProgram("/rom/programs/edit",getPath(selected))
      elseif event[2] == keys.p then
        properties()
      elseif event[2] == keys.r and selected then
        rename()
      elseif event[2] == keys.c then
        create()
      elseif event[2] == keys.d and selected then
        delete()
      elseif event[2] == keys.u then
        up()
      elseif event[2] == keys.left then
        back()
      elseif event[2] == keys.right then
        forward()
      elseif event[2] == keys.h then
        help()
      elseif event[2] == keys.o then
        if selected then
          itemOptions()
        else
          dirOptions()
        end
      end
    elseif event[1] == "key_up" then
      if event[2] == keys.leftShift then
        shiftHeld = false
      elseif event[2] == keys.leftCtrl then
        ctrlHeld = false
      end
    elseif event[1] == "term_resize" then
      doSizeCalc()
      drawScreen()
    elseif event[1] == "mouse_scroll" then
      if event[2] > 0 then
        pageDown()
      else
        pageUp()
      end
    end
  end
end

local state,err = pcall(main)
if not state then
  if err then
    if err:find("Terminated") then
      term.setBackgroundColor(colors.gray) term.setTextColor(2)
      term.clear()
      printC("Thanks for using File Manager "..version,1)
      printC("By HPWebcamAble",2)
      sleep(5)
      shell.run("os/menus/utils")
      term.setBackgroundColor(colors.gray)
      term.setCursorPos(1,3)
    elseif err:find("FORCEQUIT") then
      -- Do nothing
    else
      term.setBackgroundColor(colors.black)
      term.setTextColor(colors.white)
      term.write("X")
      paintutils.drawLine(1,1,w,1,colors.black)
      printC("Error - Press Enter",1)
      repeat
        local event,key = os.pullEvent("key")
      until key == keys.enter
      term.clear()
      printC("Error!",1)
      term.setCursorPos(1,2)
      print(err)
      print(" ")    
    end
  else
    term.setBackgroundColor(colors.black) term.setTextColor(colors.white)
    term.clear()
    printC("An known error occured",1)
    print(" ")
  end
end

os.queueEvent("Distraction")
os.pullEvent("Distraction") -- Clear the event queue