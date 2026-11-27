# Sidereal Sky: V1 Launch Checklist

The goal is to get V1 live on the App Store: free, iPhone only, no in-app purchases.
Legend: ✅ done · ⬜ to do · 👩 You (needs your Mac, accounts, or a decision) · 🤖 Z (can be done in the cloud)

---

## Phase 1: Code (🤖)

- ✅ Preserve the RevenueCat paywall on the `archive/revenuecat-paywall` branch (local tag: `v0-revenuecat`)
- ✅ Remove RevenueCat (`purchases_flutter`, `purchases_ui_flutter`), the paywall, and Restore Purchase
- ✅ Make the birth chart free
- ✅ Delete hard-coded Time and Date API keys (`timedate_auth.py`, `astro_service_proper_auth`, `astro_service_timeanddate`)
- ✅ Remove unused packages: `crypto`, `flutter_html`, `win32`, `chewie`
- ✅ Add a 15-second timeout on NASA JPL requests
- ✅ Offline view: "The sky is out of reach", a **Reload the sky** button (top and bottom), and the full "What is sidereal astrology?" explainer
- ✅ Loading state no longer shows fake Aries placeholders
- ✅ Pull-to-refresh, plus automatic refresh when the app reopens after 30+ minutes or after a failed load
- ✅ "What is sidereal?" link on the daily screen opens the explainer
- ✅ **Bug fix:** birth time was sent to NASA as if it were UTC, which shifted the Moon by up to ~7° depending on time zone. It is now converted properly. The old cached chart is discarded automatically (`birth_chart_cache_v2`).
- ✅ Removed the "rising sign" promise from the Birth Time info popup (the app doesn't calculate it yet)
- ✅ Home-screen name changed from "Flutter Application 1" to **Sidereal Sky**
- ✅ iPhone only (`TARGETED_DEVICE_FAMILY = 1`), portrait only
- ✅ `ITSAppUsesNonExemptEncryption = NO` (skips the export-compliance question on every upload)
- ✅ Minimum iOS raised from 12.0 to 13.0
- ✅ Launch screen background changed from white flash to app purple
- ✅ **Placeholder icon** replaced (it was the Flutter logo) with a provisional gold crescent on purple
- ✅ Privacy policy updated: accurate about what goes to NASA, RevenueCat-free, new date
- ✅ README updated
- ✅ Real tests (15) replace the broken counter test: sidereal math, JPL parsing, offline view, and recovery

## Phase 2: On your Mac → your iPhone (👩)

- ✅ `git pull`, then `flutter pub get` (local folder renamed to `sidereal-sky`)
- ✅ `cd ios && pod install`. RevenueCat pods are gone; Flutter also migrated the iOS project to Swift Package Manager and UIScene (committed).
- ✅ Ran in the iOS Simulator (iPhone 16 Plus): daily sky and birth chart both work with live NASA data
- ✅ Git author set to `tati` so commits link to GitHub
- ⬜ Open `ios/Runner.xcworkspace` in Xcode → Runner → Signing & Capabilities → confirm Team and "Automatically manage signing"
- ⬜ **Quick test (next step):** plug in your iPhone (Developer Mode on) → `flutter run --release`
- ⬜ **Real test:** archive → upload to App Store Connect → install with TestFlight (see Phase 3 for the app record)
- ⬜ Live with it for about a week. Things to try:
  - ⬜ Normal open: Sun, Moon, and phase load
  - ⬜ Airplane mode → offline view → turn Wi-Fi back on → Reload the sky
  - ⬜ Pull down to refresh
  - ⬜ Leave the app overnight and reopen it: the date and positions update
  - ⬜ Birth chart: enter your real birth data and check it against a trusted sidereal (Lahiri) chart, e.g. from a Vedic astrology site
  - ⬜ Edit birth data → chart recalculates
  - ⬜ Large text size (Settings → Accessibility → Larger Text): nothing gets cut off
  - ⬜ Smallest iPhone you can find (SE / mini)

## Phase 3: App Store Connect (👩)

- ⬜ Create the app record with bundle ID `org.delphicollective.siderealsky` (check the name "Sidereal Sky" is available)
- ⬜ Subtitle (30 characters), e.g. "Your eye on the real sky"
- ⬜ Description and keywords (Z can draft these)
- ⬜ Category: Lifestyle (most astrology apps) or Reference / Education
- ⬜ Price: Free
- ⬜ App Privacy questionnaire → **Data Not Collected**
- ⬜ Age rating questionnaire (should come out 4+)
- ⬜ Privacy Policy URL: publish the updated `PRIVACY_POLICY.md` at https://www.delphicollective.org/sidereal-sky
- ⬜ Support URL (can be the same site, with a contact email)
- ⬜ Screenshots: 6.9" iPhone (1320 × 2868). Z can help stage them.
- ⬜ Review notes, e.g.: "No account or login. Planetary positions are fetched live from NASA JPL Horizons (ssd.jpl.nasa.gov). If the network is unavailable the app shows an offline explainer with a retry button."
- ⬜ Copyright line (Valkyrie Agency LLC?)
- ⬜ Submit for review 🚀

## Decisions / info needed from you (👩)

- ✅ **Contact email** for the privacy policy: tatiana@valkyrie.associates
- ⬜ Optional: a brand forwarding address (e.g. hello@delphicollective.org) to replace it later
- ⬜ **Real app icon.** The current one is a provisional stand-in. Requirements: 1024 × 1024 PNG, **no transparency** (Apple adds the rounded corners), no text that's too small to read. Z will slice it into every size.
- ⬜ Developer / company name shown on the App Store: Valkyrie Agency LLC vs Delphi Collective?

## Later cleanup

- ⬜ CocoaPods "base configuration" warning for Profile builds (harmless; could finish the move to Swift Package Manager with `pod deintegrate`)

## Known limitations (fine for V1, revisit later)

- Birth time is interpreted in the phone's **current** time zone. Someone born in another time zone gets a slightly shifted Moon. Fix: ask for birth city or time zone (V1.1).
- "Summer Sun / Winter Sun" labels assume the Northern Hemisphere.
- The Lahiri ayanamsa uses a linear approximation (accurate to a few arcminutes; doesn't change signs except at the edges).
- No offline caching of today's sky; it needs a connection each time.

## V2 ideas

- $0.99/month subscription via RevenueCat (start from `archive/revenuecat-paywall`)
- Rising sign (`calculateRisingSign` already exists in `astro_utils.dart`; needs birth location)
- Notifications for sky events: eclipses, sidereal sign seasons, and more (ideas collected in [`SKY_EVENTS.md`](SKY_EVENTS.md))
