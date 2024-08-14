# LibFleeingButton-1.0
LibFleeingButton is a revolutionary new lib that makes buttons flee from the cursor.

Despite the name, it works for any type of frame, not just buttons.

## Usage

```lua
local button = CreateFrame("Button", nil, UIParent, "SharedGoldRedButtonTemplate");
button:SetPoint("CENTER");
button:SetText("Click for free Bitcoin!");

---@type LibFleeingButton
local LibFleeingButton = LibStub:GetLibrary("LibFleeingButton-1.0");

-- make button scared
LibFleeingButton.MakeButtonFlee(button);

-- reset button
LibFleeingButton.ResetButton(button);

-- temporarily suspend fleeing
LibFleeingButton.PauseButtonFleeing(button);

-- resume fleeing
LibFleeingButton.ResumeButtonFleeing(button);

-- profit???
```

> [!CAUTION]
> Buttons won't flee from the cursor in combat, nor will you be able to reset buttons in combat. Maybe I'll tighten this restriction a bit and only apply it to restricted frames but I'm lazy.
