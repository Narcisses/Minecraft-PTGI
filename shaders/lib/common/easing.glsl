float easeOutCirc(float x) {
    // Implementation from: https://easings.net/
    // Easing function takes x into [0.0, 1.0]
    // Returns y to [0.0, 1.0] smoothed
    return sqrt(1.0 - pow(x - 1.0, 2.0));
}

float easeInCirc(float x) {
    // Implementation from: https://easings.net/
    return 1.0 - sqrt(1.0 - pow(x, 2.0));
}

float easeInOutSine(float x) {
    return -(cos(3.1415 * x) - 1.0) / 2.0;
}

float easeInExpo(float x) {
    return (x == 0.0) ? 0.0 : pow(2.0, 10.0 * x - 10.0);
}