//! Mixes two 0xRRGGBB colors: t = 0 gives a, t = 1 gives b
function blendColor(a, b, t)
{
    var red = ((a >> 16) & 0xFF) + ((((b >> 16) & 0xFF) - ((a >> 16) & 0xFF)) * t);
    var green = ((a >> 8) & 0xFF) + ((((b >> 8) & 0xFF) - ((a >> 8) & 0xFF)) * t);
    var blue = (a & 0xFF) + (((b & 0xFF) - (a & 0xFF)) * t);
    return (red.toNumber() << 16) | (green.toNumber() << 8) | blue.toNumber();
}
