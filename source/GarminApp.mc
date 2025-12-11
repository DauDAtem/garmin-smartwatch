import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Math;
import Toybox.Timer;
import Toybox.Activity;

class GarminApp extends Application.AppBase {
    const MAX_BARS = 60;
    const BASELINE_AVG_CADENCE = 150;
    const HEIGHT_BASELINE = 170;
    const STEP_RATE = 6;

    private var _idealMinCadence = 90;
    private var _idealMaxCadence = 100;
    private var _zoneHistory as Array<Float?> = new [MAX_BARS]; // Store 60 data points (1 minutes at 1-second intervals)
    
    private var _historyIndex = 0;
    private var _historyCount = 0;
    private var _historyTimer;

    // Timer state
    private var _startTimestamp as Number? = null;
    private var _elapsedBeforePause = 0;
    private var _isRunning = false;
    private var _isPaused = false;

    enum {
        Beginner = 0.96,
        Intermediate = 1,
        Advanced = 1.04
    }

    //user info (testing with dummy value rn, implement user profile input later)
    private var _userHeight = 160;
    private var _userSpeed = 0;
    private var _trainingLvl = Beginner;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        _historyTimer = new Timer.Timer();
        _historyTimer.start(method(:updateZoneHistory), 1000, true);
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        if (_historyTimer != null) {
            _historyTimer.stop();
        }
        stopTimer();
    }


    // Zone history management
    function updateZoneHistory() as Void {
        var info = Activity.getActivityInfo();
        
        //var zoneState = null;
        if (info != null && info.currentCadence != null) {
            var newCadence = info.currentCadence.toFloat();
            _zoneHistory[_historyIndex] = newCadence;
            // Add to circular buffer
            _historyIndex = (_historyIndex + 1) % MAX_BARS;
            if (_historyCount < MAX_BARS) { _historyCount++; }
        }

    }

    function getMinCadence() as Number {
        return _idealMinCadence;
    }
    
    function getMaxCadence() as Number {
        return _idealMaxCadence;
    }

    function setMinCadence(value as Number) as Void {
        _idealMinCadence = value;
    }

    function setMaxCadence(value as Number) as Void {
        _idealMaxCadence = value;
    }

    function getZoneHistory() as Array<Float?> {
        return _zoneHistory;
    }

    function getHistoryCount() as Number {
        return _historyCount;
    }

    function getHistoryIndex() as Number {
        return _historyIndex;
    }

    // Timer controls
    function startTimer() as Void {
        if (!_isRunning) {
            _startTimestamp = System.getTimer();
            _isRunning = true;
            _isPaused = false;
        }
    }

    function stopTimer() as Void {
        if (_isRunning && _startTimestamp != null) {
            _elapsedBeforePause += (System.getTimer() - _startTimestamp);
            _isRunning = false;
            _isPaused = true;
            _startTimestamp = null;
        }
    }

    function resetTimer() as Void {
        _startTimestamp = null;
        _elapsedBeforePause = 0;
        _isRunning = false;
        _isPaused = false;
    }

    function isRunning() as Boolean {
        return _isRunning;
    }

    function isPaused() as Boolean {
        return _isPaused;
    }

    function getElapsedMillis() as Number {
        var elapsed = _elapsedBeforePause;

        if (_isRunning && _startTimestamp != null) {
            elapsed += (System.getTimer() - _startTimestamp);
        }

        return elapsed;
    }

    function formatElapsedTime() as String {
        var millis = getElapsedMillis();
        var totalSeconds = Math.floor(millis / 1000.0);
        var hours = Math.floor(totalSeconds / 3600);
        var minutes = Math.floor((totalSeconds % 3600) / 60);
        var seconds = totalSeconds % 60;

        return hours.format("%02d") + ":" + minutes.format("%02d") + ":" + seconds.format("%02d");
    }

    function getTimerStatusLabel() as String {
        if (isRunning()) {
            return WatchUi.loadResource(Rez.Strings.timer_running) as String;
        }

        if (isPaused()) {
            return WatchUi.loadResource(Rez.Strings.timer_paused) as String;
        }

        return WatchUi.loadResource(Rez.Strings.timer_ready) as String;
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new SimpleView(), new SimpleViewDelegate() ];
    }

}

// Provide a global accessor for environments that expect a symbol-level lookup
// instead of the instance method on GarminApp.
function getTimerStatusLabel() as String {
    return getApp().getTimerStatusLabel();
}

function getApp() as GarminApp {
    return Application.getApp() as GarminApp;
}
