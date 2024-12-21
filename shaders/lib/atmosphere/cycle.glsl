float getSunAmount() {
	float sunsetStart = 12000.;
	float sunsetEnd = 13000.;

	float sunriseStart = 22000.;
	float sunriseEnd = 24000.;

	// If in between 0 and 12000 => 1.0
	// If between 14000 and 22000 => 0.0
	// Else, interpolation
	float amount = 0.0;

	// Day
	if (worldTime >= 0 && worldTime < sunsetStart) {
		amount = 1.0;
	}
	// Night
	else if (worldTime >= sunsetEnd && worldTime < sunriseStart) {
		amount = 0.0;
	}
	// Sunrise
	else if (worldTime >= sunriseStart && worldTime < sunriseEnd) {
		amount = mapRange(worldTime, sunriseStart, sunriseEnd, 0.0, 1.0);
	}
	// Sunset
	else if (worldTime >= sunsetStart && worldTime < sunsetEnd) {
		amount = mapRange(worldTime, sunsetStart, sunsetEnd, 1.0, 0.0);
	}

	return amount;
}

float getMidDayFrac01() {
	// Return 0-1.0 from start day to midday
	// Roll back from 1.0-0 from midday to end day
	// Return 0.0 if night
	float startDay = 0.0;
	float midDay = 6000.0;
	float endDay = 13000;

	float t = 0.0;

	if (worldTime >= startDay && worldTime <= midDay) {
		t = mapRange(worldTime, startDay, midDay, 0.0, 1.0);
	} else if (worldTime > midDay && worldTime <= endDay) {
		t = mapRange(worldTime, midDay, endDay, 1.0, 0.0);
	}

	return t;
}

float getMidDayFastFrac01() {
	// Return 0-1.0 from start day to midday
	// Roll back from 1.0-0 from midday to end day
	// Return 0.0 if night
	float startDay = 0.0;
	float beforeMidday = 2000.0;
	float afterMidday = 10000.0;
	float endDay = 13000;

	float t = 0.0;

	if (worldTime >= startDay && worldTime <= beforeMidday) {
		t = mapRange(worldTime, startDay, beforeMidday, 0.0, 1.0);
	} else if (worldTime > beforeMidday && worldTime <= afterMidday) {
		t = 1.0;
	} else if (worldTime > afterMidday && worldTime <= endDay) {
		t = mapRange(worldTime, afterMidday, endDay, 1.0, 0.0);
	}

	return t;
}

float getSunRiseSetPercentage() {
	// Return 0.0-1.0 from start pre sunrise and start sunrise
	// Return 1.0-0.0 from pre sunset to sunset
	// Return 1.0 if day
	// Return 0.0 if night
	float preSunrise = 23000;
	float sunRise = 24000;
	float preSunset = 12000;
	float sunset = 13000;

	float t = 0.0;

	if (worldTime > 1000.0 && worldTime < preSunset) {
		return 1.0;
	} else if (worldTime > sunset && worldTime < preSunrise) {
		return 0.0;
	}

	if ((worldTime >= 0.0 && worldTime <= 1000.0) || (worldTime >= preSunrise && worldTime < sunRise)) {
		float newWT = (worldTime >= 0.0 && worldTime <= 1000.0) ? worldTime + 24000 : worldTime;
		t = mapRange(newWT, preSunrise, sunRise, 0.0, 1.0);
	}

	if (worldTime >= preSunset && worldTime <= sunset) {
		t = mapRange(worldTime, preSunset, sunset, 0.0, 1.0);
		t = 1.0 - t;
	}

	return t;
}

float getFastSunsetPercentage() {
	float preSunset = 12000;
	float sunset = 13000;
	float preSunrise = 23000;
	float sunrise = 24000;

	float t = 0.0;

	if (worldTime >= preSunset && worldTime <= sunset) {
		t = mapRange(worldTime, preSunset, sunset, 0.0, 1.0);
	} else if (worldTime >= sunset && worldTime < preSunrise) {
		t = 1.0;
	} else if (worldTime >= preSunrise) {
		t = mapRange(worldTime, preSunrise, sunrise, 0.0, 1.0);
		t = 1.0 - t;
	}

	return t;
}

float getNightAmount() {
    // Return 0.0-1.0 from start night to midnight
    // Return 1.0-0.0 from midnight to end night
    // Return 0.0 otherwise

    float startNight = 13000;
    float midnight = 18000;
    float endNight = 23000;

	float t = 0.0;

	if (worldTime >= startNight && worldTime <= midnight) {
		t = mapRange(worldTime, startNight, midnight, 0.0, 1.0);
	} else if (worldTime > midnight && worldTime <= endNight) {
		t = mapRange(worldTime, midnight, endNight, 1.0, 0.0);
	}

    return t;
}

float getFogAmount() {
    // Lots of fog when sunset to hide sky-clouds border
	// In order to make beautiful blending

	return 0.0;
}

float getBloomAlphaAmount() {
	// Very small bloom for sunrise and sunset to avoid too much bloom light
	float sunriseStart = 23000;
	float sunriseEnd = 24000;
	float sunsetStart = 11500;
	float sunsetEnd = 13000;
	float alphalo = 0.0005;
	float alphahi = 0.0015;
	float alpha0 = 0.00005;

	float t = alphahi;

	if (worldTime >= sunriseStart) {
		t = mapRange(worldTime, sunriseStart, sunriseEnd, alphalo, alphahi);
	} else if (worldTime >= sunsetStart && worldTime <= sunsetEnd) {
		t = mapRange(worldTime, sunsetStart, sunsetEnd, alphahi, alpha0);
	} else if (worldTime > sunsetEnd && worldTime < sunriseStart) {
		t = alpha0;
	}

	return t;
}

vec3 getSunPosition() {
	return mat3(gbufferModelViewInverse) * sunPosition;
}

vec3 getMoonPosition() {
	return mat3(gbufferModelViewInverse) * moonPosition;
}

vec3 getSunDir() {
    // Compute sun direction in world space
    return normalize(getSunPosition());
}

vec3 getMoonDir() {
    // Compute moon direction in world space
    return normalize(getMoonPosition());
}

vec3 getLightCasterDir() {
	// Return sun color if day else moon color
	if (worldTime > 13000) {
		getMoonDir();
	} else {
		getSunDir();
	}
	return getMoonDir();// (getSunAmount() <= 0.01) ? getMoonDir() : getSunDir();
}
