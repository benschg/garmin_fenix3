using Toybox.Lang as Lang;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.Time as Time;
using Toybox.WatchUi as Ui;

class TimeView extends Ui.Drawable
{
    var showTime = true;
    var showDate = true;
    var timeFont = Gfx.FONT_LARGE;
    var color;

    function initialize(params)
    {
        Ui.Drawable.initialize(params);
        // x and y are fractions of the screen size
        locX = params.get(:x);
        locY = params.get(:y);
        showTime = params.get(:showTime);
        showDate = params.get(:showDate);
        if (params.get(:timeFont) != null)
        {
            timeFont = params.get(:timeFont);
        }
        color = App.getApp().getProperty("ForegroundColor");
    }

    function draw(dc)
    {
        var time = Gregorian.info(Time.now(), Time.FORMAT_LONG);
        var centerX = locX * dc.getWidth();
        var centerY = locY * dc.getHeight();

        if (showTime)
        {
            var lineHeight = showDate ? dc.getHeight() / 7 : 0;
            var timeStr = Lang.format("$1$:$2$", [time.hour, time.min.format("%02d")]);
            // soft drop shadow, then the time
            dc.setColor(0x303030, Gfx.COLOR_TRANSPARENT);
            dc.drawText(centerX + 2, centerY - lineHeight + 3, timeFont, timeStr, Gfx.TEXT_JUSTIFY_CENTER);
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            dc.drawText(centerX, centerY - lineHeight, timeFont, timeStr, Gfx.TEXT_JUSTIFY_CENTER);
        }
        if (showDate)
        {
            dc.setColor(color, Gfx.COLOR_TRANSPARENT);
            dc.drawText(centerX, centerY, Gfx.FONT_TINY,
                        Lang.format("$1$ $2$ $3$", [time.day_of_week, time.month, time.day]), Gfx.TEXT_JUSTIFY_CENTER);
        }
    }
}
