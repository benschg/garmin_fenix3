using Toybox.WatchUi as Ui;

class AlarmView extends StatusIconView
{
	function initialize(params)
	{
		StatusIconView.initialize(params, Rez.Drawables.alarm_icon);
	}

	function isActive(deviceSettings)
	{
		return deviceSettings.alarmCount > 0;
	}
}
