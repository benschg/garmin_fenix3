using Toybox.System as Sys;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;
using Toybox.Math as Math;

class BatteryView extends Ui.Drawable
{
    var showBatteryBar = true;
    var showBatteryPercentage = true;
    var batteryBarHorizontal = true;
    // arc gauge along the top edge instead of a straight bar
    var batteryArc = false;
    var arcInset = 12;
    var arcWidth = 8;

    // layout values between -1 and 1 are a fraction of the screen, anything else is pixels
    var batteryBarSize;
    var batteryBarThickness;
    var batteryBarLocX;
    var batteryBarLocY;
    var batteryPercentageLocX;
    var batteryPercentageLocY;

    var color;
    var percentFont = Gfx.FONT_TINY;

    function initialize(params)
    {
        Drawable.initialize(params);

        batteryBarHorizontal = params.get(:batteryBarHorizontal);
        batteryArc = params.get(:batteryArc) == true;
        if (params.get(:arcInset) != null)
        {
            arcInset = params.get(:arcInset);
        }
        if (params.get(:arcWidth) != null)
        {
            arcWidth = params.get(:arcWidth);
        }
        batteryBarSize = params.get(:batteryBarSize);
        batteryBarThickness = params.get(:batteryBarThickness);
        batteryBarLocX = params.get(:batteryBarLocX);
        batteryBarLocY = params.get(:batteryBarLocY);
        batteryPercentageLocX = params.get(:batteryPercentageLocX);
        batteryPercentageLocY = params.get(:batteryPercentageLocY);

        if (params.get(:percentFont) != null)
        {
            percentFont = params.get(:percentFont);
        }

        showBatteryBar = App.getApp().getProperty("showBatteryBar");
        showBatteryPercentage = App.getApp().getProperty("showBatteryPercentage");
        color = App.getApp().getProperty("ForegroundColor");
    }

    function toPixels(value, screenSize)
    {
        return (value >= -1 && value <= 1) ? value * screenSize : value;
    }

    function draw(dc)
    {
        var battery = Sys.getSystemStats().battery;

        if (showBatteryBar && batteryArc)
        {
            drawBatteryArc(dc, battery);
        }
        else if (showBatteryBar)
        {
            dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
            drawBatteryBar(dc, 100);
            dc.setColor(color, Gfx.COLOR_TRANSPARENT);
            drawBatteryBar(dc, battery);
        }
        if (showBatteryPercentage)
        {
            var width = dc.getWidth();
            var height = dc.getHeight();
            dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
            dc.drawText(toPixels(batteryBarLocX, width) + toPixels(batteryPercentageLocX, width),
                        toPixels(batteryBarLocY, height) + toPixels(batteryPercentageLocY, height),
                        percentFont, Math.round(battery).format("%d") + "%", Gfx.TEXT_JUSTIFY_CENTER);
        }
    }

    //! Gauge on the top of the dial, filling from left (140 deg) to right (40 deg)
    function drawBatteryArc(dc, battery)
    {
        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;
        var radius = centerX - arcInset;
        var start = 140;
        var end = 40;

        // track with rounded ends
        dc.setPenWidth(arcWidth);
        dc.setColor(0x262626, Gfx.COLOR_TRANSPARENT);
        dc.drawArc(centerX, centerY, radius, Gfx.ARC_CLOCKWISE, start, end);
        drawArcCap(dc, centerX, centerY, radius, start);
        drawArcCap(dc, centerX, centerY, radius, end);

        // fill with rounded ends and a lighter inner line
        var fillEnd = start - ((start - end) * battery / 100).toNumber();
        if (fillEnd < start)
        {
            dc.setColor(color, Gfx.COLOR_TRANSPARENT);
            dc.drawArc(centerX, centerY, radius, Gfx.ARC_CLOCKWISE, start, fillEnd);
            drawArcCap(dc, centerX, centerY, radius, start);
            drawArcCap(dc, centerX, centerY, radius, fillEnd);
            dc.setPenWidth(2);
            dc.setColor($.blendColor(color, 0xFFFFFF, 0.4), Gfx.COLOR_TRANSPARENT);
            dc.drawArc(centerX, centerY, radius + arcWidth / 4, Gfx.ARC_CLOCKWISE, start, fillEnd);
        }
        dc.setPenWidth(1);
    }

    //! round end of the arc at the given angle (degrees, counter-clockwise from 3 o'clock)
    function drawArcCap(dc, centerX, centerY, radius, degrees)
    {
        var angle = Math.toRadians(degrees);
        dc.fillCircle(centerX + radius * Math.cos(angle), centerY - radius * Math.sin(angle), arcWidth / 2);
    }

    function drawBatteryBar(dc, battery)
    {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var x = toPixels(batteryBarLocX, width);
        var y = toPixels(batteryBarLocY, height);

        if (batteryBarHorizontal)
        {
            var length = toPixels(batteryBarSize, width);
            var thickness = toPixels(batteryBarThickness, height);
            var left = x - length / 2;
            dc.fillRectangle(left, y - thickness, thickness, thickness);     // 0% mark
            dc.fillRectangle(left, y, length * battery / 100, thickness);
        }
        else
        {
            var length = toPixels(batteryBarSize, height);
            var thickness = toPixels(batteryBarThickness, width);
            if (battery > 99)
            {
                dc.fillRectangle(x - 8, y, 8, thickness);
            }
            if (battery >= 75)
            {
                dc.drawLine(x - 5, y + length * 0.25, x, y + length * 0.25);
            }
            if (battery >= 50)
            {
                dc.drawLine(x - 8, y + length * 0.5, x, y + length * 0.5);
            }
            if (battery >= 25)
            {
                dc.drawLine(x - 5, y + length * 0.75, x, y + length * 0.75);
            }
            var filled = length * battery / 100;
            dc.fillRectangle(x - 8, y + length - thickness, 8, thickness);   // 0% mark
            dc.fillRectangle(x, y + length - filled, thickness, filled);
        }
    }
}
