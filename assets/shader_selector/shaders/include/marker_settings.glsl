
// vve screen-roll control channel. Channel 0 is reserved internally for time.
#define VVE_ROLL_ANGLE_CHANNEL 2

/*
signature:
 ADD_MARKER(channel, green, alpha, op, rate)
*/
// green=251 sets the roll angle instantly.
// green=252 linearly interpolates to the roll angle using cyclic shortest-path motion.
#define LIST_MARKERS ADD_MARKER(VVE_ROLL_ANGLE_CHANNEL, 251, 251, 0, 0.0) ADD_MARKER(VVE_ROLL_ANGLE_CHANNEL, 252, 251, 2, 1.8)

#define MARKER_RED 254

// Screen pixel that the marker ends up on if it uses channel k:
// Mapping follows structure that is like an inverted cantor pairing (but only producing coordinates with an even sum)
#define MARKER_POS(k) (ivec2(2*int(ceil(sqrt(float(k))) - 1.0),0) + (k - int((ceil(sqrt(float(k))) - 1.0)*(ceil(sqrt(float(k))) - 1.0)) - 1)*ivec2(-1, 1))
