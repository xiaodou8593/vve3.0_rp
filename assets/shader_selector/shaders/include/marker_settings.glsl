// Persistent data rows. Row 0 is reserved for GameTime by data.fsh.
#define FAKE_FOV_CHANNEL 1
// A single 16-bit roll packet is split into two 8-bit channels.
#define VVE_ROLL_ANGLE_HIGH_CHANNEL 2
#define VVE_ROLL_ANGLE_LOW_CHANNEL 3
/*
Marker signature:
    ADD_MARKER(channel, green, alpha, operation, rate)

FakeFOV:
    green 253: instant set
    green 252: smooth constant-rate transition

Rotation:
    green 251: instant set (initialization / teleport)
    green 200..215: cyclic constant-rate tracking at 16 speed grades
*/
#define LIST_MARKERS \
    ADD_MARKER(FAKE_FOV_CHANNEL, 253, 251, 0, 0.0) \
    ADD_MARKER(FAKE_FOV_CHANNEL, 252, 251, 1, 2.0) \
    ADD_MARKER(VVE_ROLL_ANGLE_HIGH_CHANNEL, 251, 251, 2, 3.2) \
    ADD_MARKER(VVE_ROLL_ANGLE_LOW_CHANNEL, 250, 251, 3, 2.9)


#define MARKER_RED 254

// Screen pixel that the marker ends up on if it uses channel k.
// Mapping follows an inverted Cantor-pairing-like structure.
#define MARKER_POS(k) (ivec2(2*int(ceil(sqrt(float(k))) - 1.0),0) + (k - int((ceil(sqrt(float(k))) - 1.0)*(ceil(sqrt(float(k))) - 1.0)) - 1)*ivec2(-1, 1))
