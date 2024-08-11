assert(LibStub, "LibStub not found.");

---@alias LibFleeingButton-1.0 LibFleeingButton
local major, minor = "LibFleeingButton-1.0", 1;

---@class LibFleeingButton
local LibFleeingButton = LibStub:NewLibrary(major, minor);

if not LibFleeingButton then
    return;
end

local NUM_CURSOR_SAMPLES = 5;
local FLEEING_BUTTONS = {};

-- stolen from TRP3
local function Debounce(timeout, callback)
	local calls = 0;

	local function Decrement()
		calls = calls - 1;

		if calls == 0 then
			callback();
		end
	end

	return function()
		C_Timer.After(timeout, Decrement);
		calls = calls + 1;
	end
end

local function ShouldMoveButton(button)
    if InCombatLockdown() then
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

function LibFleeingButton.MakeButtonFlee(button)
    if not FLEEING_BUTTONS[button] then
        button:HookScript("OnUpdate", HandleOnUpdate);
        button:SetClampedToScreen(true);

        FLEEING_BUTTONS[button] = {
            CursorSamples = CreateCircularBuffer(NUM_CURSOR_SAMPLES),
            Disabled = false,
        };
    end
end

function LibFleeingButton.MakeFrameFlee(frame)
    LibFleeingButton.MakeButtonFlee(frame);
end

function LibFleeingButton.PauseButtonFleeing(button)
    if FLEEING_BUTTONS[button] then
        FLEEING_BUTTONS[button].Disabled = true;
    end
end

function LibFleeingButton.ResumeButtonFleeing(button)
    if FLEEING_BUTTONS[button] then
        FLEEING_BUTTONS[button].Disabled = false;
    end
end

function LibFleeingButton.ResetButton(button)
    FLEEING_BUTTONS[button] = nil;
    button:ClearPointsOffset();
end