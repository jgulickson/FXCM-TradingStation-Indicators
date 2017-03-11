------------------------------------------Overview------------------------------------------
-- Name:             Day P/L in Percent
-- Notes:            Copyright (c) 2014 Jeremy Gulickson
-- Version:          1.1.11062014
-- Usage:            Calculates and displays Day P/L in percentage terms.
--
-- Requirements:     FXTS (FXCM Trading Station)
-- Download Link:    http://download.fxcorporate.com/FXCM/FXTS2Install.EXE
-- Documentation:    http://www.fxcodebase.com/documents/IndicoreSDK-2.3/web-content.html
--
---------------------------------------Version History--------------------------------------
-- v1.0.11062014:    Initial release
-- v1.1.11062014:    Updated default value for 'Nickname' to ""
--                   Added support for existing (though unused) option to control font color
--
--------------------------------------------------------------------------------------------

local Host;
local Account = {};
local Text = {};


function Init()
    indicator:name("Day P/L in Percent");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Statistics");

	indicator.parameters:addGroup("Display Options");
    indicator.parameters:addString("AccountName", "Account Number", "Select the account to monitor.", "");
	indicator.parameters:setFlag("AccountName", core.FLAG_ACCOUNT);
	indicator.parameters:addString("Nickname", "Account Nickname", "Optional.  Enter the nickname of account otherwise leave blank.", "");
    indicator.parameters:addColor("Color", "Color", "Select the color of the text.", core.rgb(255, 255, 255));
end


function Prepare()
	Host = core.host;
    Account.Name = instance.parameters.AccountName;
	Text.Nickname = instance.parameters.Nickname;
	Text.Color = instance.parameters.Color;
	Text.Display = Text.Nickname ..  " " .. "Day P/L: "
	instance:name(Text.Display);
	
	-- Only used to set the color of the legend
	Text.Legend = instance:createTextOutput ("O", "O", "Arial", 9, core.H_Center, core.V_Top, Text.Color, 0);
end


function Update()
	Calculate_Account()
	Host:execute("setStatus", tostring(Account.DayPLp));
end


function Calculate_Account()
    if not(Host:execute("isTableFilled", "accounts")) then
		-- Login does not contain any accounts or data is inaccessible.
		error("No Accounts Found.");
    end
	
	Account.Table = Host:findTable("accounts");
	Account.Row = Account.Table:find("AccountID", Account.Name);
	Account.DayPLp = 0;
	if Account.Row ~= nil then
		Account.DayPL = Account.Row.DayPL;
		Account.Equity = Account.Row.Equity;
		Account.DayPLp = Account.DayPL / Account.Equity * 100;
		Account.DayPLp = Format_Percentage(Account.DayPLp, 2);
	else
		-- Login does not contain the selected account or the selected account row is inaccessible.
		-- Below error call will stop indicator.
		error("Selected Account Not Found.");
    end
end


function Format_Percentage(input, decimals)
	return string.format("%." .. decimals .. "f", input) .. "%";
end