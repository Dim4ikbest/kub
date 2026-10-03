using Toybox.ActivityMonitor;
using Toybox.Activity;
using Toybox.Graphics as Gfx;
using Toybox.Lang;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.WatchUi as Ui;

class InfoFaceView extends Ui.WatchFace {

    private var _sleeping = false;

    function initialize() {
        WatchFace.initialize();
    }

    function onEnterSleep() {
        _sleeping = true;
        Ui.requestUpdate();
    }

    function onExitSleep() {
        _sleeping = false;
        Ui.requestUpdate();
    }

    function onUpdate(dc as Gfx.Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.clear();

        drawDate(dc, cx, (h * 0.10).toNumber());
        drawTime(dc, cx, (h * 0.34).toNumber());
        drawStats(dc, w, h);
    }

    private function drawDate(dc as Gfx.Dc, cx as Lang.Number, y as Lang.Number) as Void {
        var d = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var text = Lang.format("$1$ $2$ $3$", [d.day_of_week, d.day, d.month]);
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawText(cx, y, Gfx.FONT_MEDIUM, text, Gfx.TEXT_JUSTIFY_CENTER);
    }

    private function drawTime(dc as Gfx.Dc, cx as Lang.Number, cy as Lang.Number) as Void {
        var clock = Sys.getClockTime();
        var hour = clock.hour;
        if (!Sys.getDeviceSettings().is24Hour) {
            hour = hour % 12;
            if (hour == 0) {
                hour = 12;
            }
        }
        var text = Lang.format("$1$:$2$", [hour.format("%02d"), clock.min.format("%02d")]);

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(cx, cy, Gfx.FONT_NUMBER_THAI_HOT, text, Gfx.TEXT_JUSTIFY_CENTER);

        if (!_sleeping) {
            var h = dc.getHeight();
            dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
            dc.drawText(cx, cy + (h * 0.26).toNumber(), Gfx.FONT_SMALL,
                clock.sec.format("%02d"), Gfx.TEXT_JUSTIFY_CENTER);
        }
    }

    // 2x2 grid: steps, heart rate, battery, calories
    private function drawStats(dc as Gfx.Dc, w as Lang.Number, h as Lang.Number) as Void {
        var info = ActivityMonitor.getInfo();
        var stats = Sys.getSystemStats();

        var steps = info.steps != null ? info.steps.toString() : "--";
        var cal = info.calories != null ? info.calories.toString() : "--";
        var bat = stats.battery.toNumber().toString() + "%";
        var hr = getHeartRate();
        var hrText = hr != null ? hr.toString() : "--";

        var colL = (w * 0.27).toNumber();
        var colR = (w * 0.73).toNumber();
        var row1 = (h * 0.68).toNumber();
        var row2 = (h * 0.83).toNumber();

        drawStat(dc, colL, row1, "STEPS", steps, Gfx.COLOR_GREEN);
        drawStat(dc, colR, row1, "HR", hrText, Gfx.COLOR_RED);
        drawStat(dc, colL, row2, "BATT", bat, stats.battery < 20 ? Gfx.COLOR_RED : Gfx.COLOR_YELLOW);
        drawStat(dc, colR, row2, "KCAL", cal, Gfx.COLOR_ORANGE);
    }

    private function drawStat(dc as Gfx.Dc, x as Lang.Number, y as Lang.Number,
                              label as Lang.String, value as Lang.String,
                              color as Lang.Number) as Void {
        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, y, Gfx.FONT_XTINY, label, Gfx.TEXT_JUSTIFY_CENTER);
        dc.setColor(color, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, y + dc.getFontHeight(Gfx.FONT_XTINY), Gfx.FONT_MEDIUM, value, Gfx.TEXT_JUSTIFY_CENTER);
    }

    private function getHeartRate() as Lang.Number or Null {
        var cur = Activity.getActivityInfo();
        if (cur != null && cur.currentHeartRate != null) {
            return cur.currentHeartRate;
        }
        var it = ActivityMonitor.getHeartRateHistory(1, true);
        var sample = it.next();
        if (sample != null && sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
            return sample.heartRate;
        }
        return null;
    }
}
