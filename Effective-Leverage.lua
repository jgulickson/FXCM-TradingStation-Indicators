------------------------------------------Overview------------------------------------------
-- Name:             Effective Leverage
-- Notes:            Copyright (c) 2014 Jeremy Gulickson
-- Version:          1.1.11062014
-- Usage:            Calculates and displays effective leverage based on the current
--                   equity compared to open positions converted to USD values.
-- 
-- Restrictions      a) Due to their unique nature, all CFD symbols are excluded from
--                      calculation (InstrumentType <> 1).
--                   b) In order to convert open positions to USD values, the user must be
--                      subscribed to 13 specific symbols otherwise this process will fail.
--
-- Requirements:     FXTS (FXCM Trading Station)
-- Download Link:    http://download.fxcorporate.com/FXCM/FXTS2Install.EXE
-- Documentation:    http://www.fxcodebase.com/documents/IndicoreSDK-2.3/web-content.html
--
---------------------------------------Version History--------------------------------------
-- v1.0.11062014:    Initial release
-- v1.1.11062014:    Updated default value for 'Nickname' to ""
--                   Updated timer to refresh every 30 seconds from 60 seconds
--                   Added option to control precision for 'Format_Precision'
--                   Added support for existing (though unused) option to control font color
--
--------------------------------------------------------------------------------------------

local Host;
local Timer;
local Account = {};
local Offer = {};
local Trade = {};
local Text = {};


function Init()
    indicator:name("Effective Leverage");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Statistics");

	indicator.parameters:addGroup("Display Options");
    indicator.parameters:addString("AccountName", "Account Number", "Select the account to monitor.", "");
	indicator.parameters:setFlag("AccountName", core.FLAG_ACCOUNT);
	indicator.parameters:addString("Nickname", "Account Nickname", "Optional.  Enter the nickname of account otherwise leave blank.", "");
	indicator.parameters:addString("Precision", "Precision", "Select desired decimal precision", "2");
	indicator.parameters:addStringAlternative("Precision", "1 decimal places", "", "1");
	indicator.parameters:addStringAlternative("Precision", "2 decimal places", "", "2");
	indicator.parameters:addStringAlternative("Precision", "3 decimal places", "", "3");
	indicator.parameters:addStringAlternative("Precision", "4 decimal places", "", "4");
    indicator.parameters:addColor("Color", "Color", "Select the color of the text.", core.rgb(255, 255, 255));
end


function Prepare()
	Host = core.host;
    Account.Name = instance.parameters.AccountName;
	Text.Nickname = instance.parameters.Nickname;
	Text.Color = instance.parameters.Color;
	Text.Precision = instance.parameters.Precision;
	Text.Display = Text.Nickname .. " Effective Leverage: ";
	instance:name(Text.Display);
	
	Calculate_Account()
	Calculate_Trade()
	Host:execute("setStatus", tostring(Account.Leverage .. ":1"));
	-- Only used to set the color of the legend
	Text.Legend = instance:createTextOutput ("O", "O", "Arial", 9, core.H_Center, core.V_Top, Text.Color, 0);
	
	Timer = Host:execute("setTimer", 1, 30);
end


function Update()
	-- In order to limit CPU utilization, a timer is used to update this indicator
	-- instead of the standard update function which is called with each new tick.
end


function Calculate_Account()
    if not(Host:execute("isTableFilled", "accounts")) then
		-- Login does not contain any accounts or data is inaccessible.
		error("No Accounts Found.");
    end
	
	Account.Table = Host:findTable("accounts");
	Account.Row = Account.Table:find("AccountID", Account.Name);
	if Account.Row ~= nil then
		Account.Equity = Account.Row.Equity;
	else
		-- Login does not contain the selected account or the selected account row is inaccessible.
		-- Below error call will stop indicator.
		error("Selected Account Not Found.");
    end
end


function Calculate_Trade()
    if not(Host:execute("isTableFilled", "trades")) then
		-- Login does not have any open trades or data is inaccessible.
		Account.Leverage = 0;
		return;
    end
	
	Offer.Table = Host:findTable("offers");
	Trade.Table = Host:findTable("trades"):enumerator();
	Trade.Row = Trade.Table:next();
	Trade.Count = 0;
	Trade.SumInUSD = 0;
	while Trade.Row ~= nil do
		Trade.Symbol = Trade.Row.Instrument;
		if Trade.Row.AccountID == Account.Name and Offer.Table:find("Instrument", Trade.Symbol).InstrumentType == 1 then
			Trade.Count = Trade.Count + 1;
			Trade.Base = Offer.Table:find("Instrument", Trade.Symbol).ContractCurrency;
			Trade.Amount = Trade.Row.Lot;
			Trade.SizeInUSD = Calculate_ConvertToUSD(Trade.Base, Trade.Amount);
			Trade.SumInUSD = Trade.SumInUSD + Trade.SizeInUSD;
		end
		Trade.Row = Trade.Table:next();
	end
	Account.Leverage = Format_Precision(Trade.SumInUSD / Account.Equity, Text.Precision);
end


function Calculate_ConvertToUSD(base, amount)
	local SizeInUSD = 0;
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


function Format_Precision(input, decimals)
	return string.format("%." .. decimals .. "f", input);
end


function AsyncOperationFinished(reference)
	if reference == 1 then
		Calculate_Account()
		Calculate_Trade()
		Host:execute("setStatus", tostring(Account.Leverage .. ":1"));
	end
end


 function ReleaseInstance()
	host:execute("killTimer", Timer);
 end