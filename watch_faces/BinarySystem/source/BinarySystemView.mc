using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;

// true while the watch is in low power mode (seconds are hidden)
var gIsSleeping = false;

class BinarySystemView extends Ui.WatchFace {

    var isDirty = false;
    var backgroundColor = Gfx.COLOR_BLACK;

    function initialize() {
        WatchFace.initialize();
    }

    //! Load the layout selected in the settings. The drawables read their
    //! settings when they are created, so this runs again on settings changes.
    function onLayout(dc) {
        var layoutMode = App.getApp().getProperty("LayoutType");
        if (layoutMode == 0) {
            setLayout(Rez.Layouts.GeekModeLayout(dc));
        } else if (layoutMode == 1) {
            setLayout(Rez.Layouts.VerticalLayout(dc));
        } else if (layoutMode == 2) {
            setLayout(Rez.Layouts.HorizontalLayout(dc));
        } else if (layoutMode == 3) {
            setLayout(Rez.Layouts.NormalModeLayout(dc));
        } else {
            setLayout(Rez.Layouts.NormalModeLayout2(dc));
        }
        backgroundColor = App.getApp().getProperty("BackgroundColor");
    }

    function onUpdate(dc) {
        if (isDirty) {
            onLayout(dc);
            isDirty = false;
        }
        dc.setColor(Gfx.COLOR_TRANSPARENT, backgroundColor);
        dc.clear();
        View.onUpdate(dc);
    }

    //! The user has just looked at their watch.
    function onExitSleep() {
        gIsSleeping = false;
        Ui.requestUpdate();
    }

    //! Low power mode: updates only once a minute.
    function onEnterSleep() {
        gIsSleeping = true;
        Ui.requestUpdate();
    }

    function onSettingsChanged() {
        isDirty = true;
    }

}
