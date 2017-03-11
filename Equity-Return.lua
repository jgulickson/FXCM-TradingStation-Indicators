------------------------------------------Overview------------------------------------------
-- Name:             Equity Return
-- Notes:            Copyright (c) 2014 Jeremy Gulickson
-- Version:          1.2.11062014
-- Usage:            Calculates and displays equity return based on the current equity
--                   compared to the user variable 'Deposit Amount'.
--
-- Requirements:     FXTS (FXCM Trading Station)
-- Download Link:    http://download.fxcorporate.com/FXCM/FXTS2Install.EXE
-- Documentation:    http://www.fxcodebase.com/documents/IndicoreSDK-2.3/web-content.html
--
---------------------------------------Version History--------------------------------------
-- v1.0.11062014:    Initial release
-- v1.1.11062014:    Fixed percentage calculation
-- v1.2.11062014:    Updated default value for 'Nickname' to ""
--                   Updated 'Format_Financial' function to add thousands separator
--                   Added option to control precision for 'Format_Financial'
--                   Added support for existing (though unused) option to control font color
--
--------------------------------------------------------------------------------------------

local Host;
local Account = {};
local Text = {};


function Init()
    indicator:name("Equity Return");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Statistics");

	indicator.parameters:addGroup("Display Options");
    indicator.parameters:addString("AccountName", "Account Number", "Select the account to monitor.", "");
	indicator.parameters:setFlag("AccountName", core.FLAG_ACCOUNT);
	indicator.parameters:addString("Deposit", "Deposit Amount", "Enter the deposit amount of the account.  Do not include a thousands separator.", "50000.00");
	indicator.parameters:addString("Nickname", "Account Nickname", "Optional.  Enter the nickname of account otherwise leave blank.", "");
	indicator.parameters:addString("Precision", "Precision", "Select desired decimal precision", "0");
	indicator.parameters:addStringAlternative("Precision", "0 decimal places", "", "0");
	indicator.parameters:addStringAlternative("Precision", "2 decimal places", "", "2");
    indicator.parameters:addColor("Color", "Color", "Select the color of the text.", core.rgb(255, 255, 255));
end


function Prepare()
	Host = core.host;
    Account.Name = instance.parameters.AccountName;
	Account.Deposit = instance.parameters.Deposit;
	Text.Nickname = instance.parameters.Nickname;
	Text.Color = instance.parameters.Color;
	Text.Precision = instance.parameters.Precision;
	Text.Display = Text.Nickname .. " Return on ".. Format_Financial(Account.Deposit, Text.Precision) ..": ";
	instance:name(Text.Display);
	
	-- Only used to set the color of the legend
	Text.Legend = instance:createTextOutput ("O", "O", "Arial", 9, core.H_Center, core.V_Top, Text.Color, 0);
end


function Update()
	Calculate_Account()
	Host:execute("setStatus", tostring(Account.EquityDiffp .. " | " .. Account.EquityDiff));
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
		Account.EquityDiff = Format_Financial((Account.Equity - Account.Deposit), Text.Precision);
		Account.EquityDiffp = Format_Percentage(((Account.Equity - Account.Deposit) / Account.Deposit * 100), 2);
	else
		-- Login does not contain the selected account or the selected account row is inaccessible.
		-- Below error call will stop indicator.
		error("Selected Account Not Found.");
    end
end


function Format_Percentage(input, decimals)
	return string.format("%." .. decimals .. "f", input) .. "%";
end


function Format_Financial (input, decimals)
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