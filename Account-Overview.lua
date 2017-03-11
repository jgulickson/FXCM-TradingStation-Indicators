------------------------------------------Overview------------------------------------------
-- Name:             Account Overview
-- Notes:            Copyright (c) 2015 Jeremy Gulickson
-- Version:          1.0.mmddyyyy
-- Usage:            Recreates all trading tables and adds additional values for display on
--                   Marketscope for improved consumability.
--
-- Requirements:     FXTS (FXCM Trading Station)
-- Download Link:    http://download.fxcorporate.com/FXCM/FXTS2Install.EXE
-- Documentation:    http://www.fxcodebase.com/documents/IndicoreSDK-2.3/web-content.html
--
---------------------------------------Version History--------------------------------------
-- v1.0.mmddyyyy:    Initial release
--
--------------------------------------------------------------------------------------------

local Host;

local Length = {};
local Paint = {};
local Display = {};

local Accounts = {};
local Trades = {};
local ClosedTrades = {};
local Summary = {};
local Currency = {};

local CurrencyNames = {"EUR","USD","GBP","AUD","NZD","CAD","CHF","HKD","JPY","NOK","SEK","SGD","TRY","ZAR", ""};
local Nicknames = {"Portfolio Builder", "BreakoutME", "Manual"};
local AccountsNames = {};
local AccountsEquity = {};
local AccountsAmount = {};
local AccountsAmountSum = {};
local AccountsSize = {};
local AccountsSizSume = {};
local AccountsLeverage = {};
local AccountsLeverageSum = {};

function Init()
    indicator:name("Account Overview");
	indicator:description("Account Overview");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Statistics");
	
	indicator.parameters:addGroup("Display Options");
	indicator.parameters:addString("PublicMode", "Public Mode", "Hides sensitive information such as equity, balance, leverage, etc.", "Disabled");
	indicator.parameters:addStringAlternative("PublicMode", "Disabled", "", "Disabled");
	indicator.parameters:addStringAlternative("PublicMode", "Enabled", "", "Enabled");
	
	indicator.parameters:addGroup("Window Options");
	indicator.parameters:addString("ShowAccounts", "Accounts Data", "Similar to the FXTS accounts window.", "Show");
	indicator.parameters:addStringAlternative("ShowAccounts", "Show", "", "Show");
	indicator.parameters:addStringAlternative("ShowAccounts", "Hide", "", "Hide");
	indicator.parameters:addString("ShowTrades", "Trades Data", "Similar to the FXTS open positions window.", "Show");
	indicator.parameters:addStringAlternative("ShowTrades", "Show", "", "Show");
	indicator.parameters:addStringAlternative("ShowTrades", "Hide", "", "Hide");
	indicator.parameters:addString("ShowClosedTrades", "Closed Trades Data", "Similar to the FXTS closed positions window.", "Show");
	indicator.parameters:addStringAlternative("ShowClosedTrades", "Show", "", "Show");
	indicator.parameters:addStringAlternative("ShowClosedTrades", "Hide", "", "Hide");
	indicator.parameters:addString("ShowSummary", "Summary Data", "Similar to the FXTS summary window.", "Show");
	indicator.parameters:addStringAlternative("ShowSummary", "Show", "", "Show");
	indicator.parameters:addStringAlternative("ShowSummary", "Hide", "", "Hide");
	indicator.parameters:addString("ShowCurrency", "Currency Data", "Aggregates information by currency; requires Trades Data = Show to function.", "Show");
	indicator.parameters:addStringAlternative("ShowCurrency", "Show", "", "Show");
	indicator.parameters:addStringAlternative("ShowCurrency", "Hide", "", "Hide");
	
	indicator.parameters:addGroup("Color Options");
	indicator.parameters:addColor("ChartBackground", "Chart Background", "This should match the current background color for charts.", core.rgb(74, 74, 74));
	indicator.parameters:addColor("TitleTextColor", "Title Text", "", core.rgb(228, 228, 228));
	indicator.parameters:addColor("TitleBackgroundColor", "Title Background", "", core.rgb(0, 128, 255));
	indicator.parameters:addColor("SectionTextColor", "Section Text", "", core.rgb(0, 0, 0));
	indicator.parameters:addColor("SectionBackgroundColor", "Section Background", "", core.rgb(228, 228, 228));
	indicator.parameters:addColor("RowTextColor", "Row Text", "", core.rgb(228, 228, 228));
	indicator.parameters:addColor("RowBackgroundColor", "Row Background", "", core.rgb(105, 105, 105));
	indicator.parameters:addColor("TotalRowText", "Total Row Text", "", core.rgb(228, 228, 228));
	indicator.parameters:addColor("TotalRowBackgroundColor", "Total Row Background", "", core.rgb(0, 0, 0));
end


function Prepare()
    Host = core.host;
	instance:ownerDrawn(true);
	instance:name("Account Overview");
	
	if instance.parameters.PublicMode == "Disabled" then
		Display.Public = false;
	else
		Display.Public = true;
	end
	
	Display.Accounts = instance.parameters.ShowAccounts;
	Display.Trades = instance.parameters.ShowTrades;
	Display.ClosedTrades = instance.parameters.ShowClosedTrades;
	Display.Summary = instance.parameters.ShowSummary;
	Display.Currency = instance.parameters.ShowCurrency;
	
	Paint.ChartBackground = instance.parameters.ChartBackground;
	Paint.TitleTextColor = instance.parameters.TitleTextColor;
	Paint.TitleBackgroundColor = instance.parameters.TitleBackgroundColor;
	Paint.SectionTextColor = instance.parameters.SectionTextColor;
	Paint.SectionBackgroundColor = instance.parameters.SectionBackgroundColor;
	Paint.RowTextColor = instance.parameters.RowTextColor;
	Paint.RowBackgroundColor = instance.parameters.RowBackgroundColor;
	Paint.TotalRowText = instance.parameters.TotalRowText;
	Paint.TotalRowBackgroundColor = instance.parameters.TotalRowBackgroundColor;
	
	SetupSpacing()
	SetupLayout()
	
	Paint.Setup = false;
end


function SetupSpacing()
	-- General
	Length.TopSpacing = 20;
	Length.CharacterSpacing = 9;
	Length.ColumnSpacing = 5;
	Length.GapSpacing = 30;
	Length.TitleSpacing = 20;
	Length.SectionSpacing = 16;
	Length.RowSpacing = 15;
	
	-- Accounts
	Length.Accounts_AccountName = 8;
	Length.Accounts_Nickname = 15;
	Length.Accounts_Equity = 6;
	Length.Accounts_Amount = 6;
	Length.Accounts_Size = 6;
	Length.Accounts_Leverage = 8;
	Length.Accounts_GrossPL = 9;
	Length.Accounts_GrossPLp = 10;
	Length.Accounts_DayPL = 8;
	Length.Accounts_DayPLp = 9;
	Length.Accounts_UsedMargin = 8;
	Length.Accounts_BaseUnit = 8;
	
	-- Trades
	Length.Trades_AccountName = 8;
	Length.Trades_Symbol = 7;
	Length.Trades_Base = 5;
	Length.Trades_Counter = 6;
	Length.Trades_Amount = 6;
	Length.Trades_Size = 6;
	Length.Trades_Direction = 8;
	Length.Trades_PL = 6;
	Length.Trades_GrossPL = 8;
	Length.Trades_Roll = 5;
	Length.Trades_Comm = 5;
	Length.Trades_OpenTime = 14;
	Length.Trades_OpenRate = 7;
	Length.Trades_OpenDuration = 10;
	Length.Trades_CloseRate = 7;
	Length.Trades_UsedMargin = 7;
	
	-- Closed Trades
	Length.ClosedTrades_AccountName = 8;
	Length.ClosedTrades_Symbol = 7;
	Length.ClosedTrades_Base = 5;
	Length.ClosedTrades_Counter = 6;
	Length.ClosedTrades_Amount = 6;
	Length.ClosedTrades_Size = 6;
	Length.ClosedTrades_Direction = 8;
	Length.ClosedTrades_PL = 6;
	Length.ClosedTrades_GrossPL = 8;
	Length.ClosedTrades_Roll = 5;
	Length.ClosedTrades_Comm = 5;
	Length.ClosedTrades_OpenTime = 14;
	Length.ClosedTrades_OpenRate = 7;
	Length.ClosedTrades_OpenDuration = 10;
	Length.ClosedTrades_CloseTime = 14;
	Length.ClosedTrades_CloseRate = 7;
	Length.ClosedTrades_UsedMargin = 7;
	
	-- Summary
	Length.Summary_Symbol = 6;
	Length.Summary_SellAmount = 6;
	Length.Summary_SellNetPL = 8;
	Length.Summary_SellAvgOpen = 7;
	Length.Summary_BuyAmount = 6;
	Length.Summary_BuyAvgOpen = 7;
	Length.Summary_BuyNetPL = 8;
	Length.Summary_Amount = 6;
	Length.Summary_NetPL = 8;
	
	-- Currency
	Length.Currency_Symbol = 6;
	Length.Currency_SellSize = 8;
	Length.Currency_SellGrossPL = 8;
	Length.Currency_BuySize = 8;
	Length.Currency_BuyGrossPL = 8;
	Length.Currency_NetSize = 8;
	Length.Currency_NetGrossPL = 8;
end


function SetupLayout()
	-- Accounts
	Paint.Accounts_xAccountName = Length.ColumnSpacing + (Length.Accounts_AccountName * Length.CharacterSpacing);
	Paint.Accounts_xNickname = Length.ColumnSpacing + (Length.Accounts_Nickname * Length.CharacterSpacing) + Paint.Accounts_xAccountName;
	Paint.Accounts_xEquity = Length.ColumnSpacing + (Length.Accounts_Equity * Length.CharacterSpacing) + Paint.Accounts_xNickname;
	Paint.Accounts_xAmount = Length.ColumnSpacing + (Length.Accounts_Amount * Length.CharacterSpacing) + Paint.Accounts_xEquity;
	Paint.Accounts_xSize = Length.ColumnSpacing + (Length.Accounts_Size * Length.CharacterSpacing) + Paint.Accounts_xAmount;
	Paint.Accounts_xLeverage = Length.ColumnSpacing + (Length.Accounts_Leverage * Length.CharacterSpacing) + Paint.Accounts_xSize;
	Paint.Accounts_xGrossPL = Length.ColumnSpacing + (Length.Accounts_GrossPL * Length.CharacterSpacing) + Paint.Accounts_xLeverage;
	Paint.Accounts_xGrossPLp = Length.ColumnSpacing + (Length.Accounts_GrossPLp * Length.CharacterSpacing) + Paint.Accounts_xGrossPL;
	Paint.Accounts_xDayPL = Length.ColumnSpacing + (Length.Accounts_DayPL * Length.CharacterSpacing) + Paint.Accounts_xGrossPLp;
	Paint.Accounts_xDayPLp = Length.ColumnSpacing + (Length.Accounts_DayPLp * Length.CharacterSpacing) + Paint.Accounts_xDayPL;
	Paint.Accounts_xUsedMargin = Length.ColumnSpacing + (Length.Accounts_UsedMargin * Length.CharacterSpacing) + Paint.Accounts_xDayPLp;
	Paint.Accounts_xBaseUnit = Length.ColumnSpacing + (Length.Accounts_BaseUnit * Length.CharacterSpacing) + Paint.Accounts_xUsedMargin;
	
	-- Trades
	Paint.Trades_xAccountName = Length.ColumnSpacing + (Length.Trades_AccountName * Length.CharacterSpacing);
	Paint.Trades_xSymbol = Length.ColumnSpacing + (Length.Trades_Symbol * Length.CharacterSpacing) + Paint.Trades_xAccountName;
	Paint.Trades_xBase = Length.ColumnSpacing + (Length.Trades_Base * Length.CharacterSpacing) + Paint.Trades_xSymbol;
	Paint.Trades_xCounter = Length.ColumnSpacing + (Length.Trades_Counter * Length.CharacterSpacing) + Paint.Trades_xBase;
	Paint.Trades_xAmount = Length.ColumnSpacing + (Length.Trades_Amount * Length.CharacterSpacing) + Paint.Trades_xCounter;
	Paint.Trades_xSize = Length.ColumnSpacing + ( Length.Trades_Size * Length.CharacterSpacing) + Paint.Trades_xAmount;
	Paint.Trades_xDirection = Length.ColumnSpacing + (Length.Trades_Direction * Length.CharacterSpacing) + Paint.Trades_xSize;
	Paint.Trades_xPL = Length.ColumnSpacing + (Length.Trades_PL * Length.CharacterSpacing) + Paint.Trades_xDirection;
	Paint.Trades_xGrossPL = Length.ColumnSpacing + (Length.Trades_GrossPL * Length.CharacterSpacing) + Paint.Trades_xPL;
	Paint.Trades_xRoll = Length.ColumnSpacing + (Length.Trades_Roll * Length.CharacterSpacing) + Paint.Trades_xGrossPL;
	Paint.Trades_xComm = Length.ColumnSpacing + (Length.Trades_Comm * Length.CharacterSpacing) + Paint.Trades_xRoll;
	Paint.Trades_xOpenTime = Length.ColumnSpacing + (Length.Trades_OpenTime * Length.CharacterSpacing) + Paint.Trades_xComm;
	Paint.Trades_xOpenRate = Length.ColumnSpacing + (Length.Trades_OpenRate * Length.CharacterSpacing) + Paint.Trades_xOpenTime;
	Paint.Trades_xOpenDuration = Length.ColumnSpacing + (Length.Trades_OpenDuration * Length.CharacterSpacing) + Paint.Trades_xOpenRate;
	Paint.Trades_xCloseRate = Length.ColumnSpacing + (Length.Trades_AccountName * Length.CharacterSpacing) + Paint.Trades_xOpenDuration;
	Paint.Trades_xUsedMargin = Length.ColumnSpacing + (Length.Trades_UsedMargin * Length.CharacterSpacing) + Paint.Trades_xCloseRate;
	
	-- Closed Trades
	Paint.ClosedTrades_xAccountName = Length.ColumnSpacing + (Length.ClosedTrades_AccountName * Length.CharacterSpacing);
	Paint.ClosedTrades_xSymbol = Length.ColumnSpacing + (Length.ClosedTrades_Symbol * Length.CharacterSpacing) + Paint.ClosedTrades_xAccountName;
	Paint.ClosedTrades_xBase = Length.ColumnSpacing + (Length.ClosedTrades_Base * Length.CharacterSpacing) + Paint.ClosedTrades_xSymbol;
	Paint.ClosedTrades_xCounter = Length.ColumnSpacing + (Length.ClosedTrades_Counter * Length.CharacterSpacing) + Paint.ClosedTrades_xBase;
	Paint.ClosedTrades_xAmount = Length.ColumnSpacing + (Length.ClosedTrades_Amount * Length.CharacterSpacing) + Paint.ClosedTrades_xCounter;
	Paint.ClosedTrades_xSize = Length.ColumnSpacing + ( Length.ClosedTrades_Size * Length.CharacterSpacing) + Paint.ClosedTrades_xAmount;
	Paint.ClosedTrades_xDirection = Length.ColumnSpacing + (Length.ClosedTrades_Direction * Length.CharacterSpacing) + Paint.ClosedTrades_xSize;
	Paint.ClosedTrades_xPL = Length.ColumnSpacing + (Length.ClosedTrades_PL * Length.CharacterSpacing) + Paint.ClosedTrades_xDirection;
	Paint.ClosedTrades_xGrossPL = Length.ColumnSpacing + (Length.ClosedTrades_GrossPL * Length.CharacterSpacing) + Paint.ClosedTrades_xPL;
	Paint.ClosedTrades_xRoll = Length.ColumnSpacing + (Length.ClosedTrades_Roll * Length.CharacterSpacing) + Paint.ClosedTrades_xGrossPL;
	Paint.ClosedTrades_xComm = Length.ColumnSpacing + (Length.ClosedTrades_Comm * Length.CharacterSpacing) + Paint.ClosedTrades_xRoll;
	Paint.ClosedTrades_xOpenTime = Length.ColumnSpacing + (Length.ClosedTrades_OpenTime * Length.CharacterSpacing) + Paint.ClosedTrades_xComm;
	Paint.ClosedTrades_xOpenRate = Length.ColumnSpacing + (Length.ClosedTrades_OpenRate * Length.CharacterSpacing) + Paint.ClosedTrades_xOpenTime;
	Paint.ClosedTrades_xOpenDuration = Length.ColumnSpacing + (Length.ClosedTrades_OpenDuration * Length.CharacterSpacing) + Paint.ClosedTrades_xOpenRate;
	Paint.ClosedTrades_xCloseTime = Length.ColumnSpacing + (Length.ClosedTrades_CloseTime * Length.CharacterSpacing) + Paint.ClosedTrades_xOpenDuration;
	Paint.ClosedTrades_xCloseRate = Length.ColumnSpacing + (Length.ClosedTrades_AccountName * Length.CharacterSpacing) + Paint.ClosedTrades_xCloseTime;
	Paint.ClosedTrades_xUsedMargin = Length.ColumnSpacing + (Length.ClosedTrades_UsedMargin * Length.CharacterSpacing) + Paint.ClosedTrades_xCloseRate;
	
	-- Summary
	Paint.Summary_xSymbol = Length.ColumnSpacing + (Length.Summary_Symbol * Length.CharacterSpacing);
	Paint.Summary_xSellAmount = Length.ColumnSpacing + (Length.Summary_SellAmount * Length.CharacterSpacing) + Paint.Summary_xSymbol;
	Paint.Summary_xSellAvgOpen = Length.ColumnSpacing + (Length.Summary_SellAvgOpen * Length.CharacterSpacing) + Paint.Summary_xSellAmount;
	Paint.Summary_xSellNetPL = Length.ColumnSpacing + (Length.Summary_SellNetPL * Length.CharacterSpacing) + Paint.Summary_xSellAvgOpen;
	Paint.Summary_xBuyAmount = Length.ColumnSpacing + (Length.Summary_BuyAmount * Length.CharacterSpacing) + Paint.Summary_xSellNetPL;
	Paint.Summary_xBuyAvgOpen = Length.ColumnSpacing + (Length.Summary_BuyAvgOpen * Length.CharacterSpacing) + Paint.Summary_xBuyAmount;
	Paint.Summary_xBuyNetPL = Length.ColumnSpacing + (Length.Summary_BuyNetPL * Length.CharacterSpacing) + Paint.Summary_xBuyAvgOpen;
	Paint.Summary_xAmount = Length.ColumnSpacing + (Length.Summary_Amount * Length.CharacterSpacing) + Paint.Summary_xBuyNetPL;
	Paint.Summary_xNetPL = Length.ColumnSpacing + (Length.Summary_NetPL * Length.CharacterSpacing) + Paint.Summary_xAmount;
	
	-- Currency
	Paint.Currency_xSymbol = Length.ColumnSpacing + (Length.Currency_Symbol * Length.CharacterSpacing);
	Paint.Currency_xSellSize = Length.ColumnSpacing + (Length.Currency_SellSize * Length.CharacterSpacing) + Paint.Currency_xSymbol;
	Paint.Currency_xSellGrossPL = Length.ColumnSpacing + (Length.Currency_SellGrossPL * Length.CharacterSpacing) + Paint.Currency_xSellSize;
	Paint.Currency_xBuySize = Length.ColumnSpacing + (Length.Currency_BuySize * Length.CharacterSpacing) + Paint.Currency_xSellGrossPL;
	Paint.Currency_xBuyGrossPL = Length.ColumnSpacing + (Length.Currency_BuyGrossPL * Length.CharacterSpacing) + Paint.Currency_xBuySize;
	Paint.Currency_xNetSize = Length.ColumnSpacing + (Length.Currency_NetSize * Length.CharacterSpacing) + Paint.Currency_xBuyGrossPL;
	Paint.Currency_xNetGrossPL = Length.ColumnSpacing + (Length.Currency_NetGrossPL * Length.CharacterSpacing) + Paint.Currency_xNetSize;
	
	-- Overall
	Length.Accounts = Paint.Accounts_xBaseUnit + 10;
	Length.Trades = Paint.Trades_xUsedMargin + 10;
	Length.ClosedTrades = Paint.ClosedTrades_xUsedMargin + 10;
	Length.Summary = Paint.Summary_xNetPL + 10;
	Length.Currency = Paint.Currency_xNetGrossPL + 10;
end


function FormatStringToFinancial(decimals, text)
	return string.format("%." .. decimals .. "f", text);
end


function FormatStringToPercentage(decimals, text)
	return string.format("%." .. decimals .. "f", text).. "%";
end


function FormatStringToNumber(decimals, text)
	return string.format("%." .. decimals .. "f", text);
end


function FormatStringToDateTime(date)
	local DateTime = core.dateToTable(date);
	string.format("%04i%02i%02i%02i%02i", DateTime.year, DateTime.month, DateTime.day, DateTime.hour, DateTime.min);
	if DateTime.month < 10 then DateTime.month = 0 .. DateTime.month end
	if DateTime.day < 10 then DateTime.day = 0 .. DateTime.day end
	if DateTime.hour < 10 then DateTime.hour = 0 .. DateTime.hour end
	if DateTime.min < 10 then DateTime.min = 0 .. DateTime.min end
	return DateTime.month .. "/" .. DateTime.day .. "/" .. DateTime.year .. " " .. DateTime.hour .. ":" .. DateTime.min;
end


function FormatStringToDateTimeDiffClosed(date1, date2)
    local t = core.dateToTable(date1);
	local j = core.dateToTable(date2);
    DateCalculate1 = string.format("%04i%02i%02i%02i%02i%02i", t.year, t.month, t.day, t.hour, t.min);
    DateCalculate2 = string.format("%04i%02i%02i%02i%02i%02i", j.year, j.month, j.day, j.hour, j.min);
	return FormatSecondsToTime(os.difftime(DateCalculate1, DateCalculate2));
end

function FormatStringToDateTimeDiffOpen(date)
    local t = core.dateToTable(date);
    DateCalculate = string.format("%04i%02i%02i%02i%02i", t.year, t.month, t.day, t.hour, t.min);
	
	return FormatSecondsToTime(os.difftime(os.time(), DateCalculate));
end


function FormatStringToTime(time)
	return time;
end


function FormatSecondsToTime(seconds)
	local t = {};
	if seconds == 0 then
		return "00d 00m 00d 00s";
	else
		t.days = string.format("%02.f", math.floor(seconds / 86400));
		t.hours = string.format("%02.f", math.floor((seconds / 3600) - (t.days * 24)));
		t.mins = string.format("%02.f", math.floor((seconds / 60) - (t.days * 1440) - (t.hours * 60)));
		return t.days .. "d ".. t.hours.."h ".. t.mins.."m "
	end
end

function ConvertBaseToUSD (base, amount)
	local SizeInUSD = 0;
	if base == "EUR" then SizeInUSD = amount * Host:findTable("offers"):find("Instrument", "EUR/USD").Bid;
	elseif base == "USD" then SizeInUSD = amount;
	elseif base == "GBP" then SizeInUSD = amount * Host:findTable("offers"):find("Instrument", "GBP/USD").Bid;
	elseif base == "AUD" then SizeInUSD = amount * Host:findTable("offers"):find("Instrument", "AUD/USD").Bid;
	elseif base == "NZD" then SizeInUSD = amount * Host:findTable("offers"):find("Instrument", "NZD/USD").Bid;
	elseif base == "CAD" then SizeInUSD = amount * (1 / Host:findTable("offers"):find("Instrument", "USD/CAD").Bid);
	elseif base == "CHF" then SizeInUSD = amount * (1 / Host:findTable("offers"):find("Instrument", "USD/CHF").Bid);
	elseif base == "HKD" then SizeInUSD = amount * (1 / Host:findTable("offers"):find("Instrument", "USD/HKD").Bid);
	elseif base == "JPY" then SizeInUSD = amount * (1 / Host:findTable("offers"):find("Instrument", "USD/JPY").Bid);
	elseif base == "NOK" then SizeInUSD = amount * (1 / Host:findTable("offers"):find("Instrument", "USD/NOK").Bid);
	elseif base == "SEK" then SizeInUSD = amount * (1 / Host:findTable("offers"):find("Instrument", "USD/SEK").Bid);
	elseif base == "SGD" then SizeInUSD = amount * (1 / Host:findTable("offers"):find("Instrument", "USD/SGD").Bid);
	elseif base == "TRY" then SizeInUSD = amount * (1 / Host:findTable("offers"):find("Instrument", "USD/TRY").Bid);
	elseif base == "ZAR" then SizeInUSD = amount * (1 / Host:findTable("offers"):find("Instrument", "USD/ZAR").Bid);
	end
	return FormatStringToFinancial(0, SizeInUSD);
end


function ConvertToCurrency (base, counter, amount, direction, grosspl)
	grosspl = FormatStringToNumber(2, grosspl);
	if direction == "Short" then
		if base == "EUR" then
			Currency[1][1] = Currency[1][1] + ConvertBaseToUSD(base, amount);
			Currency[4][1] = Currency[4][1] + grosspl;
		elseif base == "USD" then
			Currency[1][2] = Currency[1][2] + ConvertBaseToUSD(base, amount);
			Currency[4][2] = Currency[4][2] + grosspl;
		elseif base == "GBP" then
			Currency[1][3] = Currency[1][3] + ConvertBaseToUSD(base, amount);
			Currency[4][3] = Currency[4][3] + grosspl;
		elseif base == "AUD" then
			Currency[1][4] = Currency[1][4] + ConvertBaseToUSD(base, amount);
			Currency[4][4] = Currency[4][4] + grosspl;
		elseif base == "NZD" then
			Currency[1][5] = Currency[1][5] + ConvertBaseToUSD(base, amount);
			Currency[4][5] = Currency[4][5] + grosspl;
		elseif base == "CAD" then
			Currency[1][6] = Currency[1][6] + ConvertBaseToUSD(base, amount);
			Currency[4][6] = Currency[4][6] + grosspl;
		elseif base == "CHF" then
			Currency[1][7] = Currency[1][7] + ConvertBaseToUSD(base, amount);
			Currency[4][7] = Currency[4][7] + grosspl;
		elseif base == "HKD" then
			Currency[1][8] = Currency[1][8] + ConvertBaseToUSD(base, amount);
			Currency[4][8] = Currency[4][8] + grosspl;
		elseif base == "JPY" then
			Currency[1][9] = Currency[1][9] + ConvertBaseToUSD(base, amount);
			Currency[4][9] = Currency[4][9] + grosspl;
		elseif base == "NOK" then
			Currency[1][10] = Currency[1][10] + ConvertBaseToUSD(base, amount);
			Currency[4][10] = Currency[4][10] + grosspl;
		elseif base == "SEK" then
			Currency[1][11] = Currency[1][11] + ConvertBaseToUSD(base, amount);
			Currency[4][11] = Currency[4][11] + grosspl;
		elseif base == "SGD" then
			Currency[1][12] = Currency[1][12] + ConvertBaseToUSD(base, amount);
			Currency[4][12] = Currency[4][12] + grosspl;
		elseif base == "TRY" then
			Currency[1][13] = Currency[1][13] + ConvertBaseToUSD(base, amount);
			Currency[4][13] = Currency[4][13] + grosspl;
		elseif base == "ZAR" then
			Currency[1][14] = Currency[1][14] + ConvertBaseToUSD(base, amount);
			Currency[4][14] = Currency[4][14] + grosspl;
		end
		Currency[1][15] = Currency[1][15] + ConvertBaseToUSD(base, amount);
		Currency[4][15] = Currency[4][15] + grosspl;
		
		if counter == "EUR" then
			Currency[2][1] = Currency[2][1] + ConvertBaseToUSD(base, amount);
			Currency[5][1] = Currency[5][1] + grosspl;
		elseif counter == "USD" then
			Currency[2][2] = Currency[2][2] + ConvertBaseToUSD(base, amount);
			Currency[5][2] = Currency[5][2] + grosspl;
		elseif counter == "GBP" then
			Currency[2][3] = Currency[2][3] + ConvertBaseToUSD(base, amount);
			Currency[5][3] = Currency[5][3] + grosspl;
		elseif counter == "AUD" then
			Currency[2][4] = Currency[2][4] + ConvertBaseToUSD(base, amount);
			Currency[5][4] = Currency[5][4] + grosspl;
		elseif counter == "NZD" then
			Currency[2][5] = Currency[2][5] + ConvertBaseToUSD(base, amount);
			Currency[5][5] = Currency[5][5] + grosspl;
		elseif counter == "CAD" then
			Currency[2][6] = Currency[2][6] + ConvertBaseToUSD(base, amount);
			Currency[5][6] = Currency[5][6] + grosspl;
		elseif counter == "CHF" then
			Currency[2][7] = Currency[2][7] + ConvertBaseToUSD(base, amount);
			Currency[5][7] = Currency[5][7] + grosspl;
		elseif counter == "HKD" then
			Currency[2][8] = Currency[2][8] + ConvertBaseToUSD(base, amount);
			Currency[5][8] = Currency[5][8] + grosspl;
		elseif counter == "JPY" then
			Currency[2][9] = Currency[2][9] + ConvertBaseToUSD(base, amount);
			Currency[5][9] = Currency[5][9] + grosspl;
		elseif counter == "NOK" then
			Currency[2][10] = Currency[2][10] + ConvertBaseToUSD(base, amount);
			Currency[5][10] = Currency[5][10] + grosspl;
		elseif counter == "SEK" then
			Currency[2][11] = Currency[2][11] + ConvertBaseToUSD(base, amount);
			Currency[5][11] = Currency[5][11] + grosspl;
		elseif counter == "SGD" then
			Currency[2][12] = Currency[2][12] + ConvertBaseToUSD(base, amount);
			Currency[5][12] = Currency[5][12] + grosspl;
		elseif counter == "TRY" then
			Currency[2][13] = Currency[2][13] + ConvertBaseToUSD(base, amount);
			Currency[5][13] = Currency[5][13] + grosspl;
		elseif counter == "ZAR" then
			Currency[2][14] = Currency[2][14] + ConvertBaseToUSD(base, amount);
			Currency[5][14] = Currency[5][14] + grosspl;
		end
		Currency[2][15] = Currency[2][15] + ConvertBaseToUSD(base, amount);
		Currency[5][15] = Currency[5][15] + grosspl;
	else 
		if counter == "EUR" then
			Currency[1][1] = Currency[1][1] + ConvertBaseToUSD(base, amount);
			Currency[4][1] = Currency[4][1] + grosspl;
		elseif counter == "USD" then
			Currency[1][2] = Currency[1][2] + ConvertBaseToUSD(base, amount);
			Currency[4][2] = Currency[4][2] + grosspl;
		elseif counter == "GBP" then
			Currency[1][3] = Currency[1][3] + ConvertBaseToUSD(base, amount);
			Currency[4][3] = Currency[4][3] + grosspl;
		elseif counter == "AUD" then
			Currency[1][4] = Currency[1][4] + ConvertBaseToUSD(base, amount);
			Currency[4][4] = Currency[4][4] + grosspl;
		elseif counter == "NZD" then
			Currency[1][5] = Currency[1][5] + ConvertBaseToUSD(base, amount);
			Currency[4][5] = Currency[4][5] + grosspl;
		elseif counter == "CAD" then
			Currency[1][6] = Currency[1][6] + ConvertBaseToUSD(base, amount);
			Currency[4][6] = Currency[4][6] + grosspl;
		elseif counter == "CHF" then
			Currency[1][7] = Currency[1][7] + ConvertBaseToUSD(base, amount);
			Currency[4][7] = Currency[4][7] + grosspl;
		elseif counter == "HKD" then
			Currency[1][8] = Currency[1][8] + ConvertBaseToUSD(base, amount);
			Currency[4][8] = Currency[4][8] + grosspl;
		elseif counter == "JPY" then
			Currency[1][9] = Currency[1][9] + ConvertBaseToUSD(base, amount);
			Currency[4][9] = Currency[4][9] + grosspl;
		elseif counter == "NOK" then
			Currency[1][10] = Currency[1][10] + ConvertBaseToUSD(base, amount);
			Currency[4][10] = Currency[4][10] + grosspl;
		elseif counter == "SEK" then
			Currency[1][11] = Currency[1][11] + ConvertBaseToUSD(base, amount);
			Currency[4][11] = Currency[4][11] + grosspl;
		elseif counter == "SGD" then
			Currency[1][12] = Currency[1][12] + ConvertBaseToUSD(base, amount);
			Currency[4][12] = Currency[4][12] + grosspl;
		elseif counter == "TRY" then
			Currency[1][13] = Currency[1][13] + ConvertBaseToUSD(base, amount);
			Currency[4][13] = Currency[4][13] + grosspl;
		elseif counter == "ZAR" then
			Currency[1][14] = Currency[1][14] + ConvertBaseToUSD(base, amount);
			Currency[4][14] = Currency[4][14] + grosspl;
		end
		Currency[1][15] = Currency[1][15] + ConvertBaseToUSD(base, amount);
		Currency[4][15] = Currency[4][15] + grosspl;
		
		if base == "EUR" then
			Currency[2][1] = Currency[2][1] + ConvertBaseToUSD(base, amount);
			Currency[5][1] = Currency[5][1] + grosspl;
		elseif base == "USD" then
			Currency[2][2] = Currency[2][2] + ConvertBaseToUSD(base, amount);
			Currency[5][2] = Currency[5][2] + grosspl;
		elseif base == "GBP" then
			Currency[2][3] = Currency[2][3] + ConvertBaseToUSD(base, amount);
			Currency[5][3] = Currency[5][3] + grosspl;
		elseif base == "AUD" then
			Currency[2][4] = Currency[2][4] + ConvertBaseToUSD(base, amount);
			Currency[5][4] = Currency[5][4] + grosspl;
		elseif base == "NZD" then
			Currency[2][5] = Currency[2][5] + ConvertBaseToUSD(base, amount);
			Currency[5][5] = Currency[5][5] + grosspl;
		elseif base == "CAD" then
			Currency[2][6] = Currency[2][6] + ConvertBaseToUSD(base, amount);
			Currency[5][6] = Currency[5][6] + grosspl;
		elseif base == "CHF" then
			Currency[2][7] = Currency[2][7] + ConvertBaseToUSD(base, amount);
			Currency[5][7] = Currency[5][7] + grosspl;
		elseif base == "HKD" then
			Currency[2][8] = Currency[2][8] + ConvertBaseToUSD(base, amount);
			Currency[5][8] = Currency[5][8] + grosspl;
		elseif base == "JPY" then
			Currency[2][9] = Currency[2][9] + ConvertBaseToUSD(base, amount);
			Currency[5][9] = Currency[5][9] + grosspl;
		elseif base == "NOK" then
			Currency[2][10] = Currency[2][10] + ConvertBaseToUSD(base, amount);
			Currency[5][10] = Currency[5][10] + grosspl;
		elseif base == "SEK" then
			Currency[2][11] = Currency[2][11] + ConvertBaseToUSD(base, amount);
			Currency[5][11] = Currency[5][11] + grosspl;
		elseif base == "SGD" then
			Currency[2][12] = Currency[2][12] + ConvertBaseToUSD(base, amount);
			Currency[5][12] = Currency[5][12] + grosspl;
		elseif base == "TRY" then
			Currency[2][13] = Currency[2][13] + ConvertBaseToUSD(base, amount);
			Currency[5][13] = Currency[5][13] + grosspl;
		elseif base == "ZAR" then
			Currency[2][14] = Currency[2][14] + ConvertBaseToUSD(base, amount);
			Currency[5][14] = Currency[5][14] + grosspl;
		end
		Currency[2][15] = Currency[2][15] + ConvertBaseToUSD(base, amount);
		Currency[5][15] = Currency[5][15] + grosspl;
	end
end


function AccountHelper(accountname, amount, size)
	for i = 1, Accounts.Count do
		if AccountsNames[i] == accountname then
			AccountsAmount[i] = FormatStringToFinancial(0, AccountsAmount[i] + amount);
			AccountsSize[i] = FormatStringToNumber(0, AccountsSize[i] + size);
			AccountsLeverage[i] = FormatStringToNumber(2, AccountsSize[i] / AccountsEquity[i]);
			Accounts.AmountSum = FormatStringToFinancial(0, Accounts.AmountSum + amount);
			Accounts.SizeSum = FormatStringToNumber(0, Accounts.SizeSum + size);
			Accounts.LeverageSum = FormatStringToNumber(2, Accounts.SizeSum / Accounts.EquitySum);
		end
	end
end


function Update(period)


end


function Draw(stage, context)
	if stage == 2 then
		if not Paint.Setup then
			-- Title GUI
			context:createFont (1, "Consolas", 0, context:pointsToPixels (12), context.BOLD);
			context:createSolidBrush (2, Paint.TitleBackgroundColor);
			
			-- Headings GUI
			context:createFont (3, "Consolas", 0, context:pointsToPixels (9), 0);
			context:createSolidBrush (4, Paint.SectionBackgroundColor);
			
			-- Row GUI
			context:createFont (5, "Consolas", 0, context:pointsToPixels (9), 0);
			context:createSolidBrush (6, Paint.RowBackgroundColor);
			
			-- Total Row GUI
			context:createSolidBrush (7, Paint.TotalRowBackgroundColor);
			
			-- Chart Background GUI
			context:createSolidBrush (8, Paint.ChartBackground);

			Paint.Setup = true;
		end
		
		-- Chart Background
		context:drawRectangle (-1, 8, 0, 0, 2000, 2000, 0);
		
		----------------------------------------
		-- Accounts Section
		----------------------------------------
		Paint.yAccountTitle = Length.TopSpacing;
		Paint.yAccountTitleEnd = Paint.yAccountTitle + Length.TitleSpacing;
		Paint.yAccountSection = Paint.yAccountTitle + Length.TitleSpacing;
		Paint.yAccountSectionEnd = Paint.yAccountSection + Length.SectionSpacing;
		
		Paint.yAccountRow = Paint.yAccountSection + Length.SectionSpacing;
		Paint.yAccountRowEnd = Paint.yAccountRow + Length.RowSpacing;
		Paint.yAccountRowHelper = Paint.yAccountSection + Length.SectionSpacing;
		Paint.yAccountRowEndHelper = Paint.yAccountRow + Length.RowSpacing;
		Accounts.Count = 0;
		
		if Display.Accounts == "Show" then
			-- Accounts Headings
			context:drawRectangle (-1, 4, 0, Paint.yAccountSection, Length.Accounts, Paint.yAccountSectionEnd, 0);
			context:drawText (3, "Account", Paint.SectionTextColor, -1, 0, Paint.yAccountSection, Paint.Accounts_xAccountName, Paint.yAccountSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Nickname", Paint.SectionTextColor, -1, 0, Paint.yAccountSection, Paint.Accounts_xNickname, Paint.yAccountSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Equity", Paint.SectionTextColor, -1, 0, Paint.yAccountSection, Paint.Accounts_xEquity, Paint.yAccountSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Amount", Paint.SectionTextColor, -1, 0, Paint.yAccountSection, Paint.Accounts_xAmount, Paint.yAccountSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Size", Paint.SectionTextColor, -1, 0, Paint.yAccountSection, Paint.Accounts_xSize, Paint.yAccountSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Leverage", Paint.SectionTextColor, -1, 0, Paint.yAccountSection, Paint.Accounts_xLeverage, Paint.yAccountSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Gross P/L", Paint.SectionTextColor, -1, 0, Paint.yAccountSection, Paint.Accounts_xGrossPL, Paint.yAccountSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Gross P/L %", Paint.SectionTextColor, -1, 0, Paint.yAccountSection, Paint.Accounts_xGrossPLp, Paint.yAccountSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Day P/L", Paint.SectionTextColor, -1, 0, Paint.yAccountSection, Paint.Accounts_xDayPL, Paint.yAccountSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Day P/L %", Paint.SectionTextColor, -1, 0, Paint.yAccountSection, Paint.Accounts_xDayPLp, Paint.yAccountSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Margin", Paint.SectionTextColor, -1, 0, Paint.yAccountSection, Paint.Accounts_xUsedMargin, Paint.yAccountSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Base Unit", Paint.SectionTextColor, -1, 0, Paint.yAccountSection, Paint.Accounts_xBaseUnit, Paint.yAccountSectionEnd, context.RIGHT+context.VCENTER, 0);
			
			Accounts.Table = Host:findTable("accounts"):enumerator();
			Accounts.Row = Accounts.Table:next();
			Accounts.EquitySum = 0;
			Accounts.AmountSum = 0;
			Accounts.SizeSum = 0;
			Accounts.LeverageSum = 0;
			Accounts.UsedMarginSum = 0;
			Accounts.GrossPLSum = 0;
			Accounts.GrossPLpSum = 0;
			Accounts.DayPLSum = 0;
			Accounts.DayPLpSum = 0;
			while Accounts.Row ~= nil do
				--  Accounts Rows
				Accounts.Count = Accounts.Count + 1;
				Accounts.AccountName = Accounts.Row.AccountName;
				AccountsNames[Accounts.Count] = Accounts.AccountName;
				Accounts.Nickname = Nicknames[Accounts.Count];
				Accounts.EquitySum = FormatStringToFinancial(0, Accounts.EquitySum + Accounts.Row.Equity);
				Accounts.Equity = FormatStringToFinancial(0, Accounts.Row.Equity);
				AccountsEquity[Accounts.Count] = Accounts.Equity;
				Accounts.GrossPLSum = FormatStringToFinancial(2, Accounts.GrossPLSum + Accounts.Row.GrossPL);
				Accounts.GrossPL = FormatStringToFinancial(2, Accounts.Row.GrossPL);
				Accounts.GrossPLpSum = FormatStringToPercentage(2, Accounts.GrossPLSum / Accounts.EquitySum * 100);
				Accounts.GrossPLp = FormatStringToPercentage(2, Accounts.GrossPL / Accounts.Equity * 100);
				Accounts.DayPLSum = FormatStringToFinancial(2, Accounts.DayPLSum + Accounts.Row.DayPL);
				Accounts.DayPL = FormatStringToFinancial(2, Accounts.Row.DayPL);
				Accounts.DayPLpSum = FormatStringToPercentage(2, Accounts.DayPLSum / Accounts.EquitySum * 100);
				Accounts.DayPLp = FormatStringToPercentage(2, Accounts.DayPL / Accounts.Equity * 100);
				Accounts.UsedMarginSum = FormatStringToFinancial(2, Accounts.UsedMarginSum + Accounts.Row.UsedMargin);
				Accounts.UsedMargin = FormatStringToFinancial(2, Accounts.Row.UsedMargin);
				Accounts.BaseUnit = Host:execute("getTradingProperty", "baseUnitSize", "EUR/USD", Accounts.Row.AccountID);
				
				if (Accounts.Count % 2 == 0) then context:drawRectangle (-1, 6, 0, Paint.yAccountRow, Length.Accounts, Paint.yAccountRowEnd, 0) end
				context:drawText (5, Accounts.AccountName, Paint.RowTextColor, -1, 0, Paint.yAccountRow, Paint.Accounts_xAccountName, Paint.yAccountRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, Accounts.Nickname, Paint.RowTextColor, -1, 0, Paint.yAccountRow, Paint.Accounts_xNickname, Paint.yAccountRowEnd, context.RIGHT+context.VCENTER, 0);
				if not Display.Public then context:drawText (5, Accounts.Equity, Paint.RowTextColor, -1, 0, Paint.yAccountRow, Paint.Accounts_xEquity, Paint.yAccountRowEnd, context.RIGHT+context.VCENTER, 0) end
				if not Display.Public then context:drawText (5, Accounts.GrossPL, Paint.RowTextColor, -1, 0, Paint.yAccountRow, Paint.Accounts_xGrossPL, Paint.yAccountRowEnd, context.RIGHT+context.VCENTER, 0) end
				if not Display.Public then context:drawText (5, Accounts.GrossPLp, Paint.RowTextColor, -1, 0, Paint.yAccountRow, Paint.Accounts_xGrossPLp, Paint.yAccountRowEnd, context.RIGHT+context.VCENTER, 0) end
				if not Display.Public then context:drawText (5, Accounts.DayPL, Paint.RowTextColor, -1, 0, Paint.yAccountRow, Paint.Accounts_xDayPL, Paint.yAccountRowEnd, context.RIGHT+context.VCENTER, 0) end
				if not Display.Public then context:drawText (5, Accounts.DayPLp, Paint.RowTextColor, -1, 0, Paint.yAccountRow, Paint.Accounts_xDayPLp, Paint.yAccountRowEnd, context.RIGHT+context.VCENTER, 0) end
				if not Display.Public then context:drawText (5, Accounts.UsedMargin, Paint.RowTextColor, -1, 0, Paint.yAccountRow, Paint.Accounts_xUsedMargin, Paint.yAccountRowEnd, context.RIGHT+context.VCENTER, 0) end
				context:drawText (5, Accounts.BaseUnit, Paint.RowTextColor, -1, 0, Paint.yAccountRow, Paint.Accounts_xBaseUnit, Paint.yAccountRowEnd, context.RIGHT+context.VCENTER, 0);
				
				Paint.yAccountRow = Paint.yAccountRow + Length.RowSpacing;
				Paint.yAccountRowEnd = Paint.yAccountRow + Length.RowSpacing;
				Accounts.Row = Accounts.Table:next();
			end
			if Accounts.Count > 0 then
				-- Accounts Total Rows
				context:drawRectangle (-1, 7, 0, Paint.yAccountRow, Length.Accounts, Paint.yAccountRowEnd, 0)
				if not Display.Public then context:drawText (5, Accounts.EquitySum, Paint.TotalRowText, -1, 0, Paint.yAccountRow,  Paint.Accounts_xEquity, Paint.yAccountRowEnd, context.RIGHT+context.VCENTER, 0) end
				if not Display.Public then context:drawText (5, Accounts.GrossPLSum, Paint.TotalRowText, -1, 0, Paint.yAccountRow, Paint.Accounts_xGrossPL, Paint.yAccountRowEnd, context.RIGHT+context.VCENTER, 0) end
				if not Display.Public then context:drawText (5, Accounts.GrossPLpSum, Paint.TotalRowText, -1, 0, Paint.yAccountRow, Paint.Accounts_xGrossPLp, Paint.yAccountRowEnd, context.RIGHT+context.VCENTER, 0) end
				if not Display.Public then context:drawText (5, Accounts.DayPLSum, Paint.TotalRowText, -1, 0, Paint.yAccountRow, Paint.Accounts_xDayPL, Paint.yAccountRowEnd, context.RIGHT+context.VCENTER, 0) end
				if not Display.Public then context:drawText (5, Accounts.DayPLpSum, Paint.TotalRowText, -1, 0, Paint.yAccountRow, Paint.Accounts_xDayPLp, Paint.yAccountRowEnd, context.RIGHT+context.VCENTER, 0) end
				if not Display.Public then context:drawText (5, Accounts.UsedMarginSum, Paint.TotalRowText, -1, 0, Paint.yAccountRow, Paint.Accounts_xUsedMargin, Paint.yAccountRowEnd, context.RIGHT+context.VCENTER, 0) end
			end
			-- Accounts Title
			context:drawRectangle (-1, 2, 0, Paint.yAccountTitle, Length.Accounts, Paint.yAccountTitleEnd, 0);
			context:drawText (1, "Accounts (" .. Accounts.Count .. ")" , Paint.TitleTextColor, -1, Length.ColumnSpacing, Paint.yAccountTitle, Length.Accounts, Paint.yAccountTitleEnd, context.LEFT+context.VCENTER, 0);
			context:drawRectangle (-1, 2, 0, Paint.yAccountRow, Length.Accounts, Paint.yAccountRow + 2, 0);
		else
			Paint.yAccountRow = 0;
		end
		
		----------------------------------------
		-- Trades Section
		----------------------------------------
		Paint.yTradesTitle = Paint.yAccountRow + Length.GapSpacing;
		Paint.yTradesTitleEnd = Paint.yTradesTitle + Length.TitleSpacing;
		Paint.yTradesSection = Paint.yTradesTitle + Length.TitleSpacing;
		Paint.yTradesSectionEnd = Paint.yTradesSection + Length.SectionSpacing;
		
		Paint.yTradesRow = Paint.yTradesSection + Length.SectionSpacing;
		Paint.yTradesRowEnd = Paint.yTradesRow + Length.RowSpacing;
		
		if Display.Trades == "Show" then
			-- Trades Headings
			context:drawRectangle (-1, 4, 0, Paint.yTradesSection, Length.Trades, Paint.yTradesSectionEnd, 0);
			context:drawText (3, "Account", Paint.SectionTextColor, -1, 0, Paint.yTradesSection, Paint.Trades_xAccountName, Paint.yTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Symbol", Paint.SectionTextColor, -1, 0, Paint.yTradesSection, Paint.Trades_xSymbol, Paint.yTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Base", Paint.SectionTextColor, -1, 0, Paint.yTradesSection, Paint.Trades_xBase, Paint.yTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Counter", Paint.SectionTextColor, -1, 0, Paint.yTradesSection, Paint.Trades_xCounter, Paint.yTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Amount", Paint.SectionTextColor, -1, 0, Paint.yTradesSection, Paint.Trades_xAmount, Paint.yTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Size", Paint.SectionTextColor, -1, 0, Paint.yTradesSection, Paint.Trades_xSize, Paint.yTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Direction", Paint.SectionTextColor, -1, 0, Paint.yTradesSection, Paint.Trades_xDirection, Paint.yTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "P/L", Paint.SectionTextColor, -1, 0, Paint.yTradesSection, Paint.Trades_xPL, Paint.yTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Gross P/L", Paint.SectionTextColor, -1, 0, Paint.yTradesSection, Paint.Trades_xGrossPL, Paint.yTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Roll", Paint.SectionTextColor, -1, 0, Paint.yTradesSection, Paint.Trades_xRoll, Paint.yTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Comm", Paint.SectionTextColor, -1, 0, Paint.yTradesSection, Paint.Trades_xComm, Paint.yTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Open Time", Paint.SectionTextColor, -1, 0, Paint.yTradesSection, Paint.Trades_xOpenTime, Paint.yTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Open", Paint.SectionTextColor, -1, 0, Paint.yTradesSection, Paint.Trades_xOpenRate, Paint.yTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Duration", Paint.SectionTextColor, -1, 0, Paint.yTradesSection, Paint.Trades_xOpenDuration, Paint.yTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Close", Paint.SectionTextColor, -1, 0, Paint.yTradesSection, Paint.Trades_xCloseRate, Paint.yTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Margin", Paint.SectionTextColor, -1, 0, Paint.yTradesSection, Paint.Trades_xUsedMargin, Paint.yTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
		
			Trades.Table = Host:findTable("trades"):enumerator();
			Trades.Row = Trades.Table:next();
			Trades.Count = 0;
			Trades.AmountSum = 0;
			Trades.SizeSum = 0;
			Trades.PLSum = 0;
			Trades.CommSum = 0;
			Trades.GrossPLSum = 0;
			Trades.RollSum = 0;
			Trades.UsedMarginSum = 0;
			for i = 1, Accounts.Count do
				AccountsAmount[i] = 0;
				AccountsSize[i] = 0;
				AccountsLeverage[i] = 0;
			end
			for i = 1, 6 do
				Currency[i] = {};
				for j = 1, 15 do
					Currency[i][j] = 0;
				end
			end
			while Trades.Row ~= nil do
				-- Trades Rows
				Trades.Count = Trades.Count + 1;
				Trades.AccountName = Trades.Row.AccountName;
				Trades.Symbol = Trades.Row.Instrument;
				Trades.Base = Host:findTable("offers"):find("Instrument", Trades.Symbol).ContractCurrency;
				Trades.Counter= string.sub(Trades.Symbol, 5)
				Trades.AmountSum = FormatStringToNumber(0, Trades.AmountSum + Trades.Row.Lot);
				Trades.Amount = FormatStringToNumber(0, Trades.Row.Lot);
				Trades.SizeSum = FormatStringToFinancial(0, Trades.SizeSum + ConvertBaseToUSD(Trades.Base, Trades.Amount));
				Trades.Size = FormatStringToFinancial(0, ConvertBaseToUSD(Trades.Base, Trades.Amount));
				if Trades.Row.BS == "B" then
					Trades.Direction = "Long";
					Trades.CloseRate = FormatStringToNumber(Host:findTable("offers"):find("Instrument", Trades.Symbol).Digits, Host:findTable("offers"):find("Instrument", Trades.Symbol).Ask);
				else
					Trades.Direction = "Short";
					Trades.CloseRate = FormatStringToNumber(Host:findTable("offers"):find("Instrument", Trades.Symbol).Digits, Host:findTable("offers"):find("Instrument", Trades.Symbol).Bid);
				end
				Trades.PLSum = FormatStringToNumber(1, Trades.PLSum + Trades.Row.PL);
				Trades.PL = FormatStringToNumber(1, Trades.Row.PL);
				Trades.GrossPLSum = FormatStringToFinancial(2, Trades.GrossPLSum + Trades.Row.GrossPL);
				Trades.GrossPL = FormatStringToFinancial(2, Trades.Row.GrossPL);
				Trades.RollSum = FormatStringToFinancial(2, Trades.RollSum + Trades.Row.Int);
				Trades.Roll = FormatStringToFinancial(2, Trades.Row.Int);
				Trades.CommSum = FormatStringToFinancial(2, Trades.CommSum + (Trades.Row.Com* -1));
				Trades.Comm = FormatStringToFinancial(2, Trades.Row.Com * -1);
				Trades.OpenTime = FormatStringToDateTime(Trades.Row.Time);
				Trades.OpenRate = FormatStringToNumber(Host:findTable("offers"):find("Instrument", Trades.Symbol).Digits, Trades.Row.Open);
				-- Trades.OpenDuration = FormatStringToDateTimeDiffOpen(Trades.Row.Open);
				Trades.UsedMarginSum = FormatStringToFinancial(2, (Trades.UsedMarginSum + (Host:findTable("offers"):find("Instrument", Trades.Symbol).MMR * (Trades.Amount / 1000))));
				Trades.UsedMargin = FormatStringToFinancial(2, (Host:findTable("offers"):find("Instrument", Trades.Symbol).MMR * (Trades.Amount / 1000)));
				if Display.Accounts == "Show" then AccountHelper(Trades.AccountName, Trades.Amount, Trades.Size) end
				ConvertToCurrency (Trades.Base, Trades.Counter, Trades.Amount, Trades.Direction, Trades.GrossPL);
				
				if (Trades.Count % 2 == 0) then context:drawRectangle (-1, 6, 0, Paint.yTradesRow, Length.Trades, Paint.yTradesRowEnd, 0) end
				context:drawText (5, Trades.AccountName, Paint.RowTextColor, -1, 0, Paint.yTradesRow, Paint.Trades_xAccountName, Paint.yTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, Trades.Symbol, Paint.RowTextColor, -1, 0, Paint.yTradesRow, Paint.Trades_xSymbol, Paint.yTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, Trades.Base, Paint.RowTextColor, -1, 0, Paint.yTradesRow, Paint.Trades_xBase, Paint.yTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, Trades.Counter, Paint.RowTextColor, -1, 0, Paint.yTradesRow, Paint.Trades_xCounter, Paint.yTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, Trades.Amount, Paint.RowTextColor, -1, 0, Paint.yTradesRow, Paint.Trades_xAmount, Paint.yTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, Trades.Size, Paint.RowTextColor, -1, 0, Paint.yTradesRow, Paint.Trades_xSize, Paint.yTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, Trades.Direction, Paint.RowTextColor, -1, 0, Paint.yTradesRow, Paint.Trades_xDirection, Paint.yTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, Trades.PL, Paint.RowTextColor, -1, 0, Paint.yTradesRow, Paint.Trades_xPL, Paint.yTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				if not Display.Public then context:drawText (5, Trades.GrossPL, Paint.RowTextColor, -1, 0, Paint.yTradesRow, Paint.Trades_xGrossPL, Paint.yTradesRowEnd, context.RIGHT+context.VCENTER, 0) end
				context:drawText (5, Trades.Roll, Paint.RowTextColor, -1, 0, Paint.yTradesRow, Paint.Trades_xRoll, Paint.yTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, Trades.Comm, Paint.RowTextColor, -1, 0, Paint.yTradesRow, Paint.Trades_xComm, Paint.yTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, Trades.OpenTime, Paint.RowTextColor, -1, 0, Paint.yTradesRow, Paint.Trades_xOpenTime, Paint.yTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, Trades.OpenRate, Paint.RowTextColor, -1, 0, Paint.yTradesRow, Paint.Trades_xOpenRate, Paint.yTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				-- context:drawText (5, Trades.OpenDuration, Paint.RowTextColor, -1, 0, Paint.yTradesRow, Paint.Trades_xOpenDuration, Paint.yTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, Trades.CloseRate, Paint.RowTextColor, -1, 0, Paint.yTradesRow, Paint.Trades_xCloseRate, Paint.yTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, Trades.UsedMargin, Paint.RowTextColor, -1, 0, Paint.yTradesRow, Paint.Trades_xUsedMargin, Paint.yTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				
				Paint.yTradesRow = Paint.yTradesRow + Length.RowSpacing;
				Paint.yTradesRowEnd = Paint.yTradesRow + Length.RowSpacing;
				Trades.Row = Trades.Table:next();
			end
			if Trades.Count > 0 then
				-- Trades Total Rows
				context:drawRectangle (-1, 7, 0, Paint.yTradesRow, Length.Trades, Paint.yTradesRowEnd, 0)
				context:drawText (5, Trades.AmountSum, Paint.TotalRowText, -1, 0, Paint.yTradesRow, Paint.Trades_xAmount, Paint.yTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, Trades.SizeSum, Paint.TotalRowText, -1, 0, Paint.yTradesRow, Paint.Trades_xSize, Paint.yTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, Trades.PLSum, Paint.TotalRowText, -1, 0, Paint.yTradesRow, Paint.Trades_xPL, Paint.yTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				if not Display.Public then context:drawText (5, Trades.GrossPLSum, Paint.TotalRowText, -1, 0, Paint.yTradesRow, Paint.Trades_xGrossPL, Paint.yTradesRowEnd, context.RIGHT+context.VCENTER, 0) end
				context:drawText (5, Trades.RollSum, Paint.TotalRowText, -1, 0, Paint.yTradesRow, Paint.Trades_xRoll, Paint.yTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, Trades.CommSum, Paint.TotalRowText, -1, 0, Paint.yTradesRow, Paint.Trades_xComm, Paint.yTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, Trades.UsedMarginSum, Paint.TotalRowText, -1, 0, Paint.yTradesRow, Paint.Trades_xUsedMargin, Paint.yTradesRowEnd, context.RIGHT+context.VCENTER, 0);
			end
			-- Trades Title
			context:drawRectangle (-1, 2, 0, Paint.yTradesTitle, Length.Trades, Paint.yTradesTitleEnd, 0);
			context:drawText (1, "Open Trades (" .. Trades.Count .. ")" , Paint.TitleTextColor, -1, Length.ColumnSpacing, Paint.yTradesTitle, Length.Trades, Paint.yTradesTitleEnd, context.LEFT+context.VCENTER, 0);
			context:drawRectangle (-1, 2, 0, Paint.yTradesRow, Length.Trades, Paint.yTradesRow + 2, 0);
		else
			Paint.yTradesRow = Paint.yAccountRow;
		end
		
		----------------------------------------
		-- Closed Trades Section
		----------------------------------------
		Paint.yClosedTradesTitle = Paint.yTradesRow + Length.GapSpacing;
		Paint.yClosedTradesTitleEnd = Paint.yClosedTradesTitle + Length.TitleSpacing;
		Paint.yClosedTradesSection = Paint.yClosedTradesTitle + Length.TitleSpacing;
		Paint.yClosedTradesSectionEnd = Paint.yClosedTradesSection + Length.SectionSpacing;
		
		Paint.yClosedTradesRow = Paint.yClosedTradesSection + Length.SectionSpacing;
		Paint.yClosedTradesRowEnd = Paint.yClosedTradesRow + Length.RowSpacing;
		
		if Display.ClosedTrades == "Show" then
			-- Closed Trades Headings
			context:drawRectangle (-1, 4, 0, Paint.yClosedTradesSection, Length.ClosedTrades, Paint.yClosedTradesSectionEnd, 0);
			context:drawText (3, "Account", Paint.SectionTextColor, -1, 0, Paint.yClosedTradesSection, Paint.ClosedTrades_xAccountName, Paint.yClosedTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Symbol", Paint.SectionTextColor, -1, 0, Paint.yClosedTradesSection, Paint.ClosedTrades_xSymbol, Paint.yClosedTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Base", Paint.SectionTextColor, -1, 0, Paint.yClosedTradesSection, Paint.ClosedTrades_xBase, Paint.yClosedTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Counter", Paint.SectionTextColor, -1, 0, Paint.yClosedTradesSection, Paint.ClosedTrades_xCounter, Paint.yClosedTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Amount", Paint.SectionTextColor, -1, 0, Paint.yClosedTradesSection, Paint.ClosedTrades_xAmount, Paint.yClosedTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Size", Paint.SectionTextColor, -1, 0, Paint.yClosedTradesSection, Paint.ClosedTrades_xSize, Paint.yClosedTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Direction", Paint.SectionTextColor, -1, 0, Paint.yClosedTradesSection, Paint.ClosedTrades_xDirection, Paint.yClosedTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "P/L", Paint.SectionTextColor, -1, 0, Paint.yClosedTradesSection, Paint.ClosedTrades_xPL, Paint.yClosedTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Gross P/L", Paint.SectionTextColor, -1, 0, Paint.yClosedTradesSection, Paint.ClosedTrades_xGrossPL, Paint.yClosedTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Roll", Paint.SectionTextColor, -1, 0, Paint.yClosedTradesSection, Paint.ClosedTrades_xRoll, Paint.yClosedTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Comm", Paint.SectionTextColor, -1, 0, Paint.yClosedTradesSection, Paint.ClosedTrades_xComm, Paint.yClosedTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Open Time", Paint.SectionTextColor, -1, 0, Paint.yClosedTradesSection, Paint.ClosedTrades_xOpenTime, Paint.yClosedTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Open", Paint.SectionTextColor, -1, 0, Paint.yClosedTradesSection, Paint.ClosedTrades_xOpenRate, Paint.yClosedTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Duration", Paint.SectionTextColor, -1, 0, Paint.yClosedTradesSection, Paint.ClosedTrades_xOpenDuration, Paint.yClosedTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Close Time", Paint.SectionTextColor, -1, 0, Paint.yClosedTradesSection, Paint.ClosedTrades_xCloseTime, Paint.yClosedTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Close", Paint.SectionTextColor, -1, 0, Paint.yClosedTradesSection, Paint.ClosedTrades_xCloseRate, Paint.yClosedTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Margin", Paint.SectionTextColor, -1, 0, Paint.yClosedTradesSection, Paint.ClosedTrades_xUsedMargin, Paint.yClosedTradesSectionEnd, context.RIGHT+context.VCENTER, 0);
		
			ClosedTrades.Table = Host:findTable("closed trades"):enumerator();
			ClosedTrades.Row = ClosedTrades.Table:next();
			ClosedTrades.Count = 0;
			ClosedTrades.AmountSum = 0;
			ClosedTrades.SizeSum = 0;
			ClosedTrades.PLSum = 0;
			ClosedTrades.GrossPLSum = 0;
			ClosedTrades.RollSum = 0;
			ClosedTrades.CommSum = 0;
			ClosedTrades.UsedMarginSum = 0;
			while ClosedTrades.Row ~= nil do
				-- Closed Trades Rows
				ClosedTrades.Count = ClosedTrades.Count + 1;
				ClosedTrades.AccountName = ClosedTrades.Row.AccountName;
				ClosedTrades.Symbol = ClosedTrades.Row.Instrument;
				ClosedTrades.Base = Host:findTable("offers"):find("Instrument", ClosedTrades.Symbol).ContractCurrency;
				ClosedTrades.Counter = string.sub(ClosedTrades.Symbol, 5);
				ClosedTrades.AmountSum = FormatStringToNumber(0, ClosedTrades.AmountSum + ClosedTrades.Row.Lot);
				ClosedTrades.Amount = FormatStringToNumber(0, ClosedTrades.Row.Lot);
				ClosedTrades.SizeSum = FormatStringToFinancial(0, ClosedTrades.SizeSum + ConvertBaseToUSD(ClosedTrades.Base, ClosedTrades.Amount));
				ClosedTrades.Size = FormatStringToFinancial(0, ConvertBaseToUSD(ClosedTrades.Base, ClosedTrades.Amount));
				if ClosedTrades.Row.BS == "B" then
					ClosedTrades.Direction = "Long";
				else
					ClosedTrades.Direction = "Short";
				end
				ClosedTrades.PLSum = FormatStringToNumber(1, ClosedTrades.PLSum + ClosedTrades.Row.GrossPL);
				ClosedTrades.PL = FormatStringToNumber(1, ClosedTrades.Row.GrossPL);
				ClosedTrades.GrossPLSum = FormatStringToFinancial(2, ClosedTrades.GrossPLSum + ClosedTrades.Row.GrossPL);
				ClosedTrades.GrossPL = FormatStringToFinancial(2, ClosedTrades.Row.GrossPL);
				ClosedTrades.RollSum = FormatStringToFinancial(2, ClosedTrades.RollSum + ClosedTrades.Row.Int);
				ClosedTrades.Roll = FormatStringToFinancial(2, ClosedTrades.Row.Int);
				ClosedTrades.CommSum = FormatStringToFinancial(2, ClosedTrades.CommSum + (ClosedTrades.Row.Com* -1));
				ClosedTrades.Comm =FormatStringToFinancial(2, ClosedTrades.Row.Com * -1);
				ClosedTrades.OpenTime = FormatStringToDateTime(ClosedTrades.Row.OpenTime);
				ClosedTrades.OpenRate = FormatStringToNumber(Host:findTable("offers"):find("Instrument", ClosedTrades.Symbol).Digits, ClosedTrades.Row.Open);
				-- ClosedTrades.OpenDuration = FormatStringToDateTimeDiffClosed(ClosedTrades.Row.CloseTime, ClosedTrades.Row.OpenTime);
				ClosedTrades.CloseTime =  FormatStringToDateTime(ClosedTrades.Row.CloseTime);
				ClosedTrades.CloseRate = FormatStringToNumber(Host:findTable("offers"):find("Instrument", ClosedTrades.Symbol).Digits, ClosedTrades.Row.Close);
				ClosedTrades.UsedMarginSum = FormatStringToFinancial(2, (ClosedTrades.UsedMarginSum + (Host:findTable("offers"):find("Instrument", ClosedTrades.Symbol).MMR * (ClosedTrades.Amount / 1000))));
				ClosedTrades.UsedMargin = FormatStringToFinancial(2, (Host:findTable("offers"):find("Instrument", ClosedTrades.Symbol).MMR * (ClosedTrades.Amount / 1000)));
				
				if (ClosedTrades.Count % 2 == 0) then context:drawRectangle (-1, 6, 0, Paint.yClosedTradesRow, Length.ClosedTrades, Paint.yClosedTradesRowEnd, 0) end
				context:drawText (5, ClosedTrades.AccountName, Paint.RowTextColor, -1, 0, Paint.yClosedTradesRow, Paint.ClosedTrades_xAccountName, Paint.yClosedTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, ClosedTrades.Symbol, Paint.RowTextColor, -1, 0, Paint.yClosedTradesRow, Paint.ClosedTrades_xSymbol, Paint.yClosedTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, ClosedTrades.Base, Paint.RowTextColor, -1, 0, Paint.yClosedTradesRow, Paint.ClosedTrades_xBase, Paint.yClosedTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, ClosedTrades.Counter, Paint.RowTextColor, -1, 0, Paint.yClosedTradesRow, Paint.ClosedTrades_xCounter, Paint.yClosedTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, ClosedTrades.Amount, Paint.RowTextColor, -1, 0, Paint.yClosedTradesRow, Paint.ClosedTrades_xAmount, Paint.yClosedTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, ClosedTrades.Size, Paint.RowTextColor, -1, 0, Paint.yClosedTradesRow, Paint.ClosedTrades_xSize, Paint.yClosedTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, ClosedTrades.Direction, Paint.RowTextColor, -1, 0, Paint.yClosedTradesRow, Paint.ClosedTrades_xDirection, Paint.yClosedTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, ClosedTrades.PL, Paint.RowTextColor, -1, 0, Paint.yClosedTradesRow, Paint.ClosedTrades_xPL, Paint.yClosedTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				if not Display.Public then context:drawText (5, ClosedTrades.GrossPL, Paint.RowTextColor, -1, 0, Paint.yClosedTradesRow, Paint.ClosedTrades_xGrossPL, Paint.yClosedTradesRowEnd, context.RIGHT+context.VCENTER, 0) end
				context:drawText (5, ClosedTrades.Roll, Paint.RowTextColor, -1, 0, Paint.yClosedTradesRow, Paint.ClosedTrades_xRoll, Paint.yClosedTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, ClosedTrades.Comm, Paint.RowTextColor, -1, 0, Paint.yClosedTradesRow, Paint.ClosedTrades_xComm, Paint.yClosedTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, ClosedTrades.OpenTime, Paint.RowTextColor, -1, 0, Paint.yClosedTradesRow, Paint.ClosedTrades_xOpenTime, Paint.yClosedTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, ClosedTrades.OpenRate, Paint.RowTextColor, -1, 0, Paint.yClosedTradesRow, Paint.ClosedTrades_xOpenRate, Paint.yClosedTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				-- context:drawText (5, ClosedTrades.OpenDuration, Paint.RowTextColor, -1, 0, Paint.yClosedTradesRow, Paint.ClosedTrades_xOpenDuration, Paint.yClosedTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, ClosedTrades.CloseTime, Paint.RowTextColor, -1, 0, Paint.yClosedTradesRow, Paint.ClosedTrades_xCloseTime, Paint.yClosedTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, ClosedTrades.CloseRate, Paint.RowTextColor, -1, 0, Paint.yClosedTradesRow, Paint.ClosedTrades_xCloseRate, Paint.yClosedTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, ClosedTrades.UsedMargin, Paint.RowTextColor, -1, 0, Paint.yClosedTradesRow, Paint.ClosedTrades_xUsedMargin, Paint.yClosedTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				
				Paint.yClosedTradesRow = Paint.yClosedTradesRow + Length.RowSpacing;
				Paint.yClosedTradesRowEnd = Paint.yClosedTradesRow + Length.RowSpacing;
				ClosedTrades.Row = ClosedTrades.Table:next();
			end
			if ClosedTrades.Count > 0 then
				-- Closed Trades Total Rows
				context:drawRectangle (-1, 7, 0, Paint.yClosedTradesRow, Length.ClosedTrades, Paint.yClosedTradesRowEnd, 0)
				context:drawText (5, ClosedTrades.AmountSum, Paint.TotalRowText, -1, 0, Paint.yClosedTradesRow, Paint.ClosedTrades_xAmount, Paint.yClosedTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, ClosedTrades.SizeSum, Paint.TotalRowText, -1, 0, Paint.yClosedTradesRow, Paint.ClosedTrades_xSize, Paint.yClosedTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, ClosedTrades.PLSum, Paint.TotalRowText, -1, 0, Paint.yClosedTradesRow, Paint.ClosedTrades_xPL, Paint.yClosedTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				if not Display.Public then context:drawText (5, ClosedTrades.GrossPLSum, Paint.TotalRowText, -1, 0, Paint.yClosedTradesRow, Paint.ClosedTrades_xGrossPL, Paint.yClosedTradesRowEnd, context.RIGHT+context.VCENTER, 0) end
				context:drawText (5, ClosedTrades.RollSum, Paint.TotalRowText, -1, 0, Paint.yClosedTradesRow, Paint.ClosedTrades_xRoll, Paint.yClosedTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, ClosedTrades.CommSum, Paint.TotalRowText, -1, 0, Paint.yClosedTradesRow, Paint.ClosedTrades_xComm, Paint.yClosedTradesRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, ClosedTrades.UsedMarginSum, Paint.TotalRowText, -1, 0, Paint.yClosedTradesRow, Paint.ClosedTrades_xUsedMargin, Paint.yClosedTradesRowEnd, context.RIGHT+context.VCENTER, 0);
			end
			-- Closed Trades Title
			context:drawRectangle (-1, 2, 0, Paint.yClosedTradesTitle, Length.ClosedTrades, Paint.yClosedTradesTitleEnd, 0);
			context:drawText (1, "Closed Trades (" .. ClosedTrades.Count .. ")" , Paint.TitleTextColor, -1, Length.ColumnSpacing, Paint.yClosedTradesTitle, Length.ClosedTrades, Paint.yClosedTradesTitleEnd, context.LEFT+context.VCENTER, 0);
			context:drawRectangle (-1, 2, 0, Paint.yClosedTradesRow, Length.ClosedTrades, Paint.yClosedTradesRow + 2, 0);
		else
			Paint.yClosedTradesRow = Paint.yTradesRow;
		end
		
		----------------------------------------
		-- Summary Section
		----------------------------------------
		Paint.ySummaryTitle = Paint.yClosedTradesRow + Length.GapSpacing;
		Paint.ySummaryTitleEnd = Paint.ySummaryTitle + Length.TitleSpacing;
		Paint.ySummarySection = Paint.ySummaryTitle + Length.TitleSpacing;
		Paint.ySummarySectionEnd = Paint.ySummarySection + Length.SectionSpacing;

		Paint.ySummaryRow = Paint.ySummarySection + Length.SectionSpacing;
		Paint.ySummaryRowEnd = Paint.ySummaryRow + Length.RowSpacing;

		if Display.Summary == "Show" then
			-- Summary Headings
			context:drawRectangle (-1, 4, 0, Paint.ySummarySection, Length.Summary, Paint.ySummarySectionEnd, 0);
			context:drawText (3, "Symbol", Paint.SectionTextColor, -1, 0, Paint.ySummarySection, Paint.Summary_xSymbol, Paint.ySummarySectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "S Amt", Paint.SectionTextColor, -1, 0, Paint.ySummarySection, Paint.Summary_xSellAmount, Paint.ySummarySectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "S Open", Paint.SectionTextColor, -1, 0, Paint.ySummarySection, Paint.Summary_xSellAvgOpen, Paint.ySummarySectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "S Net P/L", Paint.SectionTextColor, -1, 0, Paint.ySummarySection, Paint.Summary_xSellNetPL, Paint.ySummarySectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "L Amt", Paint.SectionTextColor, -1, 0, Paint.ySummarySection, Paint.Summary_xBuyAmount, Paint.ySummarySectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "L Open", Paint.SectionTextColor, -1, 0, Paint.ySummarySection, Paint.Summary_xBuyAvgOpen, Paint.ySummarySectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "L Net P/L", Paint.SectionTextColor, -1, 0, Paint.ySummarySection, Paint.Summary_xBuyNetPL, Paint.ySummarySectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "T Amt", Paint.SectionTextColor, -1, 0, Paint.ySummarySection, Paint.Summary_xAmount, Paint.ySummarySectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "T Net P/L", Paint.SectionTextColor, -1, 0, Paint.ySummarySection, Paint.Summary_xNetPL, Paint.ySummarySectionEnd, context.RIGHT+context.VCENTER, 0);
		
			Summary.Table = Host:findTable("summary"):enumerator();
			Summary.Row = Summary.Table:next();
			Summary.Count = 0;
			Summary.ShortAmountSum = 0;
			Summary.ShortNetPLSum = 0;
			Summary.LongAmountSum = 0;
			Summary.LongNetPLSum = 0;
			Summary.TotalAmountSum = 0;
			Summary.TotalNetPLSum = 0;
			while Summary.Row ~= nil do
				-- Summary Rows
				Summary.Count = Summary.Count + 1;
				Summary.Symbol = Summary.Row.Instrument;
				if Summary.Row.SellAmountK > 0 then
					Summary.ShortAmountSum = FormatStringToNumber(0, Summary.ShortAmountSum + (Summary.Row.SellAmountK * 1000));
					Summary.ShortAmount = FormatStringToNumber(0, Summary.Row.SellAmountK * 1000);
					Summary.ShortAvgOpen = FormatStringToNumber(Host:findTable("offers"):find("Instrument", Summary.Symbol).Digits , Summary.Row.SellAvgOpen);
					Summary.ShortNetPLSum = FormatStringToFinancial(2, Summary.ShortNetPLSum + Summary.Row.SellNetPL);
					Summary.ShortNetPL = FormatStringToFinancial(2, Summary.Row.SellNetPL);
				else
					Summary.ShortAmount = "-";
					Summary.ShortAvgOpen = "-";
					Summary.ShortNetPL = "-";
				end
				if Summary.Row.BuyAmountK > 0 then
					Summary.LongAmountSum = FormatStringToNumber(0, Summary.LongAmountSum + (Summary.Row.BuyAmountK * 1000));
					Summary.LongAmount = FormatStringToNumber(0, Summary.Row.BuyAmountK * 1000);
					Summary.LongAvgOpen = FormatStringToNumber(Host:findTable("offers"):find("Instrument", Summary.Symbol).Digits , Summary.Row.BuyAvgOpen);
					Summary.LongNetPLSum = FormatStringToFinancial(2, Summary.LongNetPLSum + Summary.Row.BuyNetPL);
					Summary.LongNetPL = FormatStringToFinancial(2, Summary.Row.BuyNetPL);
				else
					Summary.LongAmount = "-";
					Summary.LongAvgOpen = "-";
					Summary.LongNetPL = "-";
				end
				Summary.TotalAmountSum = FormatStringToNumber(0, Summary.TotalAmountSum + (Summary.Row.AmountK * 1000));
				Summary.TotalAmount = FormatStringToNumber(0, Summary.Row.AmountK * 1000);
				Summary.TotalNetPLSum = FormatStringToFinancial(2, Summary.TotalNetPLSum + Summary.Row.NetPL);
				Summary.TotalNetPL = FormatStringToFinancial(2, Summary.Row.NetPL);

				if (Summary.Count % 2 == 0) then context:drawRectangle (-1, 6, 0, Paint.ySummaryRow, Length.Summary, Paint.ySummaryRowEnd, 0) end
				context:drawText (5, Summary.Symbol, Paint.RowTextColor, -1, 0, Paint.ySummaryRow, Paint.Summary_xSymbol, Paint.ySummaryRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, Summary.ShortAmount, Paint.RowTextColor, -1, 0, Paint.ySummaryRow, Paint.Summary_xSellAmount, Paint.ySummaryRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, Summary.ShortAvgOpen, Paint.RowTextColor, -1, 0, Paint.ySummaryRow, Paint.Summary_xSellAvgOpen, Paint.ySummaryRowEnd, context.RIGHT+context.VCENTER, 0);
				if not Display.Public then context:drawText (5, Summary.ShortNetPL, Paint.RowTextColor, -1, 0, Paint.ySummaryRow, Paint.Summary_xSellNetPL, Paint.ySummaryRowEnd, context.RIGHT+context.VCENTER, 0) end
				context:drawText (5, Summary.LongAmount, Paint.RowTextColor, -1, 0, Paint.ySummaryRow, Paint.Summary_xBuyAmount, Paint.ySummaryRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, Summary.LongAvgOpen, Paint.RowTextColor, -1, 0, Paint.ySummaryRow, Paint.Summary_xBuyAvgOpen, Paint.ySummaryRowEnd, context.RIGHT+context.VCENTER, 0);
				if not Display.Public then context:drawText (5, Summary.LongNetPL, Paint.RowTextColor, -1, 0, Paint.ySummaryRow, Paint.Summary_xBuyNetPL, Paint.ySummaryRowEnd, context.RIGHT+context.VCENTER, 0) end
				context:drawText (5, Summary.TotalAmount, Paint.RowTextColor, -1, 0, Paint.ySummaryRow, Paint.Summary_xAmount, Paint.ySummaryRowEnd, context.RIGHT+context.VCENTER, 0);
				if not Display.Public then context:drawText (5, Summary.TotalNetPL, Paint.RowTextColor, -1, 0, Paint.ySummaryRow, Paint.Summary_xNetPL, Paint.ySummaryRowEnd, context.RIGHT+context.VCENTER, 0) end
				
				Paint.ySummaryRow = Paint.ySummaryRow + Length.RowSpacing;
				Paint.ySummaryRowEnd = Paint.ySummaryRow + Length.RowSpacing;
				Summary.Row = Summary.Table:next();
			end
			if Summary.Count > 0 then
				-- Summary Total Rows
				context:drawRectangle (-1, 7, 0, Paint.ySummaryRow, Length.Summary, Paint.ySummaryRowEnd, 0)
				context:drawText (5, Summary.ShortAmountSum, Paint.TotalRowText, -1, 0, Paint.ySummaryRow, Paint.Summary_xSellAmount, Paint.ySummaryRowEnd, context.RIGHT+context.VCENTER, 0);
				if not Display.Public then context:drawText (5, Summary.ShortNetPLSum, Paint.TotalRowText, -1, 0, Paint.ySummaryRow, Paint.Summary_xSellNetPL, Paint.ySummaryRowEnd, context.RIGHT+context.VCENTER, 0) end
				context:drawText (5, Summary.LongAmountSum, Paint.TotalRowText, -1, 0, Paint.ySummaryRow, Paint.Summary_xBuyAmount, Paint.ySummaryRowEnd, context.RIGHT+context.VCENTER, 0);
				if not Display.Public then context:drawText (5, Summary.LongNetPLSum, Paint.TotalRowText, -1, 0, Paint.ySummaryRow, Paint.Summary_xBuyNetPL, Paint.ySummaryRowEnd, context.RIGHT+context.VCENTER, 0) end
				context:drawText (5, Summary.TotalAmountSum, Paint.TotalRowText, -1, 0, Paint.ySummaryRow, Paint.Summary_xAmount, Paint.ySummaryRowEnd, context.RIGHT+context.VCENTER, 0);
				if not Display.Public then context:drawText (5, Summary.TotalNetPLSum, Paint.TotalRowText, -1, 0, Paint.ySummaryRow, Paint.Summary_xNetPL, Paint.ySummaryRowEnd, context.RIGHT+context.VCENTER, 0) end
			end
			-- Summary Title
			context:drawRectangle (-1, 2, 0, Paint.ySummaryTitle, Length.Summary, Paint.ySummaryTitleEnd, 0);
			context:drawText (1, "Summary (" .. Summary.Count .. ")" , Paint.TitleTextColor, -1, Length.ColumnSpacing, Paint.ySummaryTitle, Length.Summary, Paint.ySummaryTitleEnd, context.LEFT+context.VCENTER, 0);
			context:drawRectangle (-1, 2, 0, Paint.ySummaryRow, Length.Summary, Paint.ySummaryRow + 2, 0);
		else
			Paint.ySummaryRow = Paint.yClosedTradesRow;
		end
		
		----------------------------------------
		-- Currency Section
		----------------------------------------
		Paint.yCurrencyTitle = Paint.ySummaryRow + Length.GapSpacing;
		Paint.yCurrencyTitleEnd = Paint.yCurrencyTitle + Length.TitleSpacing;
		Paint.yCurrencySection = Paint.yCurrencyTitle + Length.TitleSpacing;
		Paint.yCurrencySectionEnd = Paint.yCurrencySection + Length.SectionSpacing;
		
		Paint.yCurrencyRow = Paint.yCurrencySection + Length.SectionSpacing;
		Paint.yCurrencyRowEnd = Paint.yCurrencyRow + Length.RowSpacing;

		if Display.Currency == "Show" and Display.Trades == "Show" then
			-- Currency Headings
			context:drawRectangle (-1, 4, 0, Paint.yCurrencySection, Length.Currency, Paint.yCurrencySectionEnd, 0);
			context:drawText (3, "Symbol", Paint.SectionTextColor, -1, 0, Paint.yCurrencySection, Paint.Currency_xSymbol, Paint.yCurrencySectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Sell Size", Paint.SectionTextColor, -1, 0, Paint.yCurrencySection, Paint.Currency_xSellSize, Paint.yCurrencySectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Sell G P/L", Paint.SectionTextColor, -1, 0, Paint.yCurrencySection, Paint.Currency_xSellGrossPL, Paint.yCurrencySectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Buy Size", Paint.SectionTextColor, -1, 0, Paint.yCurrencySection, Paint.Currency_xBuySize, Paint.yCurrencySectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Buy G P/L", Paint.SectionTextColor, -1, 0, Paint.yCurrencySection, Paint.Currency_xBuyGrossPL, Paint.yCurrencySectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Net Size", Paint.SectionTextColor, -1, 0, Paint.yCurrencySection, Paint.Currency_xNetSize, Paint.yCurrencySectionEnd, context.RIGHT+context.VCENTER, 0);
			context:drawText (3, "Net G P/L", Paint.SectionTextColor, -1, 0, Paint.yCurrencySection, Paint.Currency_xNetGrossPL, Paint.yCurrencySectionEnd, context.RIGHT+context.VCENTER, 0);

			-- Currency Rows
			for i = 1, 15 do
				Currency[3][i] = FormatStringToFinancial(0, Currency[2][i] - Currency[1][i]);
				Currency[6][i] = FormatStringToFinancial(2, Currency[5][i] - Currency[4][i]);
			end
			for i = 1, 14 do
				if (i % 2 == 0) then context:drawRectangle (-1, 6, 0, Paint.yCurrencyRow, Length.Currency, Paint.yCurrencyRowEnd, 0) end
				context:drawText (5, CurrencyNames[i], Paint.RowTextColor, -1, 0, Paint.yCurrencyRow, Paint.Currency_xSymbol, Paint.yCurrencyRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, Currency[1][i], Paint.RowTextColor, -1, 0, Paint.yCurrencyRow, Paint.Currency_xSellSize, Paint.yCurrencyRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, Currency[2][i], Paint.RowTextColor, -1, 0, Paint.yCurrencyRow, Paint.Currency_xBuySize, Paint.yCurrencyRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, Currency[3][i], Paint.RowTextColor, -1, 0, Paint.yCurrencyRow, Paint.Currency_xNetSize, Paint.yCurrencyRowEnd, context.RIGHT+context.VCENTER, 0);
				if not Display.Public then context:drawText (5, Currency[4][i], Paint.RowTextColor, -1, 0, Paint.yCurrencyRow, Paint.Currency_xSellGrossPL, Paint.yCurrencyRowEnd, context.RIGHT+context.VCENTER, 0) end
				if not Display.Public then context:drawText (5, Currency[5][i], Paint.RowTextColor, -1, 0, Paint.yCurrencyRow, Paint.Currency_xBuyGrossPL, Paint.yCurrencyRowEnd, context.RIGHT+context.VCENTER, 0) end
				if not Display.Public then context:drawText (5, Currency[6][i], Paint.RowTextColor, -1, 0, Paint.yCurrencyRow, Paint.Currency_xNetGrossPL, Paint.yCurrencyRowEnd, context.RIGHT+context.VCENTER, 0) end
				Paint.yCurrencyRow = Paint.yCurrencyRow + Length.RowSpacing;
				Paint.yCurrencyRowEnd = Paint.yCurrencyRow + Length.RowSpacing;
			end
			
			-- Currency Total Rows
			if Trades.Count > 0 then
				context:drawRectangle (-1, 7, 0, Paint.yCurrencyRow, Length.Currency, Paint.yCurrencyRowEnd, 0)
				context:drawText (5, Currency[1][15], Paint.TotalRowText, -1, 0, Paint.yCurrencyRow, Paint.Currency_xSellSize, Paint.yCurrencyRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, Currency[2][15], Paint.TotalRowText, -1, 0, Paint.yCurrencyRow, Paint.Currency_xBuySize, Paint.yCurrencyRowEnd, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, Currency[3][15], Paint.TotalRowText, -1, 0, Paint.yCurrencyRow, Paint.Currency_xNetSize, Paint.yCurrencyRowEnd, context.RIGHT+context.VCENTER, 0);
				if not Display.Public then context:drawText (5, Currency[4][15], Paint.TotalRowText, -1, 0, Paint.yCurrencyRow, Paint.Currency_xSellGrossPL, Paint.yCurrencyRowEnd, context.RIGHT+context.VCENTER, 0) end
				if not Display.Public then context:drawText (5, Currency[5][15], Paint.TotalRowText, -1, 0, Paint.yCurrencyRow, Paint.Currency_xBuyGrossPL, Paint.yCurrencyRowEnd, context.RIGHT+context.VCENTER, 0) end
				if not Display.Public then context:drawText (5, Currency[6][15], Paint.TotalRowText, -1, 0, Paint.yCurrencyRow, Paint.Currency_xNetGrossPL, Paint.yCurrencyRowEnd, context.RIGHT+context.VCENTER, 0) end
			end
			
			-- Currency Title
			context:drawRectangle (-1, 2, 0, Paint.yCurrencyTitle, Length.Currency, Paint.yCurrencyTitleEnd, 0);
			context:drawText (1, "Currency (" .. ")" , Paint.TitleTextColor, -1, Length.ColumnSpacing, Paint.yCurrencyTitle, Length.Currency, Paint.yCurrencyTitleEnd, context.LEFT+context.VCENTER, 0);
			context:drawRectangle (-1, 2, 0, Paint.yCurrencyRow, Length.Currency, Paint.yCurrencyRow + 2, 0);
		else
			Paint.yCurrencyRow = Paint.ySummaryRow;
		end
		
		----------------------------------------
		-- Accounts Helper
		----------------------------------------
		if Display.Accounts == "Show" and Display.Trades == "Show" then
			-- Select Accounts Rows Data Points
			for i = 1, Accounts.Count do
				context:drawText (5, AccountsAmount[i], Paint.RowTextColor, -1, 0, Paint.yAccountRowHelper,  Paint.Accounts_xAmount, Paint.yAccountRowEndHelper, context.RIGHT+context.VCENTER, 0);
				context:drawText (5, AccountsSize[i], Paint.RowTextColor, -1, 0, Paint.yAccountRowHelper,  Paint.Accounts_xSize, Paint.yAccountRowEndHelper, context.RIGHT+context.VCENTER, 0);
				if not Display.Public then context:drawText (5, AccountsLeverage[i], Paint.RowTextColor, -1, 0, Paint.yAccountRowHelper,  Paint.Accounts_xLeverage, Paint.yAccountRowEndHelper, context.RIGHT+context.VCENTER, 0) end
				Paint.yAccountRowHelper = Paint.yAccountRowHelper + Length.RowSpacing;
				Paint.yAccountRowEndHelper = Paint.yAccountRowHelper + Length.RowSpacing;
			end
			-- Select Accounts Total Rows Data Points
			context:drawText (5, Accounts.AmountSum, Paint.TotalRowText, -1, 0, Paint.yAccountRowHelper,  Paint.Accounts_xAmount, Paint.yAccountRowEndHelper, context.RIGHT+context.VCENTER, 0);
			context:drawText (5, Accounts.SizeSum, Paint.TotalRowText, -1, 0, Paint.yAccountRowHelper,  Paint.Accounts_xSize, Paint.yAccountRowEndHelper, context.RIGHT+context.VCENTER, 0);
			if not Display.Public then context:drawText (5, Accounts.LeverageSum, Paint.TotalRowText, -1, 0, Paint.yAccountRowHelper,  Paint.Accounts_xLeverage, Paint.yAccountRowEndHelper, context.RIGHT+context.VCENTER, 0) end
		end
	end
end