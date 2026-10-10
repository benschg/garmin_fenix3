using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Activity as Activity;
using Toybox.ActivityMonitor as ActMon;
using Toybox.Application as App;
using Toybox.Time as Time;
using Toybox.WatchUi as Ui;

//! One row centered at (x, y): floors climbed, temperature, heart rate
class SensorView extends Ui.Drawable
{
    var spacing = 85;
    var color;

    // temperature only changes slowly, so it is refreshed once a minute
    var temperatureText = "--";
    var temperatureMinute = -1;

    function initialize(params)
    {
        Drawable.initialize(params);
        locX = params.get(:x);
        locY = params.get(:y);
        spacing = params.get(:spacing);
        color = App.getApp().getProperty("ForegroundColor");
    }

    function getFloors()
    {
        var info = ActMon.getInfo();
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

    function draw(dc)
    {
        updateTemperature();
        var fontHeight = dc.getFontHeight(Gfx.FONT_TINY);
        var y = locY + fontHeight / 2;

        dc.setColor(color, Gfx.COLOR_TRANSPARENT);
        var justify = Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER;

        // floors: up arrow + count
        var floors = getFloors();
        var floorsX = locX - spacing;
        var arrowX = floorsX - dc.getTextWidthInPixels(floors, Gfx.FONT_TINY) / 2 - 8;
        dc.fillPolygon([[arrowX, y - 6], [arrowX - 6, y + 4], [arrowX + 6, y + 4]]);
        dc.drawText(floorsX + 4, y, Gfx.FONT_TINY, floors, justify);

        dc.drawText(locX, y, Gfx.FONT_TINY, temperatureText, justify);

        // heart rate: small heart + bpm
        var heartRate = getHeartRate();
        var heartX = locX + spacing - dc.getTextWidthInPixels(heartRate, Gfx.FONT_TINY) / 2 - 8;
        dc.fillCircle(heartX - 3, y - 3, 4);
        dc.fillCircle(heartX + 3, y - 3, 4);
        dc.fillPolygon([[heartX - 7, y - 2], [heartX + 7, y - 2], [heartX, y + 6]]);
        dc.drawText(locX + spacing + 4, y, Gfx.FONT_TINY, heartRate, justify);
    }
}
