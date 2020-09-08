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

    var batHist = {};
    var batHistCount = 0;
    var timeInterval = 0;
    var remainingBattery;

    var batteryBarSize = .01;
    var batteryBarThickness = .005;
    var batteryBarLocX= .5;
    var batteryBarLocY = .2;

    var batteryPercentageLocX = .5;
    var batteryPercentageLocY = .5;

    var fg_color = Gfx.COLOR_WHITE;
    var bg_transp = Gfx.COLOR_TRANSPARENT;
    var dot_color = App.getApp().getProperty("ForegroundColor");


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
    }



function draw(dc)
    {


        var showBatteryBar = App.getApp().getProperty("showBatteryBar");
        var showBatteryPercentage = App.getApp().getProperty("showBatteryPercentage");

        if (showBatteryBar)
        {
            drawBatteryBar(dc);
        }
        if (showBatteryPercentage)
        {
            drawBatteryPercentage(dc);
        }
    }


    function drawBatteryBars(dc, battery)
    {

        var batteryPercentageBar = Math.round(batteryBarSize / 100.0f * battery).toLong();
        var batteryPercentageOffset =(batteryBarSize -  batteryPercentageBar);   // this is needed to shift the percentage bar to its correct coordinate

        if (batteryBarHorizontal == true) //draw horizontal battery bar
        {
//            if (battery > 99){
//                dc.fillRectangle((batteryBarLocX + batteryBarSize / 2 - batteryBarThickness) * dc.getWidth(),  (batteryBarLocY - 8) * dc.getHeight(), (batteryBarThickness) * dc.getWidth(), (8) * dc.getHeight());
//            }
//            if (battery >= 75) {
//                dc.drawLine((batteryBarLocX + batteryBarSize * 0.25 ) * dc.getWidth(), (batteryBarLocY) * dc.getHeight(), (batteryBarLocX + batteryBarSize * 0.25) * dc.getWidth(), (batteryBarLocY - 5) * dc.getHeight());
//            }
//            if (battery >= 50) {
//                dc.drawLine((batteryBarLocX ) * dc.getWidth(), (batteryBarLocY) * dc.getHeight(), (batteryBarLocX) * dc.getWidth(), (batteryBarLocY - 8) * dc.getHeight());
//            }
//            if (battery >= 25) {
//                dc.drawLine((batteryBarLocX - batteryBarSize * 0.25 ) * dc.getWidth(), (batteryBarLocY) * dc.getHeight(), (batteryBarLocX - batteryBarSize * 0.25) * dc.getWidth(), (batteryBarLocY - 5) * dc.getHeight());
//            }
            dc.fillRectangle((batteryBarLocX - batteryBarSize / 2.0) * dc.getWidth(), (batteryBarLocY - .005) * dc.getHeight(),  (batteryBarThickness) * dc.getWidth(), (.005) * dc.getHeight());   //0% mark
            dc.fillRectangle((batteryBarLocX - batteryBarSize / 2.0) * dc.getWidth(), (batteryBarLocY) * dc.getHeight(), (batteryPercentageBar) * dc.getWidth(), (batteryBarThickness) * dc.getHeight());

        } else {     // draw vertical battery bar            
            if (battery > 99){
                dc.fillRectangle((batteryBarLocX - 8) * dc.getWidth(),  (batteryBarLocY ) * dc.getHeight(), 8 * dc.getWidth(), (batteryBarThickness) * dc.getHeight());
            }
            if (battery >= 75) {
                dc.drawLine((batteryBarLocX - 5) * dc.getWidth(), (batteryBarLocY  + batteryBarSize * 0.25) * dc.getHeight(), (batteryBarLocX) * dc.getWidth(),  (batteryBarLocY+ batteryBarSize * 0.25) * dc.getHeight());
            }
            if (battery >= 50) {
                dc.drawLine((batteryBarLocX - 8) * dc.getWidth(), (batteryBarLocY  + batteryBarSize * 0.5) * dc.getHeight(), (batteryBarLocX) * dc.getWidth(),  (batteryBarLocY+ batteryBarSize * 0.5) * dc.getHeight());
            }
            if (battery >= 25) {
                dc.drawLine((batteryBarLocX - 5) * dc.getWidth(), (batteryBarLocY  + batteryBarSize * 0.75) * dc.getHeight(), (batteryBarLocX) * dc.getWidth(),  (batteryBarLocY+ batteryBarSize * 0.75) * dc.getHeight());
            }
            dc.fillRectangle((batteryBarLocX - 8) * dc.getWidth(), (batteryBarLocY + batteryBarSize - batteryBarThickness) * dc.getHeight(), (8) * dc.getWidth(), (batteryBarThickness) * dc.getHeight());     //0% mark
            dc.fillRectangle((batteryBarLocX) * dc.getWidth(),  (batteryBarLocY + batteryPercentageOffset) * dc.getHeight(), (batteryBarThickness) * dc.getWidth(), (batteryPercentageBar) * dc.getHeight());
        }
    }


    function drawBatteryBar(dc)
    {
        var sysStats = Sys.getSystemStats();
        var battery = sysStats.battery;

        //===============================
        //!battery bar
        //===============================
        dc.setColor(fg_color, bg_transp);
        drawBatteryBars(dc, 100);

        dc.setColor(dot_color, bg_transp);
        drawBatteryBars(dc, battery);
    }

        //===============================
    //!battery prediction
    //===============================
    function batteryPrediction(input, battery, divider) {
        //remember battery percentage and do a prediction how long the battery will last
        var timeDiff = 1;
        if (timeInterval != input) {
            if (input-timeInterval > 1) {
                timeDiff = input-timeInterval;
            }
            timeInterval = input;
            if (batHistCount == 0) {
                batHist[0] = battery;
                batHist[1] = battery;
                batHistCount = 1;
            } else {
                batHist[0] = batHist[1];
                batHist[1] = battery;
            }

            //Sys.println(batHistCount);
            //Sys.println(batHist);

            if (batHist[0] > batHist[1])  {
                var batLoss = batHist[0]-batHist[1];
                remainingBattery = battery / batLoss / divider / timeDiff ; //batRemaining is is a global var
                Sys.println("rem: " + remainingBattery);
            }
        }
    }

    function drawBatteryPercentage(dc)
    {
        var remainingBatteryEstimateMode = App.getApp().getProperty("RemainingBatteryEstimate");
        var sysStats = Sys.getSystemStats();
        var battery = sysStats.battery;
            //===============================
            //!battery percentage
            //===============================           
            var batteryPercentageStr = Math.round(battery).format("%d");
            //Sys.println("string: "+  batteryPercentageString);
            
            //batteryPrediction(seconds, battery, 24);

            if (remainingBatteryEstimateMode) {
                if (remainingBattery) {
                    Sys.println("remaining: " + remainingBattery);
                    if (remainingBattery < 1.0) {
                        //convert to hours remaining
                        var remainingBatteryHours = remainingBattery * 60;
                        batteryPercentageStr = (remainingBatteryHours.format("%.f") + "h - " + batteryPercentageStr + "%");
                    } else {
                        //show remaining in days
                        batteryPercentageStr = (remainingBattery.format("%.f") + "d - " + batteryPercentageStr + "%");
                    }
                } else {
                    batteryPercentageStr = (batteryPercentageStr + "%");
                }
            } else {
                batteryPercentageStr = (batteryPercentageStr + "%");
            }
            var font = Gfx.FONT_TINY;
            dc.setColor(dot_color, bg_transp);
            dc.drawText((batteryBarLocX + batteryPercentageLocX) * dc.getWidth(), (batteryBarLocY +batteryPercentageLocY) * dc.getHeight(), font, batteryPercentageStr, Gfx.TEXT_JUSTIFY_CENTER);
    }


}
