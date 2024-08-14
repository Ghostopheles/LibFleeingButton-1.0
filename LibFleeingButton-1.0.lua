assert(LibStub, "LibStub not found.");

---@alias LibFleeingButton-1.0 LibFleeingButton
local major, minor = "LibFleeingButton-1.0", 2;

---@class LibFleeingButton
local LibFleeingButton = LibStub:NewLibrary(major, minor);

if not LibFleeingButton then
    return;
end

local NUM_CURSOR_SAMPLES = 5;
local FLEEING_BUTTONS = {};

local function ShouldMoveButton(button)
    if InCombatLockdown() and (button:IsProtected() or button:IsForbidden()) then
        return false;
    end

    if not button:IsShown() then
        return false;
    end

    if not FLEEING_BUTTONS[button] then
        return false;
    end

    if FLEEING_BUTTONS[button].Disabled then
        return false;
    end

    return true;
end

local function ShouldResetButton(button)
    if InCombatLockdown() and button:IsProtected() then
        return false;
    end

    if not FLEEING_BUTTONS[button] then
        return false;
    end

    return true;
end

local function GetPointsForObject(obj)
    local points = {};
    for i=1, obj:GetNumPoints() do
        local anchor = AnchorUtil.CreateAnchor(obj:GetPoint(i));
        tinsert(points, anchor);
    end

    return points;
end

local function HandleOnUpdate(button, deltaTime)
    if not ShouldMoveButton(button) then
        return;
    end

    local data = FLEEING_BUTTONS[button];
    if not data then
        return;
    end

    local cursorX, cursorY = GetScaledCursorPosition();
    data.CursorSamples:PushFront({
        x = cursorX,
        y = cursorY,
    });

    local numSamples = data.CursorSamples:GetNumElements();

    local sumX = 0;
    local sumY = 0;
    for _, element in data.CursorSamples:EnumerateIndexedEntries() do
        sumX = sumX + element.x;
        sumY = sumY + element.y;
    end
    local avgX = sumX / numSamples;
    local avgY = sumY / numSamples;

    local buttonX, buttonY = button:GetCenter();

    local distX, distY =  buttonX - avgX, buttonY - avgY;
    local totalDistanceSquared = distX^2 + distY^2;
    if totalDistanceSquared < 0.1 then
        totalDistanceSquared = 0.1;
    end

    local totalDistance = sqrt(totalDistanceSquared);

    local force = 1000000000 / totalDistanceSquared;
    local offset = force * deltaTime^2;
    if offset > 10 then
        offset = 10;
    end

    if totalDistance > 200 then
        return;
    end

    local offsetX = offset * (distX / totalDistance);
    local offsetY = offset * (distY / totalDistance);

    button:AdjustPointsOffset(offsetX, offsetY);
end

------------

---@param button Button | Frame
function LibFleeingButton.MakeButtonFlee(button)
    assert(not button:IsForbidden(), "LibFleeingButton cannot make forbidden objects flee. You need to behave.")

    if not FLEEING_BUTTONS[button] then
        button:HookScript("OnUpdate", HandleOnUpdate);
        button:SetClampedToScreen(true);

        FLEEING_BUTTONS[button] = {
            CursorSamples = CreateCircularBuffer(NUM_CURSOR_SAMPLES),
            Anchors = GetPointsForObject(button),
            Disabled = false,
        };
    end
end

---@param button Button | Frame
function LibFleeingButton.PauseButtonFleeing(button)
    if FLEEING_BUTTONS[button] then
        FLEEING_BUTTONS[button].Disabled = true;
    end
end

---@param button Button | Frame
function LibFleeingButton.ResumeButtonFleeing(button)
    if FLEEING_BUTTONS[button] then
        FLEEING_BUTTONS[button].Disabled = false;
    end
end

-- Calling this in combat will silently fail
---@param button Button | Frame
function LibFleeingButton.ResetButton(button)
    if not ShouldResetButton(button) then
        return;
    end

    button:ClearPointsOffset();
    button:ClearAllPoints();

    local anchors = FLEEING_BUTTONS[button].Anchors;
    for _, anchor in ipairs(anchors) do
        anchor:SetPoint(button);
    end

    FLEEING_BUTTONS[button] = nil;
end