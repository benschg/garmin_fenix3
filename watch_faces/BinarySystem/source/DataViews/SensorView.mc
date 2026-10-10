using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Activity as Activity;
using Toybox.ActivityMonitor as ActMon;
using Toybox.Application as App;
using Toybox.WatchUi as Ui;

//! Info panel with an icon per value, in two rows centered on x:
//!   steps | distance
//!   floors | temperature | heart rate
//! Each value sits in a fixed-width cell sized for its longest value in
//! FONT_XTINY on the 454px screen: steps "88888" and distance "12.34km"
//! need up to 141px of 150, temperature "104°F" 102px of 110, floors and
//! heart rate "888" about 72px of 95.
class SensorView extends Ui.Drawable
{
    const ICON_SIZE = 16;
    const ICON_GAP = 6;

    var rowWidth = 300;
    var rowHeight = 40;
    var showDistance = true;
    var color;
    var panelColor = 0x1E1E1E;

    // temperature only changes slowly, so it is refreshed once a minute
    var temperatureText = "--";
    var temperatureMinute = -1;

    function initialize(params)
    {
        Drawable.initialize(params);
        locX = params.get(:x);
        locY = params.get(:y);
        rowWidth = params.get(:w);
        rowHeight = params.get(:rowHeight);
        if (params.get(:panelColor) != null)
        {
            panelColor = params.get(:panelColor);
        }
        showDistance = App.getApp().getProperty("showDistance");
        color = App.getApp().getProperty("ForegroundColor");
    }

    //===============================
    //! Values
    //===============================

    function getFloors(info)
    {
        if (info has :floorsClimbed && info.floorsClimbed != null)
        {
            return info.floorsClimbed.toString();
        }
        return "--";
    }

    function getHeartRate()
    {
        var heartRate = Activity.getActivityInfo().currentHeartRate;
        if (heartRate == null && ActMon has :getHeartRateHistory)
        {
            var sample = ActMon.getHeartRateHistory(1, true).next();
            if (sample != null && sample.heartRate != ActMon.INVALID_HR_SAMPLE)
            {
                heartRate = sample.heartRate;
            }
        }
        return heartRate == null ? "--" : heartRate.toString();
    }

    //! Celsius from the phone's weather, or else the watch's own sensor
    function getTemperature()
    {
        if (Toybox has :Weather)
        {
            var conditions = Toybox.Weather.getCurrentConditions();
            if (conditions != null && conditions.temperature != null)
            {
                return conditions.temperature;
            }
        }
        if (Toybox has :SensorHistory && Toybox.SensorHistory has :getTemperatureHistory)
        {
            var sample = Toybox.SensorHistory.getTemperatureHistory({ :period => 1 }).next();
            if (sample != null)
            {
                return sample.data;
            }
        }
        return null;
    }

    //! Uses the watch's unit setting: metric shows Celsius, statute Fahrenheit
    function updateTemperature()
    {
        var minute = Sys.getClockTime().min;
        if (minute == temperatureMinute)
        {
            return;
        }
        temperatureMinute = minute;

        var celsius = getTemperature();
        if (celsius == null)
        {
            temperatureText = "--";
        }
        else if (Sys.getDeviceSettings().temperatureUnits == Sys.UNIT_STATUTE)
        {
            temperatureText = (celsius * 9 / 5.0 + 32).format("%d") + "°F";
        }
        else
        {
            temperatureText = celsius.format("%d") + "°C";
        }
    }

    //===============================
    //! Icons, drawn centered on (x, y) in about 16x16 px
    //===============================

    function drawIcon(dc, icon, x, y)
    {
        if (icon == :steps)
        {
            // two footprints
            dc.fillEllipse(x - 4, y + 1, 3, 5);
            dc.fillCircle(x - 4, y + 7, 2);
            dc.fillEllipse(x + 4, y - 4, 3, 5);
            dc.fillCircle(x + 4, y + 2, 2);
        }
        else if (icon == :distance)
        {
            // map pin
            dc.fillCircle(x, y - 3, 6);
            dc.fillPolygon([[x - 5, y], [x + 5, y], [x, y + 8]]);
            dc.setColor(panelColor, Gfx.COLOR_TRANSPARENT);
            dc.fillCircle(x, y - 3, 2);
            dc.setColor(color, Gfx.COLOR_TRANSPARENT);
        }
        else if (icon == :floors)
        {
            // stairs
            dc.fillRectangle(x - 8, y + 3, 16, 5);
            dc.fillRectangle(x - 3, y - 2, 11, 5);
            dc.fillRectangle(x + 2, y - 7, 6, 5);
        }
        else if (icon == :temperature)
        {
            // thermometer
            dc.fillRoundedRectangle(x - 2, y - 8, 5, 12, 2);
            dc.fillCircle(x, y + 5, 4);
        }
        else if (icon == :heartRate)
        {
            // heart
            dc.fillCircle(x - 3, y - 3, 4);
            dc.fillCircle(x + 3, y - 3, 4);
            dc.fillPolygon([[x - 7, y - 2], [x + 7, y - 2], [x, y + 6]]);
        }
    }

    //! Icon + value, centered as a group on (centerX, y)
    function drawCell(dc, icon, text, centerX, y)
    {
        var textWidth = dc.getTextWidthInPixels(text, Gfx.FONT_XTINY);
        var left = centerX - (ICON_SIZE + ICON_GAP + textWidth) / 2;

        dc.setColor(color, Gfx.COLOR_TRANSPARENT);
        drawIcon(dc, icon, left + ICON_SIZE / 2, y);

        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawText(left + ICON_SIZE + ICON_GAP, y, Gfx.FONT_XTINY, text,
                    Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER);
    }

    function draw(dc)
    {
        updateTemperature();
        var info = ActMon.getInfo();
        var deviceSettings = Sys.getDeviceSettings();

        // row 1: steps | distance (steps alone if distance is turned off)
        var y = locY + rowHeight / 2;
        var steps = info.steps == null ? "0" : info.steps.toString();
        if (showDistance && info.distance != null)
        {
            drawCell(dc, :steps, steps, locX - rowWidth / 4, y);
            drawCell(dc, :distance, $.formatDistance(info.distance, deviceSettings.distanceUnits), locX + rowWidth / 4, y);
        }
        else
        {
            drawCell(dc, :steps, steps, locX, y);
        }

        // row 2: floors | temperature | heart rate, the middle cell is wider
        y += rowHeight;
        var sideCell = rowWidth * 95 / 300;
        var sideCenter = rowWidth / 2 - sideCell / 2;
        drawCell(dc, :floors, getFloors(info), locX - sideCenter, y);
        drawCell(dc, :temperature, temperatureText, locX, y);
        drawCell(dc, :heartRate, getHeartRate(), locX + sideCenter, y);
    }
}
