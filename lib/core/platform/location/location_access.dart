/// Whether the app may read the device's position.
enum LocationAccess {
  /// The customer allowed it: the position can be read.
  allowed,

  /// Not allowed yet, but the system can still ask (never asked, or refused once on a phone).
  askable,

  /// Refused for good: only the customer changing it in the browser or the system settings helps. A browser never asks a
  /// second time after a refusal, so on the web a refusal is always this.
  blocked,
}
