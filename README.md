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
> Buttons that execute secure actions will not flee in combat nor will you be able to reset them in combat.
