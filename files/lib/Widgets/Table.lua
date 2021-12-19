--[[
    DOCUMENTATION:
    The table widget works like a standard table in lua.
    It has and index and a corespoding tuple of (key, value)
    an example for such a table looks like that: 

    local tableEntries = {}
    tableEntries[1] = {Entry1 = 100}
    tableEntries[2] = {Entry2 = 123}
    tableEntries[3] = {Entry3 = 144}
    tableEntries[4] = {Entry4 = 53}
    tableEntries[5] = {Entry5 = 87}
    tableEntries[6] = {Entry6 = 113}

    This will print a table on screen of the following makeup if the choosen seperator string is "=>":

    Entry1 => 100
    Entry2 => 123
    Entry3 => 144
    Entry4 => 53
    Entry5 => 87
    Entry6 => 113

    The first index is the order in which the entries will be printed to screen.

    NOTE: You have to make sure, that before you try to print the table
    the indices in the list must be integers, that can be sorted in an ascending order.
    Both elements of the key->value entry must consist of types, that have a defined bahaviour
    if put into the tostring(elem) function such that the function returns a string.

    WARNING: Mutating the content of the table is NOT thread safe against the method for printing.
    Altering the content of the table and printing at the same time will result in undefined behaviour.
--]]


--[[
    Sets default values for the visualization of the table
    Arguments: entries -> an intial list of key, value pairs that the table will print
]]

-- constants

LAYOUT_HORIZONTAL_LEFT = 0
LAYOUT_HORIZONTAL_CENTER = 1
LAYOUT_HORIZONTAL_RIGHT = 2

LAYOUT_VERTICAL_TOP = 0
LAYOUT_VERTICAL_CENTER = 1
LAYOUT_VERTICAL_BOTTOM = 2

LAYOUT_ALIGNMENT = 0
LAYOUT_ABSOLUTE = 1

Table = {}
Table.__index = Table
function Table:New(entries)
    local instance = {}
    setmetatable(instance, Table)
    --set fields like this
    --instance.int_value = int_argument
    instance.entries = entries or {}
    
    -- default values
    instance:SetHorizontalAlignment(HORIZONTAL_RIGHT)
    instance:SetVerticalAlignment(VERTICAL_BOTTOM)
    instance:SetLayoutMode(LAYOUT_ALIGNMENT)
    instance:SetEntrySeparator("->")
    instance:SetHeader(nil)

    return instance
end

--[[
    Returns the internally used list of table entries for manipulation.
    You can add/remove/alter... entries in this list and it will be reflected
    in the next call to print in the view.
--]]
function Table:GetEntryList()
    return self.entries;
end

--[[
    Sets the string that is printed on top of the table.
    If nil is given no header will be printed and during printing to screen no space
    will be reserved for a header
]]
function Table:SetHeader(header)
    self.header = header
end

--[[
    Sets the string, that is used to separate the key and value strings while printing the table
]]
function Table:SetEntrySeparator(separator)
    self.entrySeparator = separator
end

--[[
    Sets the horizontal alignnment of the table on screen.
    Given as an integer in the range (0,2) where
    use the LAYOUT_HORIZONTAL_XYZ constants
]]
function Table:SetHorizontalAlignment(alignment)
    self.horizontalAlignmentMode = alignment
end

--[[
    Sets the vertical alignnment of the table on screen.
    Given as an integer in the range (0,2) where
    use the LAYOUT_VERTICAL_XYZ constants
]]
function Table:SetVerticalAlignment(alignment)
    self.verticalAlignmentMode = alignment
end

--[[
    Sets the absolute position of the table on screen in screen coordinates.
    Info: The position (0,0) is on the screen left top
    This value is only respected if the layeout has been set to LAYOUT_ALIGMENT using the SetLayoutMode method
]]
function Table:SetPosition(xPos, yPos)
    self.xPos = xPos
    self.yPos = yPos
end

--[[
    Sets the alignnment mode of the table on screen.
    Given as an integer in the range (0,1) where
    use the constants LAYOUT_ALIGMENT or LAYOUT_ABSOLUTE to set the mode
]]
function Table:SetLayoutMode(layoutMode)
    self.layoutMode = layoutMode
end

local function formatEntry(key, value, separator)
    local formatedEntry = tostring(key) .. tostring(separator) .. tostring(value)
    return formatedEntry
end

local function calculateTableDimensions(guiHandle, table, separator)
    local tableWidth = 0
    local tableHeight = 0
    for index, tableEntry in ipairs(table) do
        -- value is now the key->value mapping of this entry
        for key, value in pairs(tableEntry) do
            local formatedTableEntry = formatEntry(key, value, separator)
            local textWidth, textHeight = GuiGetTextDimensions(guiHandle, formatedTableEntry)
            tableHeight = tableHeight + textHeight
            tableWidth = math.max(tableWidth, textWidth)    
        end
    end
    return tableWidth, tableHeight
end

--[[
    Prints the table to the screen under consideration of all set layout options

    Arguments: guiHandle is the handle given by the noita system.
    Usually returned by GuiCreate()

    CAUTION: Make sure to call GuiStartFrame(guiHandle) before trying to print anything to screen
]]
function Table:Print(guiHandle)
    local tableWidth, tableHeight = calculateTableDimensions(guiHandle, self.entries, self.entrySeparator)

    if(self.header ~= nil) then
       local _, headerHeight = GuiGetTextDimensions(guiHandle, self.header)
       tableHeight = tableHeight + headerHeight
    end

    -- determine the top left coordinate of the table to print
    local screenWidth, screenHeight = GuiGetScreenDimensions(guiHandle)

    local tableXPos = 0
    local tableYPos = 0

    if(self.layoutMode == LAYOUT_ALIGNMENT) then
        -- set x coordinate
        if(self.horizontalAlignmentMode == LAYOUT_HORIZONTAL_LEFT) then
            tableXPos = 0
        elseif (self.horizontalAlignmentMode == LAYOUT_HORIZONTAL_CENTER) then
            -- set the x pos so that the center of the table is in the center of the screen
            tableXPos = math.floor(screenWidth / 2) - math.floor(tableWidth / 2)
        elseif  (self.horizontalAlignmentMode == LAYOUT_HORIZONTAL_RIGHT) then
            -- set the x pos so that the left end of the table end on the left side of the screen
            tableXPos = screenWidth - tableWidth
        end

        -- set y coordinate
        if(self.verticalAlignmentMode == LAYOUT_VERTICAL_TOP) then
            tableYPos = 0
        elseif (self.verticalAlignmentMode == LAYOUT_VERTICAL_CENTER) then
            -- set the y pos so that the center of the table is in the center of the screen
            tableYPos = math.floor(screenHeight / 2) - math.floor(tableHeight / 2)
        elseif  (self.verticalAlignmentMode == LAYOUT_VERTICAL_BOTTOM) then
            -- set the Y pos so that the left end of the table end on the left side of the screen
            tableYPos = screenHeight - tableHeight
        end
    else
        -- this is the code to handle the absolute positioning
        tableXPos = self.xPos
        tableYPos = self.yPos
    end

    -- the one determines that the pixel mode is supposed to be used for the drawing positions
    GuiLayoutBeginVertical(guiHandle, tableXPos, tableYPos, 1)
    if(self.header ~= nil) then
        GuiText(guiHandle, 0, 0, self.header)
    end
    for index, tableEntry in ipairs(self.entries) do
        for key, value in pairs(tableEntry) do
            local printableEntry = formatEntry(key, value, self.entrySeparator)
            GuiText(guiHandle, 0, 0, printableEntry)
        end
    end

    GuiLayoutEnd(guiHandle)
end