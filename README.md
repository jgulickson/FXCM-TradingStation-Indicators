# FX-TradingStation-Indicators

## Overview
#### Summary
Repository contains eight (8) non-trading indicators written in Lua and intended to be executed using [FXCM Trading Station](https://www.fxcm.com/uk/platforms/trading-station/innovative-platform/). FXCM Trading Station is a financial trading application written for Windows that can leverage scripts written in Lua (and JavaScript) via [Indicore SDK](http://www.fxcodebase.com/bin/products/IndicoreSDK/3.3.0/help/Lua/web-content.html) to further extend functionality.

###### Symbol Overlay
Calculates and displays symbol's change during period in pips and percent terms as well as symbol's net open positions and net PL.

![Symbol Overlay](/README-Images/Symbol-Overlay.png)

###### Day P/L In Percent
Calculates and displays day p/l in percentage terms.

###### Effective Leverage
Calculates and displays effective leverage based on the current equity compared to open positions converted to USD values.

###### Equity Return
Calculates and displays equity return based on the current equity compared to the user variable 'Deposit Amount'.

###### Equity Drawdown
Calculates and displays equity drawdown based on the current equity compared to the user variable 'Equity High'.

![Symbol Overlay](/README-Images/4x-Indicators.png)

###### Account Overlay
Calculates and displays account's current equity, day p/l, day p/l in percent and leverage.

![Symbol Overlay](/README-Images/Account-Overlay.png)

###### Account Overview
Recreates all trading tables and adds additional values for display on Marketscope for improved consumability.

![Symbol Overlay](/README-Images/Account-Overview.png)

###### Inverted Spread Identifier
Highlights zero and negative spreads.

## **Installation**
1. Clone or download desired *.lua files from this repository.

2. Move *.lua files to the following directory depending on 32 or 64 bit OS version:

	`C:\Program Files (x86)\Candleworks\FXTS2\indicators\Custom`

	`C:\Program Files\Candleworks\FXTS2\indicators\Custom`

3. If previously running, close and reopen FXCM Trading Station.

4. Strategy(ies) will now be available under 'Alerts and Trading Automation' > 'New Strategy or Alert.'

*OR*

1. Clone or download desired *.lua files from this repository.

2. If not running, open FXCM Trading Station.

3. Drap and drop *.lua files onto a Marketscope chart instance.

## Version History

#### Symbol Overlay
###### 1.1.07282016
- ***Feature release***
- Added average open rate
- Added average pips
- Added automatic suppression of values if exposure = 0
- Overall code optimization

###### 1.0.07282016
- ***Initial release***

#### Day P/L In Percent
###### 1.1.11062014
- ***Cosmetic release***
- Updated default value for 'Nickname' to ""
- Added support for existing (though unused) option to control font color

###### 1.0.11062014
- ***Initial release***

#### Effective Leverage
###### 1.1.11062014
- ***Cosmetic release***
- Updated default value for 'Nickname' to ""
- Updated timer to refresh every 30 seconds from 60 seconds
- Added option to control precision for 'Format_Precision'
- Added support for existing (though unused) option to control font color

###### 1.0.11062014
- ***Initial release***

#### Equity Return
###### 1.2.11062014
- ***Cosmetic release***
- Updated default value for 'Nickname' to ""
- Updated 'Format_Financial' function to add thousands separator
- Added option to control precision for 'Format_Financial'
- Added support for existing (though unused) option to control font color

###### 1.1.11062014
- ***Feature release***
- Fixed percentage calculation

###### 1.0.11062014
- ***Initial release***

#### Equity Drawdown
###### 1.1.11062014
- ***Cosmetic release***
- Updated default value for 'Nickname' to ""
- Updated 'Format_Financial' function to add thousands separator
- Added option to control precision for 'Format_Financial'
- Added support for existing (though unused) option to control font color

###### 1.0.11062014
- ***Initial release***

#### Account Overlay
###### 1.0.01312016
- ***Initial release***

#### Account Overview
###### 1.0.mmddyyyy
- ***Initial release***

#### Inverted Spread Identifier
###### 1.0.mmddyyyy
- ***Initial release***
