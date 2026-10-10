using Toybox.Graphics as Gfx;
using Toybox.Math as Math;
using Toybox.WatchUi as Ui;

//! A shaded area that groups other drawables. Put it in the layout before
//! the drawables it should sit behind.
//! Rounded rectangle by default; with a bottomWidth param it becomes a
//! trapezoid narrowing toward the bottom (to follow the round dial).
//! Filled with a vertical gradient and a thin highlight along the top edge.
class PanelView extends Ui.Drawable
{
	var topColor = 0x2C2C2C;
	var bottomColor = 0x101010;
	var highlightColor = 0x4A4A4A;

	// one horizontal line per pixel row, computed once
	var rowLeft;
	var rowRight;
	var rowColor;

	function initialize(params)
	{
		Drawable.initialize(params);
		locX = params.get(:x);
		locY = params.get(:y);
		var panelWidth = params.get(:w);
		var panelHeight = params.get(:h);
		var radius = params.get(:radius) != null ? params.get(:radius) : 16;
		var bottomWidth = params.get(:bottomWidth) != null ? params.get(:bottomWidth) : panelWidth;

		var centerX = locX + panelWidth / 2.0;
		var bottom = locY + panelHeight;
		var polygon = roundCorners([
			[locX, locY],
			[locX + panelWidth, locY],
			[centerX + bottomWidth / 2.0, bottom],
			[centerX - bottomWidth / 2.0, bottom]
		], radius);
		computeRows(polygon, panelHeight);
	}

	//! Replaces each corner with a curve (quadratic Bezier through the corner)
	function roundCorners(corners, r)
	{
		var count = corners.size();
		var points = [];
		for (var i = 0; i < count; i++)
		{
			var corner = corners[i];
			var start = towards(corner, corners[(i + count - 1) % count], r);
			var end = towards(corner, corners[(i + 1) % count], r);
			for (var step = 0; step <= 4; step++)
			{
				var t = step / 4.0;
				var a = (1 - t) * (1 - t);
				var b = 2 * (1 - t) * t;
				var c = t * t;
				points.add([a * start[0] + b * corner[0] + c * end[0],
				            a * start[1] + b * corner[1] + c * end[1]]);
			}
		}
		return points;
	}

	//! point at distance r from 'from' in the direction of 'to'
	function towards(from, to, r)
	{
		var dx = to[0] - from[0];
		var dy = to[1] - from[1];
		var length = Math.sqrt(dx * dx + dy * dy);
		return [from[0] + dx * r / length, from[1] + dy * r / length];
	}

	//! Left/right edge of the (convex) polygon on every pixel row, and the
	//! gradient color of that row
	function computeRows(polygon, height)
	{
		rowLeft = new [height];
		rowRight = new [height];
		rowColor = new [height];
		var count = polygon.size();
		for (var row = 0; row < height; row++)
		{
			var y = locY + row + 0.5;
			var left = null;
			var right = null;
			for (var i = 0; i < count; i++)
			{
				var p1 = polygon[i];
				var p2 = polygon[(i + 1) % count];
				if ((p1[1] <= y && p2[1] > y) || (p2[1] <= y && p1[1] > y))
				{
					var x = p1[0] + (y - p1[1]) * (p2[0] - p1[0]) / (p2[1] - p1[1]);
					if (left == null || x < left) { left = x; }
					if (right == null || x > right) { right = x; }
				}
			}
			rowLeft[row] = left == null ? 0 : Math.round(left).toNumber();
			rowRight[row] = right == null ? 0 : Math.round(right).toNumber();
			rowColor[row] = row == 1 ? highlightColor : $.blendColor(topColor, bottomColor, row.toFloat() / height);
		}
	}

	function draw(dc)
	{
		var count = rowColor.size();
		for (var row = 0; row < count; row++)
		{
			if (rowRight[row] > rowLeft[row])
			{
				dc.setColor(rowColor[row], Gfx.COLOR_TRANSPARENT);
				dc.drawLine(rowLeft[row], locY + row, rowRight[row], locY + row);
			}
		}
	}
}
