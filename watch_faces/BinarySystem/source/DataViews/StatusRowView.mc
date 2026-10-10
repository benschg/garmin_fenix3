using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

//! Alarm, Bluetooth and notifications in one row, as icons only. Only
//! active items are shown and the row is centered on x as a group.
class StatusRowView extends Ui.Drawable
{
	const GAP = 12;
	const ENVELOPE_WIDTH = 26;
	const ENVELOPE_HEIGHT = 18;

	var alarmImage;
	var bluetoothImage;
	var rowHeight;

	function initialize(params)
	{
		Drawable.initialize(params);
		locX = params.get(:x);
		locY = params.get(:y);
		alarmImage = Ui.loadResource(Rez.Drawables.alarm_icon);
		bluetoothImage = Ui.loadResource(Rez.Drawables.bluetooth_icon);
		rowHeight = bluetoothImage.getHeight();
	}

	//! envelope icon, left edge at x
	function drawNotifications(dc, x, centerY)
	{
		var top = centerY - ENVELOPE_HEIGHT / 2;
		var right = x + ENVELOPE_WIDTH - 1;
		var bottom = top + ENVELOPE_HEIGHT - 1;
		dc.setColor(0xCCCCCC, Gfx.COLOR_TRANSPARENT);
		dc.setPenWidth(2);
		dc.drawRoundedRectangle(x, top, ENVELOPE_WIDTH, ENVELOPE_HEIGHT, 3);
		dc.drawLine(x + 1, top + 1, x + ENVELOPE_WIDTH / 2, top + ENVELOPE_HEIGHT / 2);
		dc.drawLine(x + ENVELOPE_WIDTH / 2, top + ENVELOPE_HEIGHT / 2, right, top + 1);
		dc.setPenWidth(1);
	}

	function draw(dc)
	{
		var settings = Sys.getDeviceSettings();
		var showAlarm = settings.alarmCount > 0;
		var showBluetooth = settings.phoneConnected;
		var showNotifications = settings.notificationCount > 0;

		// total width of the visible items, to center them
		var width = 0;
		var items = 0;
		if (showAlarm)
		{
			width += alarmImage.getWidth();
			items++;
		}
		if (showBluetooth)
		{
			width += bluetoothImage.getWidth();
			items++;
		}
		if (showNotifications)
		{
			width += ENVELOPE_WIDTH;
			items++;
		}
		if (items == 0)
		{
			return;
		}
		width += GAP * (items - 1);

		var x = locX - width / 2;
		var centerY = locY + rowHeight / 2;
		if (showAlarm)
		{
			dc.drawBitmap(x, centerY - alarmImage.getHeight() / 2, alarmImage);
			x += alarmImage.getWidth() + GAP;
		}
		if (showBluetooth)
		{
			dc.drawBitmap(x, centerY - bluetoothImage.getHeight() / 2, bluetoothImage);
			x += bluetoothImage.getWidth() + GAP;
		}
		if (showNotifications)
		{
			drawNotifications(dc, x, centerY);
		}
	}
}
