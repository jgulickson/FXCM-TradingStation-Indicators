#**FXTS Indicators & Strategies**


##**Overview**
######1x Strategy
Objective: Proof of concept to control Philips Hue Lights based on trading activity.

######1x Strategy
Objective: Proof of concept to facilitate a variety of push notifications.

######5x indicators
Objective: Highlight specific account level statistics for FXTS (FXCM Trading Station).


##**Functionality**
######Hue Lights Control
Proof of concept to control Philips Hue Lights based on trading activity.

######Push Notifications
Proof of concept to facilitate of push notifications for trading, account and offer activity.

######Day P/L In Percent
Calculates and displays Day P/L in percentage terms.

######Effective Leverage
Calculates and displays effective leverage based on the current equity compared to open positions converted to USD values.

######Equity Return
Calculates and displays equity return based on the current equity compared to the user variable 'Deposit Amount'.

######Equity Drawdown
Calculates and displays equity drawdown based on the current equity compared to the user variable 'Equity High'.

######Symbol Overlay
Calculates and displays symbol's change during period in pips and percent terms as well as symbol's net open positions and net PL.


##**Screenshots**
![Screenshot](https://raw.githubusercontent.com/jgulickson/FXTS-Indicators/master/Screenshot-1.png)

![Screenshot](https://raw.githubusercontent.com/jgulickson/FXTS-Indicators/master/Screenshot-2.png)


##**Installation**
1. Download all desired *.lua files from the repository.

2. Move downloaded *.lua files to the following directory depending on 32 or 64 bit OS version:


	`C:\Program Files (x86)\Candleworks\FXTS2\indicators\Custom`

	`C:\Program Files\Candleworks\FXTS2\indicators\Custom`

3. Close and reopen FXTS.


4. Indicators will now be available under the section 'Statistics' in the 'Add Indicator' window.

5. Strategies will now be available under the section 'Statistics' in the 'Add Indicator' window.

##**Notes**
######Platform Requirement
FXTS (FXCM Trading Station)

######Platform Download URL
[http://download.fxcorporate.com/FXCM/FXTS2Install.EXE](http://download.fxcorporate.com/FXCM/FXTS2Install.EXE)

######Indicore Documentation URL
[http://www.fxcodebase.com/bin/beta/IndicoreSDK-3.0/help/web-content.html](http://www.fxcodebase.com/bin/beta/IndicoreSDK-3.0/help/web-content.html)


##**Version History**

#####Hue Lights Control
######1.0.03092015
- Initial release

#####Push Notifications
######1.1.08242015
- Initial release

#####Day P/L In Percent
######1.2.11062014
- Updated default value for 'Nickname' to ""
- Added support for existing (though unused) option to control font color

######1.0.11062014
- Initial release

#####Effective Leverage
######1.2.11062014
- Updated default value for 'Nickname' to ""
- Updated timer to refresh every 30 seconds from 60 seconds
- Added option to control precision for 'Format_Precision'
- Added support for existing (though unused) option to control font color

######1.0.11062014
- Initial release

#####Equity Return
######1.2.11062014
- Updated default value for 'Nickname' to ""
- Updated 'Format_Financial' function to add thousands separator
- Added option to control precision for 'Format_Financial'
- Added support for existing (though unused) option to control font color

######1.1.11062014
- Fixed percentage calculation

######1.0.11062014
- Initial release

#####Equity Drawdown
######1.2.11062014
- Updated default value for 'Nickname' to ""
- Updated 'Format_Financial' function to add thousands separator
- Added option to control precision for 'Format_Financial'
- Added support for existing (though unused) option to control font color

######1.0.11062014
- Initial release

#####Symbol Overlay
######1.0.11092014
- Initial release