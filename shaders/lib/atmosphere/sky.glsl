vec3 getLightCasterColor() {
	// Return light color (for clouds)
	vec3 sunColor = vec3(1.0, 0.9, 0.85) * 1.7;
	vec3 moonColor = vec3(0.1373, 0.1294, 0.1294) * 1.1;
	return (getSunAmount() < 1.0) ? moonColor : sunColor;
}

vec3 getMoon(vec3 rd) {
	// Return moon color
	vec3 moonDir = getMoonDir();
    vec3 col = moonAndStars(rd, moonDir);
	col = pow(col, vec3(1.0 / 2.2));

    return col;
}

/* Implementation from https://www.shadertoy.com/view/MdGfzh */
vec3 getSkyColor(vec3 rd, bool doMoonStars) {
	float middayRatio = getMidDayFrac01();
    vec3 sunDir = getSunDir();
	float sunAmount = getSunAmount();
    float sundot = clamp(dot(rd, sunDir), 0.0, 1.0);

	// Rain / dryness factor
	float wetnessFactor = mix(0.0, 0.75, wetness);

    // Upper sky color
	float viewToSunRatio = dot(sunDir, rd) * 0.5 + 0.5;
	viewToSunRatio *= (1.0 - getMidDayFastFrac01());
	vec3 nearSunColor = mix(vec3(2.5), vec3(1.0), middayRatio);
	vec3 farSunColor = vec3(0.302, 0.5451, 1.0);
	vec3 upperSkyDay = mix(farSunColor, nearSunColor, viewToSunRatio);
	vec3 upperSkyNight = vec3(0.0039, 0.0196, 0.0353);
	vec3 col = mix(upperSkyNight, upperSkyDay, max(0.0, sunAmount - wetnessFactor));

    // Lower skycolor
	vec3 lowerSkyDay = vec3(0.612, 0.773, 1) * 1.5;
	vec3 lowerSkyNight = vec3(0.0627, 0.0667, 0.0784);
	vec3 lowerSkyAmount = mix(lowerSkyNight, lowerSkyDay, max(0.0, sunAmount - wetnessFactor));
    col = mix(col, 0.85 * lowerSkyAmount, pow(1.0 - max(rd.y, 0.0), 6.0)) * sunAmount;

	// Moon
	if (doMoonStars) {
		col += getMoon(rd);
	}

    // Sun
	vec3 sunWhiteGlowColor = vec3(1.0);
	
	vec3 sunOuterGlowColor = vec3(0.9725, 0.6784, 0.0471);
	vec3 sunInnerGlowColor = vec3(1.0, 0.7843, 0.4078);
	vec3 sunColor = vec3(1.0, 0.62, 0.05);

	vec3 sunsetOuterGlowColor = vec3(0.9804, 0.4667, 0.0196);
	vec3 sunsetInnerGlowColor = vec3(0.9765, 0.5373, 0.0627);
	vec3 sunriseSunColor = vec3(1.0, 0.6, 0.07);

	vec3 sunriseOuterGlowColor = vec3(1.0, 0.65, 0.08);
	vec3 sunriseInnerGlowColor = vec3(0.99, 0.47, 0.05);
	vec3 sunsetSunColor = vec3(1.0, 0.48, 0.05);

	sunColor = mix(sunColor, sunWhiteGlowColor, easeOutCirc(middayRatio));
	sunInnerGlowColor = mix(sunInnerGlowColor, sunWhiteGlowColor, easeOutCirc(middayRatio));

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

	// Pre-sunrise
	float sunPowerPercentage = getSunRiseSetPercentage();
	float preSunRiseP1 = mix(0.01, 1.0, sunPowerPercentage);
	float preSunRiseP2 = mix(0.01, 1.0, sunPowerPercentage);
	float preSunRiseP3 = mix(0.3, 1.0, sunPowerPercentage);
	float preSunRiseP4 = mix(0.5, 1.0, sunPowerPercentage);

	// Sun power throughout the day and night
	float power1 = mix(3.0, 1.0, easeOutCirc(middayRatio));
	float power2 = mix(6.0, 1.0, easeOutCirc(middayRatio));
	float intensity1 = mix(24.0, 16.0, easeOutCirc(middayRatio));
	float intensity2 = mix(32.0, 24.0, easeOutCirc(middayRatio));
	float concentration1 = mix(4.1, 5.5, easeOutCirc(middayRatio));
	float concentration2 = mix(4.2, 6.6, easeOutCirc(middayRatio));
	float sunPower = easeOutCirc(sunAmount);
	
	// Compute sun color
    col += sunAmount * sunWhiteGlowColor * pow(sundot, concentration1) * sunPower * power1 * preSunRiseP1 * (1.0 - wetnessFactor);
    col += sunAmount * sunInnerGlowColor * pow(sundot, concentration2) * sunPower * power2 * preSunRiseP2 * (1.0 - wetnessFactor);
    col += sunAmount * sunColor * pow(sundot, 64.0) * sunPower * intensity1 * preSunRiseP3 * (1.0 - wetnessFactor);
	col += sunAmount * sunColor * pow(sundot, 128.0) * sunPower * intensity2 * preSunRiseP4 * (1.0 - wetnessFactor);

    return col;
}
