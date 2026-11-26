# Sidereal Sky

**Your eye on the real sky.**

Western astrology has been off by roughly 23 degrees for 1,800 years due to the precession of the equinoxes. Sidereal Sky shows you where the planets actually were — calculated against the real positions of the constellations, not a fixed ancient snapshot.

Originally prototyped for the [RevenueCat Shipathon](https://shipathon.revenuecat.com/). **Version 1 is free with no in-app purchases.** The Shipathon paywall is preserved on the `archive/revenuecat-paywall` branch for a future version.

---

## What it does

- **Daily sky screen**: real-time sidereal Sun and Moon positions, sign glyphs, and current moon phase, pulled live from the NASA JPL Horizons API
- **Offline view**: if NASA can't be reached, a "Reload the sky" button plus a short explainer of what sidereal astrology is
- **What is sidereal?**: the same explainer, one tap away from the daily screen
- **Birth chart (free)**: enter your birth date and time to get your sidereal natal chart: Sun, Moon, Mercury, Venus, Mars, Jupiter, Saturn, Uranus, Neptune, and Pluto
- **Sky Signature**: personalized interpretation text for your sidereal Sun and Moon placements

## Tech stack

- **Flutter** (iOS, iPhone only for v1)
- **NASA JPL Horizons API**: ephemeris data for all planetary positions (15s timeout, graceful offline state)
- **Lahiri ayanamsa**: standard Vedic sidereal correction applied to all positions
- **SharedPreferences**: local caching of birth chart results (JPL only called once per birth date)

## Running locally

```bash
flutter pub get
flutter test
flutter run            # pick your iPhone or a simulator
```

## Shipping

See [`LAUNCH_CHECKLIST.md`](LAUNCH_CHECKLIST.md) for the App Store launch checklist.
