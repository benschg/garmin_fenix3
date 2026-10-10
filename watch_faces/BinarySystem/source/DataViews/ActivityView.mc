using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.ActivityMonitor as ActMon;
using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class ActivityView extends Ui.Drawable
{
    var stepsXOffset = 0;
    var stepsYOffset = 0;
    var showDistance = true;
    var distanceXOffset = 0;
    var distanceYOffset = 0;
    var color;

    function initialize(params)
    {
        Drawable.initialize(params);
        locX = params.get(:x);
        locY = params.get(:y);
        stepsXOffset = params.get(:stepsXOffset);
        stepsYOffset = params.get(:stepsYOffset);
        distanceXOffset = params.get(:distanceXOffset);
        distanceYOffset = params.get(:distanceYOffset);

        showDistance = App.getApp().getProperty("showDistance");
        color = App.getApp().getProperty("ForegroundColor");
    }

    function draw(dc)
    {
        var deviceSettings = Sys.getDeviceSettings();
        if (deviceSettings.activityTrackingOn != true)
        {
            return;
        }

        var activityInfo = ActMon.getInfo();
        var steps = activityInfo.steps == null ? 0 : activityInfo.steps;

        // steps
        dc.setColor(color, Gfx.COLOR_TRANSPARENT);
        dc.drawText(locX + stepsXOffset, locY + stepsYOffset, Gfx.FONT_TINY, steps.toString(), Gfx.TEXT_JUSTIFY_RIGHT);

        // distance
        if (showDistance && activityInfo.distance != null)
        {
            dc.drawText(locX + distanceXOffset, locY + distanceYOffset, Gfx.FONT_TINY,
                        formatDistance(activityInfo.distance, deviceSettings.distanceUnits), Gfx.TEXT_JUSTIFY_RIGHT);
        }
    }

    //! distance is in centimeters
    function formatDistance(distance, units)
    {
        if (units == Sys.UNIT_METRIC)
        {
            if (distance >= 100000)
            {
                return (distance * 0.00001).format("%.2f") + "km";
            }
            return (distance * 0.01).toLong() + "m";
        }

        var feet = distance * 0.0328084;
        if (feet >= 5280)
        {
            return (feet / 5280.0).format("%.2f") + "mi";
        }
        return feet.toLong() + "ft";
    }
}
