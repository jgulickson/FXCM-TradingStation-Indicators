------------------------------------------Overview------------------------------------------
-- Name:             Symbol Overlay
-- Notes:            Copyright (c) 2016 Jeremy Gulickson
-- Version:          1.0.07282016
-- Usage:            Calculates and displays symbol's change during period in pips and
--                   percent terms as well as symbol's net open positions and net PL.
--
-- Requirements:     FXTS (FXCM Trading Station)
-- Download Link:    http://download.fxcorporate.com/FXCM/FXTS2Install.EXE
-- Documentation:    http://www.fxcodebase.com/documents/IndicoreSDK-2.3/web-content.html
--
---------------------------------------Version History--------------------------------------
-- v1.0.11092014:    Initial release
--
-- v1.1.07282016:    Added average open rate
--                   Added average pips
--                   Added automatic suppression of values if exposure = 0
--                   Overall code optimization
--
--------------------------------------------------------------------------------------------


local Source;
local Host;
local Color = {};
local Display = {};
local Symbol = {};
local Font = {};
local Summary = {};
local Offer = {};

	
function Init()
    indicator:name("Symbol Overlay");
    indicator:type(core.Indicator);
    indicator:setTag("group", "Statistics");

	indicator.parameters:addGroup("Color Options");
	indicator.parameters:addColor("SymbolRateColor", "Symbol Rate Color", "Select the color of rate text.", core.rgb(255, 255, 255));
	indicator.parameters:addColor("SymbolNameColor", "Symbol Name Color", "Select the color of symbol name text.", core.rgb(255, 255, 255));
	indicator.parameters:addColor("NeutralColor", "Neutral Values", "Select the color of neutral values.", core.rgb(192, 192, 192));
	indicator.parameters:addColor("PositiveColor", "Positive Values", "Select the color of positive values.", core.rgb(128, 255, 0));
	indicator.parameters:addColor("NegativeColor", "Negative Values", "Select the color of negative values.", core.rgb(255, 53, 53));
	
	indicator.parameters:addGroup("Display Options");
	indicator.parameters:addInteger("LegendCount", "Number of Legend Entries", "Enter the number of legend entries visible.", 1, 0, 10);
	indicator.parameters:addBoolean("ShowSymbolName", "Show Symbol Name", "", true);
	indicator.parameters:addBoolean("ShowNetPositions", "Show Net Positions", "", true);
	indicator.parameters:addBoolean("ShowNetPL", "Show Net P/L", "", true);
	indicator.parameters:addBoolean("ShowAverageOpen", "Show Average Open Rate", "", true);
	indicator.parameters:addBoolean("ShowAveragePips", "Show Average Pips", "", true);
end


function Prepare()
	Source = instance.source;
    Host = core.host;

	Offer.Table = Host:findTable("offers");
	
	Color.Rate = instance.parameters.SymbolRateColor;
	Color.Symbol = instance.parameters.SymbolNameColor;
	Color.Neutral = instance.parameters.NeutralColor;
	Color.Positive = instance.parameters.PositiveColor;
	Color.Negative = instance.parameters.NegativeColor;
	
	Display.LegendCount = instance.parameters.LegendCount;
	Display.SymbolName = instance.parameters.ShowSymbolName;
	Display.NetPositions = instance.parameters.ShowNetPositions;
	Display.NetPL = instance.parameters.ShowNetPL;
	Display.AverageOpen = instance.parameters.ShowAverageOpen;
	Display.AveragePips = instance.parameters.ShowAveragePips;
	CalculateOffsets();
	
	Symbol.Name = Source:instrument();
	Symbol.PipSize = Source:pipSize();
	Symbol.OfferID = Offer.Table:find("Instrument", Symbol.Name).OfferID;
	Symbol.Type = Offer.Table:find("Instrument", Symbol.Name).InstrumentType;
	if Source:isBid() == true then 
		Symbol.Data = Host:execute("getBidPrice");
	else
		Symbol.Data = Host:execute("getAskPrice");
	end
	if Symbol.Type == 1 then
		Symbol.Precision = Symbol.Data:getPrecision() - 1;
	else
		Symbol.Precision = Symbol.Data:getPrecision();
	end
	
	instance:name("Symbol Overlay(" .. Symbol.Name .. ")");
	
	Font.Rate = Host:execute("createFont", "Verdana", 55, false, true);
	Font.Information = Host:execute("createFont", "Verdana", 23, false, false);
end


function CalculateOffsets()
	Display.yRateOffset = 32 + (Display.LegendCount * 18);
	Display.ySymbolOffset = Display.yRateOffset + 50;
	Display.yPipsOffset = Display.yRateOffset - 15;
	Display.yPercentOffset = Display.yRateOffset + 17;
	Display.yNetPositionsOffset = Display.yPipsOffset;
	Display.yNetPLOffset = Display.yPercentOffset;
	Display.yAverageOpen = Display.yPipsOffset;
	Display.yAveragePips = Display.yPercentOffset;
	
	Display.xRateOffset = 3;
	Display.xSymbolOffset = 10;
	-- These 5 offsets are calculated in the update function as they depend on rate digits.
	-- Display.xPipsOffset
	-- Display.xPercentOffset
	-- Display.xNetPositionsOffset
	-- Display.xNetPLOffset
	-- Display.xAverageOpen
	-- Display.xAveragePips
end


function Update(period)
	if Source:hasData(period) then
	
		-- Calculate all values
		Symbol.Open = Symbol.Data.open[period];
		Symbol.Close = Symbol.Data.close[period];
		Symbol.PipsChange = (Symbol.Close - Symbol.Open) / Symbol.PipSize;
		Symbol.PercentChange = (Symbol.Close - Symbol.Open) / Symbol.Open * 100;
		Summary.Table = Host:findTable("summary"):enumerator();
		Summary.Row = Summary.Table:next();
		Summary.NetPositions = 0;
		Summary.NetPL = 0;
		Summary.AverageOpen = 0;
		Summary.AveragePips = 0;
		while Summary.Row ~= nil do
			if Symbol.OfferID == Summary.Row.OfferID then
				Summary.NetPositions = Summary.Row.AmountK;
				Summary.NetPL = Summary.Row.NetPL;
				if Summary.NetPositions ~= 0 and Summary.NetPositions > 0 then
					Summary.AverageOpen = Summary.Row.BuyAvgOpen;
				else
					Summary.AverageOpen = Summary.Row.SellAvgOpen;						
				end
				break;
			end
			Summary.Row = Summary.Table:next();
		end
		if Summary.NetPositions ~= 0 and Summary.NetPL > 0 then
			Summary.AveragePips = (Symbol.Close - Summary.AverageOpen) / Symbol.PipSize;
		elseif Summary.NetPositions ~= 0 then
			Summary.AveragePips = (Summary.AverageOpen - Symbol.Close) / Symbol.PipSize;
		end
		
		-- Format colors
		if Symbol.PipsChange > 0 then
			Color.PipsPerent = Color.Positive
		elseif Symbol.PipsChange < 0 then
			Color.PipsPerent = Color.Negative
		else
			Color.PipsPerent = Color.Neutral
		end
		if Summary.NetPositions > 0 then
			Color.NetPositions = Color.Positive
		elseif Summary.NetPositions < 0 then
			Color.NetPositions = Color.Negative
		else
			Color.NetPositions = Color.Neutral
		end
		if Summary.NetPL > 0 then
			Color.NetPL = Color.Positive
		elseif Summary.NetPL < 0 then
			Color.NetPL = Color.Negative
		else
			Color.NetPL = Color.Neutral
		end
		
		-- Format values
		Symbol.Close = Format_Precision(Symbol.Data.close[period], Symbol.Precision);
		Symbol.PipsChange = Format_Pips(math.abs(Symbol.PipsChange), 0)
		Symbol.PercentChange = Format_Percentage(math.abs(Symbol.PercentChange), 2)
		Summary.NetPL = Format_Financial(math.abs(Summary.NetPL), 2);
		if Summary.NetPositions ~= 0 then
			Symbol.NetPLDigits = string.len(Summary.NetPL);
			Summary.NetPositions = Format_AmountK(math.abs(Summary.NetPositions), 0)
		else
			Symbol.NetPLDigits = 4;
		end
		Summary.AverageOpen = Format_Precision(math.abs(Summary.AverageOpen), Symbol.Precision);
		Summary.AveragePips = Format_Pips(math.abs(Summary.AveragePips), 0);

		-- Format placement
		Symbol.RateDigits = string.len(Symbol.Close);
		Symbol.PipsDigits = string.len(Symbol.PipsChange);
		if string.find(Symbol.Close, "%.") then
			Display.xPipsOffset = 47 * Symbol.RateDigits;
		else
			Display.xPipsOffset = 50 * Symbol.RateDigits;
		end
		Display.xPercentOffset = Display.xPipsOffset;
		Display.xNetPositionsOffset = 19 * Symbol.PipsDigits + Display.xPipsOffset;
		Display.xNetPLOffset = Display.xNetPositionsOffset;
		Display.xAverageOpen = 19 * Symbol.NetPLDigits + Display.xNetPositionsOffset + 6;
		Display.xAveragePips =  Display.xAverageOpen
		
		-- Drawing
		Host:execute("drawLabel1", 1, Display.xRateOffset, core.CR_LEFT, Display.yRateOffset, core.CR_TOP, core.H_Right, core.V_Center, Font.Rate, Color.Rate, Symbol.Close);
		if Display.SymbolName then Host:execute("drawLabel1", 2, Display.xSymbolOffset, core.CR_LEFT, Display.ySymbolOffset, core.CR_TOP, core.H_Right, core.V_Center, Font.Information, Color.Symbol, Symbol.Name) end
		Host:execute("drawLabel1", 3, Display.xPipsOffset, core.CR_LEFT, Display.yPipsOffset, core.CR_TOP, core.H_Right, core.V_Center, Font.Information, Color.PipsPerent, Symbol.PipsChange);
		Host:execute("drawLabel1", 4, Display.xPercentOffset, core.CR_LEFT, Display.yPercentOffset, core.CR_TOP, core.H_Right, core.V_Center, Font.Information, Color.PipsPerent, Symbol.PercentChange);
		if Display.NetPositions and Summary.NetPositions ~= 0 then Host:execute("drawLabel1", 5, Display.xNetPositionsOffset, core.CR_LEFT, Display.yNetPositionsOffset, core.CR_TOP, core.H_Right, core.V_Center, Font.Information, Color.NetPositions, Summary.NetPositions) end
		if Display.NetPL and Summary.NetPositions ~= 0 then Host:execute("drawLabel1", 6, Display.xNetPLOffset, core.CR_LEFT, Display.yNetPLOffset, core.CR_TOP, core.H_Right, core.V_Center, Font.Information, Color.NetPL, Summary.NetPL) end
		if Display.AverageOpen and Summary.NetPositions ~= 0 then Host:execute("drawLabel1", 7, Display.xAverageOpen, core.CR_LEFT, Display.yAverageOpen, core.CR_TOP, core.H_Right, core.V_Center, Font.Information, Color.NetPL, Summary.AverageOpen) end
		if Display.AveragePips and Summary.NetPositions ~= 0 then Host:execute("drawLabel1", 8, Display.xAveragePips, core.CR_LEFT, Display.yAveragePips, core.CR_TOP, core.H_Right, core.V_Center, Font.Information, Color.NetPL, Summary.AveragePips) end
	end
end


function Format_Precision(input, decimals)
	return string.format("%." .. decimals .. "f", input);
end


function Format_AmountK(input, decimals)
	return string.format("%." .. decimals .. "f", input) .. "K";
end


function Format_Pips(input, decimals)
	return string.format("%." .. decimals .. "f", input) .. " pips";
end


function Format_Percentage(input, decimals)
	return string.format("%." .. decimals .. "f", input) .. "%";
end


function Format_Financial(input, decimals)
	-- Inspired by http://www.gammon.com.au/forum/?id=7805
	input = string.format("%." .. decimals .. "f", input);
	
	local result = ""
	local sign, before, after = string.match (tostring (input), "^([%+%-]?)(%d*)(%.?.*)$")
	while string.len (before) > 3 do
		result = "," .. string.sub (before, -3, -1) .. result
		before = string.sub (before, 1, -4)
	end

	return "$" .. sign .. before .. result .. after;
end


function ReleaseInstance()
    Host:execute("deleteFont", Font.Rate);
	Host:execute("deleteFont", Font.Information);
end