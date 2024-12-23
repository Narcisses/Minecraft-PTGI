vec3 getLightCasterColor() {
	// Return light color (for clouds)
	vec3 sunColor = vec3(1.0, 0.9, 0.85) * 1.7;
	vec3 moonColor = vec3(0.15, 0.16, 0.2) * 1.01;
	vec3 rainColor = vec3(0.0);
	
	sunColor = mix(sunColor, rainColor, wetness);
	moonColor = mix(moonColor, rainColor, wetness);

	return (getSunAmount() < 1.0) ? moonColor : sunColor;
}

vec3 getMoon(vec3 rd) {
	// Return moon color
	vec3 moonDir = getMoonDir();
    vec3 col = moonAndStars(rd, moonDir);
	col = pow(col, vec3(1.0 / GAMMA));

    return col;
}

/* Implementation from https://www.shadertoy.com/view/MdGfzh */
vec3 getSkyColor(vec3 rd, bool doMoonStars, bool fast) {
	float middayRatio = getMidDayFrac01();
	float middayNormalAmount = getMidDayNormalFrac01();
	vec3 sunPos = getSunPosition();
    vec3 sunDir = getSunDir();
	float sunAmount = getSunAmount();
    float sundot = clamp(dot(rd, sunDir), 0.0, 1.0);

	// Rain / dryness factor
	float wetnessFactor = mix(0.0, 0.85, wetness);

    // Upper sky color
	float viewToSunRatio = dot(sunDir, rd) * 0.5 + 0.5;
	// viewToSunRatio *= 1.0 - getMidDayFastFrac01();
	vec3 nearSunColor = mix(vec3(2.45), vec3(0.42, 0.63, 1.0) * 1.01, middayRatio);
	vec3 farSunColorSunrise = vec3(0.16, 0.47, 1.0) * 1.1;
	vec3 farSunColorMidday = vec3(0.25, 0.51, 1.0) * 1.1;
	vec3 farSunColor = mix(farSunColorSunrise, farSunColorMidday, middayNormalAmount);
	vec3 upperSkyDay = mix(farSunColor, nearSunColor, viewToSunRatio);
	vec3 rainSkyColor = vec3(0.02, 0.07, 0.21);
	upperSkyDay = mix(upperSkyDay, rainSkyColor, wetness);
	vec3 upperSkyNightColor = vec3(0.09, 0.08, 0.17) * 1.5; //vec3(0.0039, 0.0196, 0.0353);
	vec3 col = mix(upperSkyNightColor, upperSkyDay, max(0.0, sunAmount));

    // Lower skycolor
	vec3 lowerSkySunRiseColor = vec3(0.84, 0.94, 1.0) * 3.5;
	vec3 lowerSkyDayColor = vec3(0.5, 0.71, 0.99) * 1.9;
	vec3 lowerSkyDayMixedColor = mix(lowerSkySunRiseColor, lowerSkyDayColor, middayRatio);
	vec3 lowerSkyNightColor = vec3(0.0627, 0.0667, 0.0784);
	vec3 lowerRainSkyColor = vec3(0.16, 0.18, 0.21) * 2.75;
	lowerSkyDayMixedColor = mix(lowerSkyDayMixedColor, lowerRainSkyColor, wetness);
	vec3 lowerSkyAmount = mix(lowerSkyNightColor, lowerSkyDayMixedColor, clamp(sunAmount, 0.0, 1.0));
    col = mix(col, 0.85 * lowerSkyAmount, pow(1.0 - max(rd.y, 0.0), 4.0)) * sunAmount;

	// Moon
	if (doMoonStars) {
		col += getMoon(rd);
	}

    // Sun
	vec3 sunWhiteGlowColor = vec3(0.77, 0.85, 1.0);
	
	vec3 sunOuterGlowColor = vec3(1.0, 0.54, 0.13);
	vec3 sunInnerGlowColor = vec3(0.99, 0.51, 0.04);
	vec3 sunColor = vec3(1.0, 0.3, 0.0);

	vec3 sunsetOuterGlowColor = vec3(1.0, 0.54, 0.07);
	vec3 sunsetInnerGlowColor = vec3(1.0, 0.45, 0.01);
	vec3 sunriseSunColor = vec3(1.0, 0.3, 0.0);

	vec3 sunriseOuterGlowColor = vec3(1.0, 0.42, 0.03);
	vec3 sunriseInnerGlowColor = vec3(0.99, 0.47, 0.05);
	vec3 sunsetSunColor = vec3(1.0, 0.45, 0.0);

	sunColor = mix(sunColor, sunWhiteGlowColor, easeOutCirc(middayNormalAmount));
	sunInnerGlowColor = mix(sunInnerGlowColor, sunWhiteGlowColor, easeOutCirc(middayNormalAmount));

	if (worldTime > 0 && worldTime < 12500) {
		// Sunrise
		sunOuterGlowColor = mix(sunriseOuterGlowColor, sunOuterGlowColor, middayRatio);
		sunInnerGlowColor = mix(sunriseInnerGlowColor, sunInnerGlowColor, middayRatio);
		sunColor = mix(sunriseSunColor, sunColor, middayRatio);
	}

	if (worldTime > 12500) {
		// Sunset
		sunOuterGlowColor = mix(sunsetOuterGlowColor, sunOuterGlowColor, middayRatio);
		sunInnerGlowColor = mix(sunsetInnerGlowColor, sunInnerGlowColor, middayRatio);
		sunColor = mix(sunsetSunColor, sunColor, middayRatio);
	}

	// Sunset goes down
	float sunsetLessLight = mix(1.0, 0.0, getFastSunsetPercentage()); 

	// Pre-sunrise
	float sunPowerPercentage = getSunRiseSetPercentage();
	float preSunRiseP1 = mix(0.01, 1.0, sunPowerPercentage);
	float preSunRiseP2 = mix(0.01, 1.0, sunPowerPercentage);
	float preSunRiseP3 = mix(0.3, 1.0, sunPowerPercentage);
	float preSunRiseP4 = mix(0.5, 1.0, sunPowerPercentage);

	// Rain
	float rainLessLight = max(0.01, (1.0 - wetness) * sunsetLessLight);

	// Sun power throughout the day and night
	float power1 = mix(2.0, 2.0, middayRatio) * rainLessLight;
	float power2 = mix(2.15, 2.0, middayRatio) * rainLessLight;
	float intensity1 = mix(4.5, 2.0, middayRatio) * rainLessLight;
	float intensity2 = mix(6.5, 2.0, middayRatio) * rainLessLight;
	float intensity3 = mix(8.5, 8.0, middayRatio) * rainLessLight;
	float concentration1 = mix(4.0, 8.5, middayRatio) * rainLessLight;
	float concentration2 = mix(4.5, 10.0, middayRatio) * rainLessLight;

	// Sun shine power
	float power = 18.0;
    
	// Compute sun color
	col += sunAmount * sunWhiteGlowColor * pow(sundot, concentration1) * power1 * preSunRiseP1 * rainLessLight;
	col += sunAmount * sunOuterGlowColor * pow(sundot, concentration2) * power2 * preSunRiseP2 * rainLessLight;
	col += sunAmount * sunInnerGlowColor * pow(sundot, concentration2) * intensity1 * preSunRiseP3 * rainLessLight;
	col += sunAmount * sunColor * pow(sundot, concentration1) * intensity2 * preSunRiseP4 * rainLessLight;

	if (!fast && hitSphere(sunPos, 8.0, vec3(0.0), rd) && dot(rd, sunDir) > 0)
		col += sunAmount * sunColor * power * intensity3 * preSunRiseP4 * pow(rainLessLight, 4.0);

    return max(vec3(0.0), col);
}
