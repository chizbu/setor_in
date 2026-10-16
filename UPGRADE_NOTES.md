# Setor.in mobile — upgrade notes

## Environment / security

- The mobile app does not read or package a `.env` file. Laravel's `.env` is server-side configuration and is not accessible to the Flutter client.
- The public API URL is supplied at compile time with `--dart-define=API_BASE_URL=...`; the development default is `http://10.0.2.2:8000/api` for Android Emulator only.
- For production, set the GitHub Actions repository variable `API_BASE_URL` to the team's real HTTPS API URL. Version-tag builds are rejected if this variable is missing or not HTTPS.
- The URL is public configuration, **not a secret**. Anyone can extract values bundled in an APK.
- Never place Laravel `APP_KEY`, Gemini API key, SMTP password, Firebase service-account JSON/private key, or Midtrans credentials in Flutter or `--dart-define`. Those belong only on the backend server.

## Current upgrade scope and backend dependency

The existing mobile app and `haris3n/setorin_backend` are Proyek 2 implementations. Mobile previously hard-coded `http://127.0.0.1:8000/api`; the backend does not expose that host to an Android emulator and its routes remain the legacy contract. The upgrade uses compile-time API URL configuration, adds a single-partner Rumah Hijau location screen, price listing, and deposit history mapped to the available legacy transaction route; it intentionally does not invent fallback partner/contact data.

This mobile client currently finds these legacy routes in the backend: `/register`, `/verify-otp`, `/login`, `/nasabah/profil`, `/nasabah/transaksi`, `/nasabah/saldo`, `/nasabah/edukasi`, `/nasabah/notifikasi`, and `/nasabah/bank-sampah`. In contrast, the PRD contract includes `/api/v1`, customer-specific prices, `saldo tersedia/ditahan`, transfer PIN and approval, Google auth, chatbot, FAQ, customer schedules/location, device token, forgotten password, and a non-sensitive random customer QR. Most are **not implemented** in the backend repository as inspected. Do not present them as live functionality until that API work and end-to-end integration are delivered.

The legacy API also still exposes coin, mission, multiple-bank and customer-side deposit-confirmation behavior that the PRD removes. The upgraded entry navigation no longer routes users to the legacy coin/finance screen or mission view. Existing orphaned files remain in the repository for the team to remove as part of the coordinated migration. The mobile UI upgrade should be completed alongside backend contract migration; stale backend behavior must not be treated as PRD-compliant.

This PR is a foundation, **not an assertion that the mobile acceptance criteria for all F1/F2 features are complete**. Registration/login still follow the legacy contract, OTP is not production-safe in the current backend, and transfer/PIN, Google Sign-In, chatbot, FCM, and server-computed schedule status require backend/API implementation and end-to-end tests first.

## PRD implementation status

The latest mobile changes and the requirement-by-requirement blockers are listed in [`PRD_MOBILE_STATUS_ID.md`](PRD_MOBILE_STATUS_ID.md). They add registration validation/address, safe profile editing, honest QR/balance/price/history states, Rumah Hijau-only data selection, FAQ cleanup, removal of simulated OTP actions, and inbox cleanup. Widget tests pass and a Web release build compiles. Android installation was not verified locally because this sandbox has no Android SDK/emulator.
