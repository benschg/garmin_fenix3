using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.Time as Time;
using Toybox.WatchUi as Ui;
using Toybox.Math as Math;

const BINARY_ROWS = 6;
// dot radius on the 454px Fenix 8, scaled to the screen width
const BINARY_RADIUS_454 = 14;
// arc segment style: bits are 12 degrees apart, a segment covers 10 of them
const SEGMENT_HALF_ANGLE = 5.0;
const SEGMENT_WIDTH = 24;

class BinaryView extends Ui.Drawable
{
	var showSeconds = true;
	var color;
	// glow halo around lit dots, from the accent color fading to black
	var glowColors;
	// bevel for lit segments: lighter outer edge, darker inner edge
	var bevelLightColor;
	var bevelDarkColor;
	var binaryLocation;
	var typeMethod = null;
	// dot positions per column (0 = seconds, 1 = minutes, 2 = hours), computed on first draw
	var positions = null;
	var radius = BINARY_RADIUS_454;
	var glowStep = 2;
	// arc segment style (circular layouts only): angle of each bit on the ring
	var arcSegments = false;
	var ringRadius = 0;
	var angles = new [3 * BINARY_ROWS];     // index: column * BINARY_ROWS + row

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
			arcSegments = params.get(:arcSegments) == true;
		}

		showSeconds = params.get(:showSeconds) == true && App.getApp().getProperty("ShowSeconds") == true;
		color = App.getApp().getProperty("ForegroundColor");
		bevelLightColor = $.blendColor(color, 0xFFFFFF, 0.35);
		bevelDarkColor = $.blendColor(color, 0x000000, 0.35);
		glowColors = [
			$.blendColor(color, 0x000000, 0.88),
			$.blendColor(color, 0x000000, 0.75),
			$.blendColor(color, 0x000000, 0.55)
		];
	}

	function computePositions(dc)
	{
		radius = Math.round(BINARY_RADIUS_454 * dc.getWidth() / 454.0).toNumber();
		glowStep = radius >= 12 ? 2 : 1;
		positions = new [3];
		for (var column = 0; column < 3; column++)
		{
			positions[column] = new [BINARY_ROWS];
			for (var row = 0; row < BINARY_ROWS; row++)
			{
				positions[column][row] = typeMethod.invoke(dc, column, row);
			}
		}

		if (arcSegments)
		{
			// degrees counter-clockwise from 3 o'clock, as drawArc expects
			var centerX = dc.getWidth() / 2.0;
			var centerY = dc.getHeight() / 2.0;
			ringRadius = (dc.getWidth() - binaryLocation.borderDistance) / 2.0;
			for (var column = 0; column < 3; column++)
			{
				for (var row = 0; row < BINARY_ROWS; row++)
				{
					var position = typeMethod.invoke(dc, column, row);
					angles[column * BINARY_ROWS + row] = Math.toDegrees(Math.atan2(centerY - position[1], position[0] - centerX));
				}
			}
		}
	}

	function drawSegments(dc, column, count)
	{
		var centerX = dc.getWidth() / 2;
		var centerY = dc.getHeight() / 2;
		// glow behind lit segments first, so the segments are drawn on top of it
		for (var row = 0; row < BINARY_ROWS; row++)
		{
			if ((count & (1 << row)) != 0)
			{
				var angle = angles[column * BINARY_ROWS + row];
				for (var i = 0; i < glowColors.size(); i++)
				{
					var spread = glowColors.size() - i;     // outer rings first
					dc.setPenWidth(SEGMENT_WIDTH + spread * 4);
					dc.setColor(glowColors[i], Gfx.COLOR_TRANSPARENT);
					dc.drawArc(centerX, centerY, ringRadius, Gfx.ARC_COUNTER_CLOCKWISE,
					           angle - SEGMENT_HALF_ANGLE - spread * 0.8, angle + SEGMENT_HALF_ANGLE + spread * 0.8);
				}
			}
		}

		for (var row = 0; row < BINARY_ROWS; row++)
		{
			var angle = angles[column * BINARY_ROWS + row];
			var start = angle - SEGMENT_HALF_ANGLE;
			var end = angle + SEGMENT_HALF_ANGLE;
			var lit = (count & (1 << row)) != 0;

			dc.setPenWidth(SEGMENT_WIDTH);
			dc.setColor(lit ? color : 0x262626, Gfx.COLOR_TRANSPARENT);
			dc.drawArc(centerX, centerY, ringRadius, Gfx.ARC_COUNTER_CLOCKWISE, start, end);

			if (lit)
			{
				dc.setPenWidth(4);
				dc.setColor(bevelLightColor, Gfx.COLOR_TRANSPARENT);
				dc.drawArc(centerX, centerY, ringRadius + SEGMENT_WIDTH / 2 - 3, Gfx.ARC_COUNTER_CLOCKWISE, start, end);
				dc.setColor(bevelDarkColor, Gfx.COLOR_TRANSPARENT);
				dc.drawArc(centerX, centerY, ringRadius - SEGMENT_WIDTH / 2 + 3, Gfx.ARC_COUNTER_CLOCKWISE, start, end);
			}
		}
		dc.setPenWidth(1);
	}

	function drawBinaryArray(dc, column, count)
	{
		if (arcSegments)
		{
			drawSegments(dc, column, count);
			return;
		}
		var column_positions = positions[column];
		for (var row = 0; row < BINARY_ROWS; row++)
		{
			var x = column_positions[row][0];
			var y = column_positions[row][1];

			if ((count & (1 << row)) != 0)
			{
				// lit LED: soft halo (outer rings darkest), then the flat dot
				for (var i = 0; i < glowColors.size(); i++)
				{
					dc.setColor(glowColors[i], Gfx.COLOR_TRANSPARENT);
					dc.fillCircle(x, y, radius + glowStep * (glowColors.size() - i));
				}
				dc.setColor(color, Gfx.COLOR_TRANSPARENT);
				dc.fillCircle(x, y, radius - 1);
			}
			else
			{
				// off LED: faint thin ring
				dc.setColor(0x3A3A3A, Gfx.COLOR_TRANSPARENT);
				dc.setPenWidth(2);
				dc.drawCircle(x, y, radius - 1);
				dc.setPenWidth(1);
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
