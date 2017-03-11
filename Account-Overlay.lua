------------------------------------------Overview------------------------------------------
-- Name:             Account Overlay
-- Notes:            Copyright (c) 2016 Jeremy Gulickson
-- Version:          1.0.01312016
-- Usage:            Shows current Equity, Day P/l, Day P/L in Percent and Leverage.
--
-- Requirements:     FXTS (FXCM Trading Station)
-- Download Link:    http://download.fxcorporate.com/FXCM/FXTS2Install.EXE
-- Documentation:    http://www.fxcodebase.com/bin/beta/IndicoreSDK-3.0/help/web-content.html
--
---------------------------------------Version History--------------------------------------
-- v1.0.01312016:    Initial release
--
--------------------------------------------------------------------------------------------


local Host;
local PaintSetup;
local RefreshTimer;

local Account = {};
local Font = {};
local Color = {};
local Display = {};

	
function Init()
    indicator:name("Account Overlay");
    indicator:type(core.Indicator);
    indicator:setTag("group", "Statistics");

	indicator.parameters:addGroup("Color Options");
	indicator.parameters:addColor("EquityColor", "Equity Color", "Select the color of equity text.", core.rgb(255, 255, 255));
	indicator.parameters:addColor("LeverageColor", "Leverage Color", "Select the color of equity text.", core.rgb(255, 255, 255));
	indicator.parameters:addColor("BackgroundColor", "Background Color", "Select the color of the chart background.", core.rgb(56, 56, 56));
	indicator.parameters:addColor("NeutralColor", "Neutral Values", "Select the color of neutral values.", core.rgb(192, 192, 192));
	indicator.parameters:addColor("PositiveColor", "Positive Values", "Select the color of positive values.", core.rgb(0, 128, 255));
	indicator.parameters:addColor("NegativeColor", "Negative Values", "Select the color of negative values.", core.rgb(255, 53, 53));
	
	indicator.parameters:addGroup("Display Options");
	indicator.parameters:addInteger("LegendCount", "Number of Legend Entries", "Enter the number of legend entries visible.", 0, 0, 10);
	indicator.parameters:addString("AccountName", "Account Number", "Select the account to monitor.", "");
	indicator.parameters:setFlag("AccountName", core.FLAG_ACCOUNT);
end


function Prepare()
    Host = core.host;
	PaintSetup = false;
	instance:ownerDrawn(true);
	
	Color.Equity = instance.parameters.EquityColor;
	Color.Leverage = instance.parameters.LeverageColor;
	Color.Background = instance.parameters.BackgroundColor;
	Color.Neutral = instance.parameters.NeutralColor;
	Color.Positive = instance.parameters.PositiveColor;
	Color.Negative = instance.parameters.NegativeColor;
	
	Display.LegendCount = instance.parameters.LegendCount;
	Account.Name = instance.parameters.AccountName
	CalculateOffsets();
	
	instance:name("Account Overlay (" .. Account.Name .. ")");
	
	Font.Equity = Host:execute("createFont", "Verdana", 70, false, true);
	Font.DayPL = Host:execute("createFont", "Verdana", 30, false, false);
	Font.DayPLp = Host:execute("createFont", "Verdana", 30, false, false);
	Font.Leverage = Host:execute("createFont", "Verdana", 30, false, false);
	
	Calculate_Account()
	Calculate_Trade()
	Update_Display()
	
	RefreshTimer = Host:execute("setTimer", 1, 5);
end


function CalculateOffsets()
	Display.yEquityOffset = 45 + (Display.LegendCount * 18);
	Display.yDayPLOffset = Display.yEquityOffset - 19;
	Display.yDayPLpOffset = Display.yEquityOffset + 21;
	Display.yLeverageOffset = Display.yDayPLOffset;

	Display.xEquityOffset = 5;
	-- These two offsets are calculated in the update function as they depend on equity digits.
	-- Display.xDayPLOffset = 10;
	-- Display.xDayPLpOffset = 10;
	-- Display.xLeverageOffset = 10;
end


function Update()
	-- Not used
end


function Update_Display()
	if Account.DayPL > 0 then
		Color.DayPL = Color.Positive
		Color.DayPLp = Color.Positive
	elseif Account.DayPL < 0 then
		Color.DayPL = Color.Negative
		Color.DayPLp = Color.Negative
	else
		Color.DayPL = Color.Neutral
		Color.DayPLp = Color.Neutral
	end
	
	Display.xDayPLOffset = 58 * Display.EquityDigits;
	Display.xDayPLpOffset = Display.xDayPLOffset;
	if Display.DayPLDigits > Display.DayPLpDigits then
		Display.xLeverageOffset = 27 * Display.DayPLDigits + Display.xDayPLpOffset;
	else
		Display.xLeverageOffset = 27 * Display.DayPLpDigits + Display.xDayPLpOffset;
	end

	Account.Equity = Format_Financial(Account.Equity, 0);
	Account.DayPL = Format_Financial(math.abs(Account.Row.DayPL), 0);
	Account.DayPLp = Format_Percentage(math.abs((Account.Row.DayPL / Account.Row.Equity) * 100), 2);
	
	Host:execute("drawLabel1", 1, Display.xEquityOffset, core.CR_LEFT, Display.yEquityOffset, core.CR_TOP, core.H_Right, core.V_Center, Font.Equity, Color.Equity, Account.Equity);
	Host:execute("drawLabel1", 2, Display.xDayPLOffset, core.CR_LEFT, Display.yDayPLOffset, core.CR_TOP, core.H_Right, core.V_Center, Font.DayPL, Color.DayPL, Account.DayPL);
	Host:execute("drawLabel1", 3, Display.xDayPLpOffset, core.CR_LEFT, Display.yDayPLpOffset, core.CR_TOP, core.H_Right, core.V_Center, Font.DayPLp, Color.DayPLp, Account.DayPLp);
	Host:execute("drawLabel1", 4, Display.xLeverageOffset, core.CR_LEFT, Display.yLeverageOffset, core.CR_TOP, core.H_Right, core.V_Center, Font.Leverage, Color.Leverage, Account.Leverage);
end


function Calculate_Account()
    if not(Host:execute("isTableFilled", "accounts")) then
		-- Login does not contain any accounts or data is inaccessible.
		error("No Accounts Found.");
    end
	
	Account.Table = Host:findTable("accounts");
	Account.Row = Account.Table:find("AccountID", Account.Name);
	if Account.Row ~= nil then
		Display.EquityDigits = string.len(Format_Financial(Account.Row.Equity, 0));
		Display.DayPLDigits = string.len(Format_Financial(Account.Row.DayPL, 0));
		Display.DayPLpDigits = string.len(Format_Percentage(((Account.Row.DayPL / Account.Row.Equity) * 100), 2));
		
		Account.Equity = Account.Row.Equity;
		Account.DayPL = Account.Row.DayPL;
		Account.DayPLp = (Account.Row.DayPL / Account.Row.Equity) * 100;
	else
		-- Login does not contain the selected account or the selected account row is inaccessible.
		error("Selected Account Not Found.");
    end
end


function Calculate_Trade()
    if not(Host:execute("isTableFilled", "trades")) then
		-- Login does not have any open trades or data is inaccessible.
		Account.Leverage = "0:1";
		return;
    end
	
	local Offer = {};
	local Trade = {};
	Offer.Table = Host:findTable("offers");
	Trade.Table = Host:findTable("trades"):enumerator();
	Trade.Row = Trade.Table:next();
	Trade.SumInUSD = 0;
	while Trade.Row ~= nil do
		Trade.Symbol = Trade.Row.Instrument;
		if Trade.Row.AccountID == Account.Name and Offer.Table:find("Instrument", Trade.Symbol).InstrumentType == 1 then
			Trade.Base = Offer.Table:find("Instrument", Trade.Symbol).ContractCurrency;
			Trade.Amount = Trade.Row.Lot;
			Trade.SizeInUSD = Calculate_ConvertToUSD(Trade.Base, Trade.Amount);
			Trade.SumInUSD = Trade.SumInUSD + Trade.SizeInUSD;
		end
		Trade.Row = Trade.Table:next();
	end
	Account.Leverage = Format_Precision(Trade.SumInUSD / Account.Equity, 2);
	Account.Leverage = tostring(Account.Leverage .. ":1");
end


function Calculate_ConvertToUSD(base, amount)
	local SizeInUSD = 0;
	local Offer = {};
	Offer.Table = Host:findTable("offers");
	
	if base == "EUR" then SizeInUSD = amount * Offer.Table:find("Instrument", "EUR/USD").Bid;
	elseif base == "USD" then SizeInUSD = amount;
	elseif base == "GBP" then SizeInUSD = amount * Offer.Table:find("Instrument", "GBP/USD").Bid;
	elseif base == "AUD" then SizeInUSD = amount * Offer.Table:find("Instrument", "AUD/USD").Bid;
	elseif base == "NZD" then SizeInUSD = amount * Offer.Table:find("Instrument", "NZD/USD").Bid;
	elseif base == "CAD" then SizeInUSD = amount * (1 / Offer.Table:find("Instrument", "USD/CAD").Bid);
	elseif base == "CHF" then SizeInUSD = amount * (1 / Offer.Table:find("Instrument", "USD/CHF").Bid);
	elseif base == "HKD" then SizeInUSD = amount * (1 / Offer.Table:find("Instrument", "USD/HKD").Bid);
	elseif base == "JPY" then SizeInUSD = amount * (1 / Offer.Table:find("Instrument", "USD/JPY").Bid);
	elseif base == "NOK" then SizeInUSD = amount * (1 / Offer.Table:find("Instrument", "USD/NOK").Bid);
	elseif base == "SEK" then SizeInUSD = amount * (1 / Offer.Table:find("Instrument", "USD/SEK").Bid);
	elseif base == "SGD" then SizeInUSD = amount * (1 / Offer.Table:find("Instrument", "USD/SGD").Bid);
	elseif base == "TRY" then SizeInUSD = amount * (1 / Offer.Table:find("Instrument", "USD/TRY").Bid);
	elseif base == "ZAR" then SizeInUSD = amount * (1 / Offer.Table:find("Instrument", "USD/ZAR").Bid);
	else error("Base Currency Conversion Path Does Not Exist");
	end
	return SizeInUSD;
end


function Draw(stage, context)
	if stage == 1 then
		if not PaintSetup then
			context:createSolidBrush(0, Color.Background);
			PaintSetup = true;
		end
		context:drawRectangle(-1, 0, 0, 0, 2000, 2000, 0);
	end
end


--------------------------------------------------------------------------------------------------
---------------------------------------Common Functions-------------------------------------------
--------------------------------------------------------------------------------------------------


function Format_Precision(input, decimals)
	return string.format("%." .. decimals .. "f", input);
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


function AsyncOperationFinished(Reference)
	if Reference == 1 then
		Calculate_Account(Account.Name)
		Calculate_Trade()
		Update_Display()
	end
end


function ReleaseInstance()
    Host:execute("deleteFont", Font.Equity);
	Host:execute("deleteFont", Font.DayPL);
	Host:execute("deleteFont", Font.DayPLp);
end