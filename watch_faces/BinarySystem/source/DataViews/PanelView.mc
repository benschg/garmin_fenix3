using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;

//! A shaded rounded rectangle that groups other drawables. Put it in the
//! layout before the drawables it should sit behind.
class PanelView extends Ui.Drawable
{
	var panelWidth;
	var panelHeight;
	var radius = 16;
	var color = 0x1E1E1E;

	function initialize(params)
	{
		Drawable.initialize(params);
		locX = params.get(:x);
		locY = params.get(:y);
		panelWidth = params.get(:w);
		panelHeight = params.get(:h);
		if (params.get(:radius) != null)
		{
			radius = params.get(:radius);
		}
		if (params.get(:color) != null)
		{
			color = params.get(:color);
		}
	}

	function draw(dc)
	{
		dc.setColor(color, Gfx.COLOR_TRANSPARENT);
		dc.fillRoundedRectangle(locX, locY, panelWidth, panelHeight, radius);
	}
}
