vec3 getLightCasterColor() {
	// Return light color (for clouds)
	vec3 sunColor = vec3(1.0, 0.9, 0.85) * 1.7;
	vec3 moonColor = vec3(0.1373, 0.1294, 0.1294) * 1.1;
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
    vec3 sunDir = getSunDir();
	float sunAmount = getSunAmount();
    float sundot = clamp(dot(rd, sunDir), 0.0, 1.0);

	// Rain / dryness factor
	float wetnessFactor = mix(0.0, 0.85, wetness);

    // Upper sky color
	float viewToSunRatio = dot(sunDir, rd) * 0.5 + 0.5;
	// viewToSunRatio *= (1.0 - getMidDayFastFrac01());
	vec3 nearSunColor = mix(vec3(2.45), vec3(0.42, 0.63, 1.0) * 1.01, middayRatio);
	vec3 farSunColor = vec3(0.34, 0.59, 1.0) * 1.1;
	vec3 upperSkyDay = mix(farSunColor, nearSunColor, viewToSunRatio);
	vec3 rainSkyColor = vec3(0.02, 0.07, 0.21);
	upperSkyDay = mix(upperSkyDay, rainSkyColor, wetness);
	vec3 upperSkyNightColor = vec3(0.09, 0.08, 0.17) * 1.5; //vec3(0.0039, 0.0196, 0.0353);
	vec3 col = mix(upperSkyNightColor, upperSkyDay, max(0.0, sunAmount));

    // Lower skycolor
	vec3 lowerSkySunRiseColor = vec3(0.84, 0.94, 1.0) * 3.5;
	vec3 lowerSkyDayColor = vec3(0.53, 0.73, 1.0) * 1.9;
	vec3 lowerSkyDayMixedColor = mix(lowerSkySunRiseColor, lowerSkyDayColor, middayRatio);
	vec3 lowerSkyNightColor = vec3(0.0627, 0.0667, 0.0784);
	vec3 lowerRainSkyColor = vec3(0.22, 0.24, 0.28) * 2.75;
	lowerSkyDayMixedColor = mix(lowerSkyDayMixedColor, lowerRainSkyColor, wetness);
	vec3 lowerSkyAmount = mix(lowerSkyNightColor, lowerSkyDayMixedColor, max(0.0, sunAmount));
    col = mix(col, 0.85 * lowerSkyAmount, pow(1.0 - max(rd.y, 0.0), 4.0)) * sunAmount;

	// Moon
	if (doMoonStars) {
		col += getMoon(rd);
	}

    // Sun
	vec3 sunWhiteGlowColor = vec3(1.0);
	
	vec3 sunOuterGlowColor = vec3(1.0, 0.75, 0.15);
	vec3 sunInnerGlowColor = vec3(0.99, 0.51, 0.04);
	vec3 sunColor = vec3(1.0, 0.4, 0.02);

	vec3 sunsetOuterGlowColor = vec3(1.0, 0.62, 0.13);
	vec3 sunsetInnerGlowColor = vec3(1.0, 0.45, 0.01);
	vec3 sunriseSunColor = vec3(1.0, 0.47, 0.07);

	vec3 sunriseOuterGlowColor = vec3(1.0, 0.42, 0.03);
	vec3 sunriseInnerGlowColor = vec3(0.99, 0.47, 0.05);
	vec3 sunsetSunColor = vec3(1.0, 0.45, 0.0);

	sunColor = mix(sunColor, sunWhiteGlowColor, middayRatio);
	sunInnerGlowColor = mix(sunInnerGlowColor, sunWhiteGlowColor, middayRatio);

	if (worldTime > 0 && worldTime < 12000) {
		// Sunrise
		sunOuterGlowColor = mix(sunriseOuterGlowColor, sunOuterGlowColor, middayRatio);
		sunInnerGlowColor = mix(sunriseInnerGlowColor, sunInnerGlowColor, middayRatio);
		sunColor = mix(sunriseSunColor, sunColor, middayRatio);
	}

	if (worldTime > 12000) {
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
	float power1 = mix(2.1, 3.0, easeOutCirc(middayRatio)) * rainLessLight;
	float power2 = mix(2.5, 2.0, easeOutCirc(middayRatio)) * rainLessLight;
	float intensity1 = mix(10.5, 10.0, easeOutCirc(middayRatio)) * rainLessLight;
	float intensity2 = mix(18.5, 16.0, easeOutCirc(middayRatio)) * rainLessLight;
	float concentration1 = mix(4.0, 9.5, easeOutCirc(middayRatio)) * rainLessLight;
	float concentration2 = mix(4.5, 12.0, easeOutCirc(middayRatio)) * rainLessLight;

	// Sun shines brightly when looking at it
	vec3 vd = getRayDir(vec2(0.5));

	float power = 1.0;
	if (dot(vd, sunDir) <= 0.0) {
		power = 2.0;
	} else {
		power = clamp(pow(easeInCirc(dot(vd, sunDir)), 2.0) * 72.0, 2.0, 72.0);
	}
    
	// Compute sun color
	col += sunAmount * sunWhiteGlowColor * pow(sundot, concentration1) * power1 * preSunRiseP1 * rainLessLight;
	col += sunAmount * sunOuterGlowColor * pow(sundot, concentration2) * power2 * preSunRiseP2 * rainLessLight;
	col += sunAmount * sunInnerGlowColor * pow(sundot, concentration1) * intensity1 * preSunRiseP3 * rainLessLight;
	col += sunAmount * sunColor * pow(sundot, concentration1) * intensity2 * preSunRiseP4 * rainLessLight;

	if (!fast)
		col += sunAmount * sunColor * pow(sundot, 512.0) * power * intensity2 * preSunRiseP4 * rainLessLight * rainLessLight;

    return max(vec3(0.0), col);
}
