using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Position as Pos;
using Toybox.Application as App;

class gilgadroidView extends Ui.WatchFace {

	const LINES = 32.0;
	var myFontS;
	var myFontM;
	var sunrise;
	var sunset;
	var moon;
	var todate = 0;
	var RND = Math.rand() % 2;
	var ratio = 1.0;
	
    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
		myFontM = Ui.loadResource(Rez.Fonts.myFontM);
		myFontS = Ui.loadResource(Rez.Fonts.myFontS);
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore the state of this View and prepare it to be shown. This includes loading resources into memory.
    function onShow() {
    }

	function toRad(num){						// because Math.toRadians() doesn't work for some reason
		return ( Math.PI / 180 ) * num;
	}

	function toDeg(num){						// because Math.toDegrees() doesn't work for some reason
		return ( 180 / Math.PI ) * num;
	}

    function sunRise(year, month, day, latitude, longitude) {
		var zenith = toRad(90.833); 			// in radians

		// 1
    	var N1 = (275 * month / 9).toNumber();
		var N2 = ((month + 9) / 12).toNumber();
		var N3 = 1 + ((year - 4 * (year / 4).toNumber() + 2) / 3).toNumber();
		var N = N1 - (N2 * N3) + day - 30;

		// 2
		var lngHour = toDeg(longitude) / 15;
		var tUp = N + ((6 - lngHour) / 24);

		// 3
		var Mup = (0.9856 * tUp) - 3.289;

		// 4 
		var Lup = Mup + (1.916 * Math.sin(toRad(Mup))) + (0.020 * Math.sin(toRad(2 * Mup))) + 282.634;

		// make sure Lup and Ldo are in the range [0,360)
		if ( Lup >= 360 ) 	{ Lup -= 360; }
		if ( Lup < 0 ) 		{ Lup += 360; }

		// 5a
		var RAup = toDeg( Math.atan( 0.91764 * Math.tan( toRad(Lup) ) ) );
		// make sure RAup and RAdo are in the range [0,360)
		if ( RAup >= 360 ) 	{ RAup -= 360; }
		if ( RAup < 0 ) 	{ RAup += 360; }
		
		// 5b
		var LquadrantUp  = ( Lup / 90 ).toNumber() * 90;
		var RAquadrantUp = ( RAup / 90 ).toNumber() * 90;
		RAup += LquadrantUp - RAquadrantUp;

		// 5c
		RAup /= 15;

		// 6
		var sinDecUp = 0.39782 * Math.sin(toRad(Lup));	// in rads
		var cosDecUp = Math.cos(Math.asin(sinDecUp));

		// 7a
		var cosHup = ( Math.cos(zenith) - (sinDecUp * Math.sin(latitude)) ) / ( cosDecUp * Math.cos(latitude) );
		// if (cosH >  1) the sun never rises on this location (on the specified date)
		// if (cosH < -1) the sun never sets on this location (on the specified date)

		// 7b
		var Hup = 360 - toDeg( Math.acos(cosHup) );
		Hup /= 15;

		// 8
		var Tup = Hup + RAup - (0.06571 * tUp) - 6.622;

		// 9		
		var UTup = Tup - lngHour;
		// make sure UTup and UTdo are in the Range [0,24)
		if ( UTup >= 24 ) 	{ UTup -= 24; }
		if ( UTup < 0 ) 	{ UTup += 24; }

		// 10
//		var localUp = UTup * 3600;	// in seconds
		var localUp = UTup * 3600 + Sys.getClockTime().timeZoneOffset;

		sunrise = Time.Gregorian.info(Time.today().add(new Time.Duration(localUp)), Time.FORMAT_SHORT);
	}

    function sunSet(year, month, day, latitude, longitude) {
		var zenith = toRad(90.833); 			// in radians

		// 1
    	var N1 = (275 * month / 9).toNumber();
		var N2 = ((month + 9) / 12).toNumber();
		var N3 = 1 + ((year - 4 * (year / 4).toNumber() + 2) / 3).toNumber();
		var N = N1 - (N2 * N3) + day - 30;

		// 2
		var lngHour = toDeg(longitude) / 15;
		var tDo = N + ((18 - lngHour) / 24);

		// 3
		var Mdo = (0.9856 * tDo) - 3.289;

		// 4 
		var Ldo = Mdo + (1.916 * Math.sin(toRad(Mdo))) + (0.020 * Math.sin(toRad(2 * Mdo))) + 282.634;

		// make sure Lup and Ldo are in the range [0,360)
		if ( Ldo >= 360 ) 	{ Ldo -= 360; }
		if ( Ldo < 0 ) 		{ Ldo += 360; }

		// 5a
		var RAdo = toDeg( Math.atan( 0.91764 * Math.tan( toRad(Ldo) ) ) );
		// make sure RAup and RAdo are in the range [0,360)
		if ( RAdo >= 360 ) 	{ RAdo -= 360; }
		if ( RAdo < 0 ) 	{ RAdo += 360; }

		// 5b
		var LquadrantDo  = ( Ldo / 90 ).toNumber() * 90;
		var RAquadrantDo = ( RAdo / 90 ).toNumber() * 90;
		RAdo += LquadrantDo - RAquadrantDo;

		// 5c
		RAdo /= 15;

		// 6
		var sinDecDo = 0.39782 * Math.sin(toRad(Ldo));	// in rads
		var cosDecDo = Math.cos(Math.asin(sinDecDo));

		// 7a
		var cosHdo = ( Math.cos(zenith) - (sinDecDo * Math.sin(latitude)) ) / ( cosDecDo * Math.cos(latitude) );
		// if (cosH >  1) the sun never rises on this location (on the specified date)
		// if (cosH < -1) the sun never sets on this location (on the specified date)
//		Sys.println("cosHup, cosHdo: " + cosHup + ", " + cosHdo);

		// 7b
		var Hdo = toDeg( Math.acos(cosHdo) );
		Hdo /= 15;

		// 8
		var Tdo = Hdo + RAdo - (0.06571 * tDo) - 6.622;

		// 9		
		var UTdo = Tdo - lngHour;
		// make sure UTup and UTdo are in the Range [0,24)
		if ( UTdo >= 24 ) 	{ UTdo -= 24; }
		if ( UTdo < 0 ) 	{ UTdo += 24; }
//		Sys.println("UTup, UTdo: " + UTup + ", " + UTdo);

		// 10
//		var localDo = UTdo * 3600;	// in seconds
		var localDo = UTdo * 3600 + Sys.getClockTime().timeZoneOffset;

		sunset = Time.Gregorian.info(Time.today().add(new Time.Duration(localDo)), Time.FORMAT_SHORT);
		sunset.day = day;
	}

	function moonPhase(year, month, day) {
		var r = ( year % 100 ) % 19;
		if ( r > 9 ){ r -= 19; }
		r = (( r * 11 ) % 30) + month + day;
		if ( month < 3 ){ r += 2; }
		r -= 8.3;
		r = ( r + 0.5 ).toNumber() % 30;
		if ( r < 0 ) { r += 30; }
		moon = r;
//		moon = Math.round(r * 6.66).toNumber(); // in % illuminated
	}	

	function drawMoon(dc){
		var X = 40;
		var Y = 49;
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		dc.drawRectangle(X, Y, 16, 16);

		if ( moon < 15 ) {					// moon growing
			dc.fillRectangle(X + 15 - moon, Y + 1, moon, 14);
		} else {							// moon shrinking
			dc.fillRectangle(X, Y + 1, 15 - (moon - 15), 14);
		}
	}

	function drawActivity(dc, activity, history){
		var maxSteps = 1;

		if ( activity.stepGoal != 0 ) { 		// when activity tracking is on
			for( var i = history.size() - 1; i >= 0 ; i-- ) {
				if ( history[i].steps > maxSteps ) { maxSteps = history[i].steps; }
			}
		
			if ( activity.steps > maxSteps ) { maxSteps = activity.steps; }

			dc.drawText(dc.getWidth()/2, 195, myFontS, (maxSteps / 1000.0).format("%2.1f"), Gfx.TEXT_JUSTIFY_CENTER);
			// steps are variable length somehow so the max keeps changing
//			dc.drawText(dc.getWidth()/2, 195, myFontS, (maxSteps * ratio / 1000.0).format("%2.1f"), Gfx.TEXT_JUSTIFY_CENTER);
			
			drawActivityToday(dc, activity, maxSteps);
			drawActivityPast(dc, history, maxSteps);		// activity for past 7 days
		}
	}

	function drawActivityToday(dc, activity, maxSteps) {
		var X = 182;
		var Y = 141;
		var L = 22;
		var S = 2;

		var lines = ( LINES * activity.steps.toFloat() / maxSteps.toFloat() ).toNumber();

		if ( lines > LINES ) { lines = LINES; }

		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

		var j = 0;
		for( j = 0; j < lines; j++ ) {
			dc.drawLine(X, Y - j * S, X+L, Y - j * S);
		}

		if ( activity.steps > activity.stepGoal ) {
			dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
			dc.drawLine(X, Y - (j-1) * S, 	X+L, Y - (j-1) * S);
			dc.drawLine(X, Y - j * S,		X+L, Y - j * S);
		}
	}

	function drawActivityPast(dc, history, maxSteps) {
		var X = 158;
		var Y = 141;
		var L = 22;
		var S = 2;

		var x = 0;

		for( var i = 0; i < history.size(); i++ ) {
			var lines = ( LINES * history[i].steps.toFloat() / maxSteps.toFloat() ).toNumber();
				
			if ( lines > LINES ) { lines = LINES; }

			dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
			
			var j = 0;
			for ( j = 0; j < lines; j++ ) {
				dc.drawLine( X + x, Y - j * S, X+L + x, Y - j * S );
			}

			if ( history[i].steps > history[i].stepGoal ) {
				dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
				dc.drawLine( X + x, Y - (j-1) * S,	X+L + x, Y - (j-1) * S );
				dc.drawLine( X + x, Y - j * S,		X+L + x, Y - j * S );
			}
			x -= L+2;
		}
	}

    // Update the view
    function onUpdate(dc) {
		View.onUpdate(dc);
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

		var timeNow = Time.now();
		var utcOffset = Sys.getClockTime().timeZoneOffset;	// in seconds

		if ( utcOffset < 0 ) {
			utcOffset *= -1; 		// negate it so we can use .add function below
		}

		var date 		= Time.Gregorian.info(timeNow, Time.FORMAT_SHORT);
		var datem 		= Time.Gregorian.info(timeNow, Time.FORMAT_MEDIUM);
		var dateUTC 	= Time.Gregorian.info(timeNow.add(new Time.Duration(utcOffset)), Time.FORMAT_SHORT);
		var dateTomo 	= Time.Gregorian.info(timeNow.add(new Time.Duration(Time.Gregorian.SECONDS_PER_DAY)), Time.FORMAT_SHORT);

		var batt = Sys.getSystemStats().battery.toNumber();		// battery status

		var gps = Activity.getActivityInfo().currentLocation;	// last known GPS location
//		var alt = Activity.getActivityInfo().altitude;

		if (gps != null) {
			var lat = gps.toRadians()[0];
			var long = gps.toRadians()[1];

			// calculate sunrise and sunset only once a day
			if ( ( sunrise == null ) || ( sunset.day.toNumber() != date.day.toNumber() && date.hour.toNumber() < sunset.hour.toNumber() )) {		// b/w midnight and sunset
				sunRise(date.year.toNumber(), date.month.toNumber(), date.day.toNumber(), lat, long);
				sunSet( date.year.toNumber(), date.month.toNumber(), date.day.toNumber(), lat, long);
			} else if ( sunset.day.toNumber() != dateTomo.day.toNumber() && date.hour.toNumber() >= sunset.hour.toNumber() && date.min.toNumber() >= sunset.min.toNumber() ) { 	// b/w sunset and midnight
				sunRise(dateTomo.year.toNumber(), dateTomo.month.toNumber(), dateTomo.day.toNumber(), lat, long);
				sunSet( dateTomo.year.toNumber(), dateTomo.month.toNumber(), dateTomo.day.toNumber(), lat, long);
			}

			dc.drawText(103, 149, myFontS, sunrise.hour.format("%02d") + ":" + sunrise.min.format("%02d"), Gfx.TEXT_JUSTIFY_RIGHT);
			dc.drawText(115, 149, myFontS, sunset.hour.format("%02d")  + ":" + sunset.min.format("%02d"),  Gfx.TEXT_JUSTIFY_LEFT);
		}

		dc.drawText(dc.getWidth()/2, 20, myFontM, date.month + "M." + date.day + "D." + datem.day_of_week.toUpper(), Gfx.TEXT_JUSTIFY_CENTER);

		dc.drawText(115, 163, myFontS, dateUTC.month + "M." + dateUTC.day + "D", Gfx.TEXT_JUSTIFY_LEFT);
		dc.drawText(103, 163, myFontS, dateUTC.hour.format("%02d") + ":"  + date.min.format("%02d"), Gfx.TEXT_JUSTIFY_RIGHT);
		dc.drawText(dc.getWidth()/2, 45, myFontM, date.hour.format("%02d") + "h" + date.min.format("%02d") + "m", Gfx.TEXT_JUSTIFY_CENTER);

		if 	( todate != date.day.toNumber() ) {			// calculate only once a day
			moonPhase(date.year.toNumber(), date.month.toNumber(), date.day.toNumber());

			todate = date.day.toNumber();
		}

		if ( batt < 20 ) {
			dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
			dc.fillRectangle(116, 181, 32, 11);
			dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
			dc.drawText(117, 177, myFontS, batt+"%", Gfx.TEXT_JUSTIFY_LEFT);			
		} else {
			dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
			dc.drawText(117, 177, myFontS, batt+"%", Gfx.TEXT_JUSTIFY_LEFT);		
		}

		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		dc.drawLine(dc.getWidth()/2, 149, dc.getWidth()/2, 195);
		drawMoon(dc);
//		dc.drawText(103, 177, myFontS, ActivityMonitor.getInfo().steps.toString(), Gfx.TEXT_JUSTIFY_RIGHT);
		dc.drawText(103, 177, myFontS, (ActivityMonitor.getInfo().distance / 100).toString(), Gfx.TEXT_JUSTIFY_RIGHT);

		// figure out how long is a step in meters
		if ( ActivityMonitor.getInfo().distance > 0 && ActivityMonitor.getInfo().steps > 0){
			ratio = (ActivityMonitor.getInfo().distance / 100.0) / ActivityMonitor.getInfo().steps;
		}
		drawActivity(dc, ActivityMonitor.getInfo(), ActivityMonitor.getHistory());

		if (RND == 0){
			dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
			dc.drawLine(dc.getWidth()/2-2, 5, dc.getWidth()/2-2, 15);
			dc.drawLine(dc.getWidth()/2+2, 5, dc.getWidth()/2+2, 15);
		} else {
			dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
			dc.drawLine(dc.getWidth()/2-2, 5, dc.getWidth()/2-2, 15);
			dc.drawLine(dc.getWidth()/2+2, 5, dc.getWidth()/2+2, 15);
		}
    }

    // Called when this View is removed from the screen. Save the state of this View here. This includes freeing resources from memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    	RND = Math.rand() % 2;
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }
}