using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class NotificationView extends Ui.Drawable
{
	var color;

	function initialize(params)
	{
		Drawable.initialize(params);
		locX = params.get(:x);
		locY = params.get(:y);
		color = App.getApp().getProperty("ForegroundColor");
	}

	function draw(dc)
	{
		var notificationCount = Sys.getDeviceSettings().notificationCount;
		if (notificationCount > 0)
		{
			// envelope with text lines
			dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
			dc.drawRoundedRectangle(locX, locY, 40, 18, 4);
			dc.drawRectangle(locX+2, locY+4, 10, 1);
			dc.drawRectangle(locX+2, locY+8, 16, 1);
			dc.drawRectangle(locX+2, locY+12, 10, 1);

			dc.setColor(color, Gfx.COLOR_TRANSPARENT);
			dc.drawText(locX+36, locY-1, Gfx.FONT_TINY, notificationCount.toString(), Gfx.TEXT_JUSTIFY_RIGHT);
		}
	}
}
