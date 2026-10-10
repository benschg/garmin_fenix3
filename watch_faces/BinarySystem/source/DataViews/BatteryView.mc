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

    // layout values between -1 and 1 are a fraction of the screen, anything else is pixels
    var batteryBarSize;
    var batteryBarThickness;
    var batteryBarLocX;
    var batteryBarLocY;
    var batteryPercentageLocX;
    var batteryPercentageLocY;

    var color;

    function initialize(params)
    {
        Drawable.initialize(params);

        batteryBarHorizontal = params.get(:batteryBarHorizontal);
        batteryBarSize = params.get(:batteryBarSize);
        batteryBarThickness = params.get(:batteryBarThickness);
        batteryBarLocX = params.get(:batteryBarLocX);
        batteryBarLocY = params.get(:batteryBarLocY);
        batteryPercentageLocX = params.get(:batteryPercentageLocX);
        batteryPercentageLocY = params.get(:batteryPercentageLocY);

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

        if (showBatteryBar)
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
                        Gfx.FONT_TINY, Math.round(battery).format("%d") + "%", Gfx.TEXT_JUSTIFY_CENTER);
        }
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
