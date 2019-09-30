Expelo = { 
    UI = { },
    events = { },
    totalExp = 0,
    intervalStartTime = 0, 
    elapsedTime = 0,
    recording = false,
}

local debug = true;

function Expelo:init()
    Expelo:BuildWindow();
    -- EVENT REGISTRATION
    for k, v in pairs(Expelo.events) do 
        Expelo.UI.rootFrame:RegisterEvent(k);
    end
    Expelo.UI.rootFrame:SetScript("OnEvent", function(_, event, ...)
        Expelo:OnEvent(_, event, ...);
    end);

    Expelo:Reset();
end

-- Generic event handler function
function Expelo:OnEvent(_, event, ...)
    if (Expelo.events[event]) then
        Expelo.events[event](self, ...);
    end
end

function Expelo.events:ADDON_LOADED(addon)
    if (addon == "Expelorometer" and debug) then
        print("Expelorometer loaded!");
    end
end

function Expelo.events:CHAT_MSG_COMBAT_XP_GAIN(text)
    if (debug) then
        print("xp from kill detected");
    end
    if (Expelo.recording) then
        local gainedExp = string.match(text, "gain (%d+) experience");
        Expelo:UpdateExp(gainedExp);
    end
end

function Expelo.events:CHAT_MSG_SYSTEM(text)
    if (debug) then
        print("chat msg system fired, text: " .. text);
    end
    local gainedExp = string.match(text, "(%d+) experience");
    if (gainedExp) then
        if (debug) then
            print("Exp found: " .. gainedExp);
        end
        Expelo:UpdateExp(gainedExp);
    end
end

-- TO BE REMOVED
-- function Expelo.events:QUEST_TURNED_IN(...)
--     return; -- TESTING IF CHAT_MSG_COMBAT_XP_GAIN IS ENOUGH
--     -- if (debug) then
--     --     print("Quest turn in detected.");
--     --     print("Gained xp: " .. (select(2, ...)))
--     -- end
--     -- if (Expelo.recording) then
--     --     local gainedExp = (select(2, ...));
--     --     Expelo:UpdateExp(gainedExp);
--     -- end
-- end

-- Resets all stats to 0, ready to begin recording again
function Expelo:Reset()
    Expelo.totalExp = 0;
    Expelo.elapsedTime = 0;
    Expelo.intervalStartTime = time();
    Expelo:UpdateExp(0);
end

-- Toggles recording. When stopping, elapsedTime is updated. When starting, intervalStartTime is updated for the new interval
function Expelo:Record()
    if (Expelo.recording) then
        Expelo.recording = false;
        Expelo:UpdateExp(0);
        Expelo.UI.recordButton:SetText("Start");
    else
        Expelo.recording = true;
        Expelo.intervalStartTime = time();
        Expelo.UI.recordButton:SetText("Stop");
    end
end

-- Builds all aspects of the UI
function Expelo:BuildWindow()
    Expelo.UI.rootFrame = CreateFrame("Frame", "sandboxFrame", UIParent, "BasicFrameTemplateWithInset");

    Expelo.UI.rootFrame:SetMovable(true);
    -- Expelo.UI.rootFrame:SetResizable(true);
    -- Expelo.UI.rootFrame:SetMinResize(140, 63);
    -- Expelo.UI.rootFrame:SetMaxResize(500, 500);
    Expelo.UI.rootFrame:EnableMouse(true);
    Expelo.UI.rootFrame:SetScript("OnMouseDown", function(self, button)
        if (button == "LeftButton") then 
            self:StartMoving();
            self.isMoving = true
        end
    end)
    Expelo.UI.rootFrame:SetScript("OnMouseUp", function(self)
        if (self.isMoving) then
            self:StopMovingOrSizing()
            self.isMoving = false
        end
    end)
    Expelo.UI.rootFrame.title = Expelo.UI.rootFrame:CreateFontString(nil, "OVERLAY");
    Expelo.UI.rootFrame.title:SetFontObject("GameFontHighlight");
    Expelo.UI.rootFrame.title:SetPoint("CENTER", Expelo.UI.rootFrame.TitleBg, "CENTER", 0, 0);
    Expelo.UI.rootFrame.title:SetText("XP Tracker");
    Expelo.UI.rootFrame:SetSize(180, 150);
    Expelo.UI.rootFrame:SetPoint("CENTER", UIParent, "CENTER");


    Expelo.UI.rootFrame.xpRateText = Expelo.UI.rootFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    Expelo.UI.rootFrame.xpRateText:SetPoint("LEFT", Expelo.UI.rootFrame, "LEFT", 20, -5);
    local Font, Height, Flags = Expelo.UI.rootFrame.xpRateText:GetFont();
    Expelo.UI.rootFrame.xpRateText:SetFont(Font, 20, Flags);
    Expelo.UI.rootFrame.xpRateText:SetTextColor(1, 1, 1, 1);

    Expelo.UI.rootFrame.percentRate = Expelo.UI.rootFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    Expelo.UI.rootFrame.percentRate:SetPoint("LEFT", Expelo.UI.rootFrame, "LEFT", 20, -45);
    Font, Height, Flags = Expelo.UI.rootFrame.percentRate:GetFont();
    Expelo.UI.rootFrame.percentRate:SetFont(Font, 20, Flags);
    Expelo.UI.rootFrame.percentRate:SetTextColor(1, 1, 1, 1);

    Expelo.UI.resetButton = CreateFrame("Button", "sandboxReset", Expelo.UI.rootFrame, "GameMenuButtonTemplate");
    Expelo.UI.resetButton:SetPoint("TOPRIGHT", Expelo.UI.rootFrame, "TOPRIGHT", -20, -30);
    Expelo.UI.resetButton:SetSize(70, 30);
    Expelo.UI.resetButton:SetText("Reset");
    Expelo.UI.resetButton:SetNormalFontObject("GameFontNormal");
    Expelo.UI.resetButton:SetHighlightFontObject("GameFontHighlight");
    Expelo.UI.resetButton:SetScript("OnClick", function(self)
        Expelo:Reset();
    end);

    Expelo.UI.recordButton = CreateFrame("Button", "sandboxRecord", Expelo.UI.rootFrame, "GameMenuButtonTemplate");
    Expelo.UI.recordButton:SetPoint("TOPLEFT", Expelo.UI.rootFrame, "TOPLEFT", 15, -30);
    Expelo.UI.recordButton:SetSize(70, 30);
    Expelo.UI.recordButton:SetText("Start");
    Expelo.UI.recordButton:SetNormalFontObject("GameFontNormal");
    Expelo.UI.recordButton:SetHighlightFontObject("GameFontHighlight");
    Expelo.UI.recordButton:SetScript("OnClick", function(self)
        Expelo:Record();
    end);

end

-- Adds gainedExp to total, updates time, and updates UI to reflect changes
function Expelo:UpdateExp(gainedExp)
    if (debug) then
        print("Updating exp: total: " .. Expelo.totalExp .. ", +" .. gainedExp);
    end
    Expelo.totalExp = Expelo.totalExp + gainedExp;

    local maxExp = UnitXPMax("player");
    Expelo:UpdateTime();
    local xpRate = -1;
    if (Expelo.elapsedTime == 0) then
        if (debug) then
            print("elapsed time is 0. xpRate set to 0");
        end
        xpRate = 0;
    else
        xpRate = math.floor(Expelo.totalExp / (Expelo.elapsedTime * (1 / 3600)));
    end
    if (debug) then
        print("xprate: " .. xpRate);
    end
    local percentRate = (xpRate / maxExp) * 100;
    Expelo.UI.rootFrame.xpRateText:SetText(xpRate .. " xp/hr");
    Expelo.UI.rootFrame.percentRate:SetText(string.format("%.1f", percentRate) .. " %/hr");
end

function Expelo:UpdateTime()
    local time = time();
    Expelo.elapsedTime = Expelo.elapsedTime + (time - Expelo.intervalStartTime)
    Expelo.intervalStartTime = time;
    if (debug) then
        print("Time updated. Elapsed time is now " .. Expelo.elapsedTime);
    end
end

Expelo:init();