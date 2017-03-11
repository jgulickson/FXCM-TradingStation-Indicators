------------------------------------------Overview------------------------------------------
-- Name:             Inverted Spread Identifier
-- Notes:            Copyright (c) 2015 Jeremy Gulickson
-- Version:          1.0.mmddyyyy
-- Usage:            Highlights zero and negative spreads.
--
-- Requirements:     FXTS (FXCM Trading Station)
-- Download Link:    http://download.fxcorporate.com/FXCM/FXTS2Install.EXE
-- Documentation:    http://www.fxcodebase.com/documents/IndicoreSDK-2.3/web-content.html
--
---------------------------------------Version History--------------------------------------
-- v1.0.mmddyyyy:    Initial release
--
--------------------------------------------------------------------------------------------

local Source;
local Host;
Label = {};
Symbol = {};


function Init()
    indicator:name("Inverted Spread Identifier");
	indicator:description("Inverted Spread Identifier")
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	indicator:setTag("group", "Statistics");
end


function Prepare()
	Source = instance.source;
    Host = core.host;
	Symbol.Start = Source:first()
	Symbol.Name = Source:instrument();
	instance:name("Inverted Spread Identifier(" ..Symbol.Name.. ")");
	
	Symbol.BidData = Host:execute("getBidPrice");
	Symbol.AskData = Host:execute("getAskPrice");
	
	Symbol.InvertedPipsSum = 0;
	Symbol.InvertedPipsCount = 0;
	Symbol.InvertedPipsValue = 0;
	
	Symbol.FreePipsSum = 0;
	Symbol.FreePipsCount = 0;
	Symbol.FreePipsValue = 0;

	Label.Free = instance:createTextOutput ("Free Spread", "Free", "Wingdings", "20", core.H_Center, core.V_Center, core.rgb(128, 255, 0), 0);
	Label.Inverted = instance:createTextOutput ("Negative Spread", "Inverted", "Wingdings", "20", core.H_Center, core.V_Center, core.rgb(255, 53, 53), 0);
	Label.Zero = instance:createTextOutput ("Zero Spread", "Zero", "Wingdings", "20", core.H_Center, core.V_Center, core.rgb(192, 192, 192), 0);
	Label.Display = Host:execute("createFont", "Verdana", 20, false, false);
end


function Update(period)
	if period >= Symbol.Start and Source:hasData(period) and Source:isAlive() then
		Symbol.Bid = Symbol.BidData.open[period];
		Symbol.Ask = Symbol.AskData.open[period];
		Symbol.Spread = (Symbol.Ask - Symbol.Bid) / Source:pipSize();
		
		if Symbol.Spread < -.5 then
			Label.Free:set(period, Symbol.Ask, "\74", "Free Spread: " .. tostring(Symbol.Spread) .. " pips");
			Symbol.FreePipsSum = Symbol.FreePipsSum + Symbol.Spread;
			Symbol.FreePipsCount = Symbol.FreePipsCount + 1;
		
			Symbol.FreeDisplayPips = string.format("%." .. 1 .. "f", Symbol.FreePipsSum) .. " inverted pips across " .. Symbol.FreePipsCount .. " instances";
			Symbol.FreePipsValue = ((1 / Symbol.Bid) * Symbol.FreePipsSum) - (Symbol.FreePipsCount * .6);
			Symbol.FreeDisplayValue = "$".. string.format("%." .. 1 .. "f", Symbol.FreePipsValue);
		elseif Symbol.Spread < 0 then
			Label.Inverted:set(period, Symbol.Ask, "\75", "Inverted Spread: " .. tostring(Symbol.Spread) .. " pips");
			Symbol.InvertedPipsSum = Symbol.InvertedPipsSum + Symbol.Spread;
			Symbol.InvertedPipsCount = Symbol.InvertedPipsCount + 1;
			
			Symbol.InvertedDisplayPips = string.format("%." .. 1 .. "f", Symbol.InvertedPipsSum) .. " inverted pips across " .. Symbol.InvertedPipsCount .. " instances";
			Symbol.InvertedPipsValue = ((1 / Symbol.Bid) * Symbol.InvertedPipsSum) - (Symbol.InvertedPipsCount * .6);
			Symbol.InvertedisplayValue = "$".. string.format("%." .. 1 .. "f", Symbol.InvertedPipsValue);
		elseif Symbol.Spread == 0 then
			Label.Zero:set(period, Symbol.Ask, "\75", "Zero Spread: " .. tostring(Symbol.Spread) .. " pips");
		end
		
		Host:execute("drawLabel1", 1, 50, core.CR_LEFT, 50, core.CR_TOP, core.H_Right, core.V_Center, Label.Display, core.rgb(192, 192, 192), Symbol.InvertedDisplayPips);
		Host:execute("drawLabel1", 2, 50, core.CR_LEFT, 100, core.CR_TOP, core.H_Right, core.V_Center, Label.Display, core.rgb(192, 192, 192), Symbol.InvertedisplayValue);
		
		Host:execute("drawLabel1", 3, 50, core.CR_LEFT, 150, core.CR_TOP, core.H_Right, core.V_Center, Label.Display, core.rgb(192, 192, 192), Symbol.FreeDisplayPips);
		Host:execute("drawLabel1", 4, 50, core.CR_LEFT, 200, core.CR_TOP, core.H_Right, core.V_Center, Label.Display, core.rgb(192, 192, 192), Symbol.FreeDisplayValue);
	else
		error("Error");
		return;
	end
end