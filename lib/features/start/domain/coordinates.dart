/// A point on the map, in degrees: `latitude` from -90 to 90 north of the equator and `longitude` from -180 to 180 east of
/// the prime meridian.
///
/// A record, so two points with the same values are equal and a screen can ask for the restaurants around the same
/// point once. The point is the customer's position (personal data) or a restaurant's: never log it.
typedef Coordinates = ({double latitude, double longitude});
