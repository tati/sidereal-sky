# Sidereal Sky

**Your eye on the real sky.**

Western astrology has been off by roughly 23 degrees for 1,800 years due to the precession of the equinoxes. Sidereal Sky shows you where the planets actually were — calculated against the real positions of the constellations, not a fixed ancient snapshot.

Built for the [RevenueCat Shipathon](https://shipathon.revenuecat.com/).

---

## What it does

- **Daily sky screen** — real-time sidereal Sun and Moon positions, sign glyphs, and current moon phase, pulled live from the NASA JPL Horizons API
- **Birth chart** — enter your birth date and time to get your full sidereal natal chart: Sun, Moon, Mercury, Venus, Mars, Jupiter, Saturn, Uranus, Neptune, and Pluto, all calculated to the exact degree
- **Sky Signature** — personalized interpretation text for your sidereal Sun and Moon placements
- **One-time unlock** — birth chart is a $0.99 non-consumable purchase powered by RevenueCat

## Tech stack

- **Flutter** (macOS + iOS)
- **NASA JPL Horizons API** — ephemeris data for all planetary positions
- **Lahiri ayanamsa** — standard Vedic sidereal correction applied to all positions
- **RevenueCat** — purchase management, entitlement checking, restore purchases
- **SharedPreferences** — local caching of birth chart results (JPL only called once per birth date)

## RevenueCat integration

- SDK initialized in `main.dart` with platform-specific API keys
- Entitlement `sidereal_pro` checked on every launch — unlocks instantly if already purchased
- One-time non-consumable product `pro_birth_chart_unlock` at $0.99
- Restore Purchases wired up on the paywall screen
- Birth chart results cached locally — no repeat API calls after first calculation

## Running locally

```bash
flutter pub get
flutter run -d macos   # or -d <your-device-id>
```

Requires Flutter 3.x and Xcode for macOS/iOS targets.

## Privacy

Sidereal Sky does not collect or transmit any personal data. Birth details are stored only on the user's device. Privacy policy: [delphicollective.org/sidereal-sky](https://www.delphicollective.org/sidereal-sky)

---

Repo: [github.com/tati/sidereal-sky](https://github.com/tati/sidereal-sky)

Built by [Valkyrie Agency LLC](https://valkyrie.associates)
