# LibFleeingButton-1.0
LibFleeingButton is a revolutionary new lib that makes buttons flee from the cursor.

## Usage

```lua
local button = CreateFrame("Button", nil, UIParent, "SharedGoldRedButtonTemplate");
button:SetPoint("CENTER");
button:SetText("Click for free Bitcoin!");

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
