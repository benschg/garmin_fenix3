using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

//! Draws a status icon at (x, y) while isActive() returns true
class StatusIconView extends Ui.Drawable
{
	var image;

	function initialize(params, resource)
	{
		Drawable.initialize(params);
		locX = params.get(:x);
		locY = params.get(:y);
		image = Ui.loadResource(resource);
	}

	function isActive(deviceSettings)
	{
		return false;
	}

	function draw(dc)
	{
		if (isActive(Sys.getDeviceSettings()))
		{
			dc.drawBitmap(locX, locY, image);
		}
	}
}

class BluetoothView extends StatusIconView
{
	function initialize(params)
	{
		StatusIconView.initialize(params, Rez.Drawables.bluetooth_icon);
	}

	function isActive(deviceSettings)
	{
		return deviceSettings.phoneConnected;
	}
}
