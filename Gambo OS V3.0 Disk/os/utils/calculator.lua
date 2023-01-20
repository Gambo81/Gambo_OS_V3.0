os.pullEvent = os.pullEventRaw

image = paintutils.loadImage("/os/backgrounds/gray.nfp")
paintutils.drawImage(image, 1, 1)
term.setBackgroundColor(colors.gray)
term.setTextColor(2)

term.clear()
term.setCursorPos(1,1)

-- This function performs the given operation on the two operands
function calculate(operand1, operator, operand2)
  if operator == "+" then
    return operand1 + operand2
  elseif operator == "-" then
    return operand1 - operand2
  elseif operator == "" then
    return operand1 - operand2
  elseif operator == "/" then
    return operand1 / operand2
  else
    -- If the operator is not recognized, return nil
    return nil
  end
end

-- Prompt the user for operand1, operator, and operand2
print("Enter the first operand:")
local operand1 = tonumber(read())

print("Enter the operator (+, -, *, /):")
local operator = read()

print("Enter the second operand:")
local operand2 = tonumber(read())

-- Calculate the result and print it
local result = calculate(operand1, operator, operand2)
if result then
  print("Result: " .. result)
else
  print("Invalid operator")
end

os.pullEvent("mouse_click") 
  term.setTextColor(colors.white)
  return