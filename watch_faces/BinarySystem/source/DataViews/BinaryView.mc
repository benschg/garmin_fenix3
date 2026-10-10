using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.Time as Time;
using Toybox.WatchUi as Ui;

const BINARY_ROWS = 6;
const BINARY_RADIUS = 14;

class BinaryView extends Ui.Drawable
{
	var showSeconds = true;
	var color;
	var binaryLocation;
	var typeMethod = null;
	// dot positions per column (0 = seconds, 1 = minutes, 2 = hours), computed on first draw
	var positions = null;

	function initialize(params)
	{
		Drawable.initialize(params);

		binaryLocation = new BinaryLocation();
		binaryLocation.locX = params.get(:x);
		binaryLocation.locY = params.get(:y);
		binaryLocation.borderDistance = params.get(:borderDistance);

		var type = params.get(:type);
		if (type == Vertical)
		{
			typeMethod = binaryLocation.method(:verticalLocation);
		}
		else if (type == Horizontal)
		{
			typeMethod = binaryLocation.method(:horizontalLocation);
		}
		else
		{
			typeMethod = binaryLocation.method(:circularLocation);
		}

		showSeconds = params.get(:showSeconds) == true && App.getApp().getProperty("ShowSeconds") == true;
		color = App.getApp().getProperty("ForegroundColor");
	}

	function computePositions(dc)
	{
		positions = new [3];
		for (var column = 0; column < 3; column++)
		{
			positions[column] = new [BINARY_ROWS];
			for (var row = 0; row < BINARY_ROWS; row++)
			{
				positions[column][row] = typeMethod.invoke(dc, column, row);
			}
		}
	}

	function drawBinaryArray(dc, column, count)
	{
		var column_positions = positions[column];
		for (var row = 0; row < BINARY_ROWS; row++)
		{
			var x = column_positions[row][0];
			var y = column_positions[row][1];

			dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
			dc.drawCircle(x, y, BINARY_RADIUS);

			if ((count & (1 << row)) != 0)
			{
				dc.setColor(color, Gfx.COLOR_TRANSPARENT);
				dc.fillCircle(x, y, BINARY_RADIUS - 1);
			}
		}
	}

	function draw(dc)
	{
		if (positions == null)
		{
			computePositions(dc);
		}

		var time = Gregorian.info(Time.now(), Time.FORMAT_SHORT);

		if (showSeconds && !gIsSleeping)
		{
			drawBinaryArray(dc, 0, time.sec);
		}
		drawBinaryArray(dc, 1, time.min);
		drawBinaryArray(dc, 2, time.hour);
	}
}
