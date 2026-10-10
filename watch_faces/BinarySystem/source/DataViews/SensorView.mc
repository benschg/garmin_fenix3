using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Activity as Activity;
using Toybox.ActivityMonitor as ActMon;
using Toybox.Application as App;
using Toybox.WatchUi as Ui;

//! Info panel with an icon per value, as a pyramid narrowing toward the
//! bottom of the dial, centered on x:
//!       steps | distance          row width w: cells of 4/9 w and 5/9 w
//!    weather | watch sensor       temperatures, cells at +-innerOffset
//!     floors | heart rate         cells at +-tipOffset
//! Widest values in FONT_XTINY on the 454px screen (icon included):
//! steps "88888" 107px, distance "12.34km" 141px, temperature "104°F"
//! 102px, floors/heart rate "888" 72px.
class SensorView extends Ui.Drawable
{
    const ICON_SIZE = 16;
    const ICON_GAP = 6;

    var rowWidth = 300;
    var rowHeight = 40;
    var innerOffset = 62;
    var tipOffset = 50;
    var showDistance = true;
    var color;
    var panelColor = 0x1E1E1E;

    // temperatures only change slowly, so they are refreshed once a minute
    var weatherText = "--";
    var sensorText = "--";
    var temperatureMinute = -1;

    function initialize(params)
    {
        Drawable.initialize(params);
        locX = params.get(:x);
        locY = params.get(:y);
        rowWidth = params.get(:w);
        rowHeight = params.get(:rowHeight);
        if (params.get(:innerOffset) != null)
        {
            innerOffset = params.get(:innerOffset);
        }
        if (params.get(:tipOffset) != null)
        {
            tipOffset = params.get(:tipOffset);
        }
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

    //! Outside air temperature in Celsius from the phone's weather
    function getWeatherTemperature()
    {
        if (Toybox has :Weather)
        {
            var conditions = Toybox.Weather.getCurrentConditions();
            if (conditions != null)
            {
                return conditions.temperature;
            }
        }
        return null;
    }

    //! Celsius from the watch's own sensor (warmed by the wrist)
    function getSensorTemperature()
    {
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
    function formatTemperature(celsius, units)
    {
        if (celsius == null)
        {
            return "--";
        }
        if (units == Sys.UNIT_STATUTE)
        {
            return (celsius * 9 / 5.0 + 32).format("%.0f") + "°F";
        }
        return celsius.toFloat().format("%.0f") + "°C";
    }

    function updateTemperatures()
    {
        var minute = Sys.getClockTime().min;
        if (minute == temperatureMinute)
        {
            return;
        }
        temperatureMinute = minute;

        var units = Sys.getDeviceSettings().temperatureUnits;
        weatherText = formatTemperature(getWeatherTemperature(), units);
        sensorText = formatTemperature(getSensorTemperature(), units);
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
        else if (icon == :weather)
        {
            // cloud
            dc.fillCircle(x - 4, y + 1, 4);
            dc.fillCircle(x + 1, y - 3, 6);
            dc.fillCircle(x + 5, y + 1, 4);
            dc.fillRectangle(x - 4, y + 1, 9, 5);
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
        updateTemperatures();
        var info = ActMon.getInfo();
        var deviceSettings = Sys.getDeviceSettings();

        // row 1 (widest): steps | distance, steps alone if distance is turned off
        var y = locY + rowHeight / 2;
        var steps = info.steps == null ? "0" : info.steps.toString();
        if (showDistance && info.distance != null)
        {
            // distance is the longest value, so it gets the wider cell
            var stepsCell = rowWidth * 4 / 9;
            var distanceCell = rowWidth - stepsCell;
            var left = locX - rowWidth / 2;
            drawCell(dc, :steps, steps, left + stepsCell / 2, y);
            drawCell(dc, :distance, $.formatDistance(info.distance, deviceSettings.distanceUnits), left + stepsCell + distanceCell / 2, y);
        }
        else
        {
            drawCell(dc, :steps, steps, locX, y);
        }

        // row 2: weather | watch sensor temperature
        y += rowHeight;
        drawCell(dc, :weather, weatherText, locX - innerOffset, y);
        drawCell(dc, :temperature, sensorText, locX + innerOffset, y);

        // row 3 (tip): floors | heart rate
        y += rowHeight;
        drawCell(dc, :floors, getFloors(info), locX - tipOffset, y);
        drawCell(dc, :heartRate, getHeartRate(), locX + tipOffset, y);
    }
}
