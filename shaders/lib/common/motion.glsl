vec2 calcVelocity(vec4 newPos, vec4 oldPos) {
	oldPos /= oldPos.w;
	oldPos.xy = (oldPos.xy + 1) / 2.0;
	oldPos.y = 1 - oldPos.y;

	newPos /= newPos.w;
	newPos.xy = (newPos.xy + 1) / 2.0;
	newPos.y = 1 - newPos.y;

	return (oldPos - newPos).xy;
}
