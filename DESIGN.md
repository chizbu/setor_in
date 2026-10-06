---
name: Setor.in — Rumah Hijau (Mobile Nasabah Android)
platform: Android mobile only
product_scope: Nasabah mobile app only
orientation: portrait-first
web_scope: none
colors:
  surface: '#FFFFFF'
  surface-dim: '#F5F7FA'
  surface-bright: '#FFFFFF'
  surface-container-lowest: '#FFFFFF'
  surface-container-low: '#FAFCFB'
  surface-container: '#F5F7FA'
  surface-container-high: '#EEF2EF'
  surface-container-highest: '#E2E8E3'
  on-surface: '#1A1A2E'
  on-surface-variant: '#667085'
  inverse-surface: '#1A1A2E'
  inverse-on-surface: '#FFFFFF'
  outline: '#98A2B3'
  outline-variant: '#E4E7EC'
  surface-tint: '#0D9146'
  primary: '#0D9146'
  on-primary: '#FFFFFF'
  primary-container: '#E8F8EF'
  on-primary-container: '#0A7A3A'
  inverse-primary: '#26D077'
  secondary: '#2F6F44'
  on-secondary: '#FFFFFF'
  secondary-container: '#EAF5EC'
  on-secondary-container: '#194729'
  tertiary: '#3B82F6'
  on-tertiary: '#FFFFFF'
  tertiary-container: '#DBEAFE'
  on-tertiary-container: '#1E3A8A'
  error: '#EF4444'
  on-error: '#FFFFFF'
  error-container: '#FEE2E2'
  on-error-container: '#991B1B'
  warning: '#F59E0B'
  success: '#0D9146'
  info: '#3B82F6'
  background: '#F5F7FA'
  on-background: '#1A1A2E'
typography:
  display-lg:
    fontFamily: Poppins
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Poppins
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Poppins
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 30px
    letterSpacing: -0.01em
  title-md:
    fontFamily: Poppins
    fontSize: 18px
    fontWeight: '700'
    lineHeight: 26px
    letterSpacing: 0
  body-lg:
    fontFamily: Poppins
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0
  body-md:
    fontFamily: Poppins
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 21px
    letterSpacing: 0
  body-bold:
    fontFamily: Poppins
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 21px
    letterSpacing: 0
  label:
    fontFamily: Poppins
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 18px
    letterSpacing: 0.01em
  stat-lg:
    fontFamily: Poppins
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.02em
rounded:
  sm: 0.5rem
  DEFAULT: 0.75rem
  md: 1rem
  lg: 1.25rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  xxl: 40px
  gutter: 16px
  margin-mobile: 20px
---

# Design System: Setor.in — Rumah Hijau — Mobile Nasabah Android

> **Strict scope:** This DESIGN.md defines the UI/UX for the **Setor.in Android mobile application used by Nasabah only**. It does **not** define Web Petugas, Web Admin, desktop, tablet, landscape, or responsive web layouts. Do not generate dashboard/web navigation patterns from this file.

## 1. Visual Theme & Atmosphere

Setor.in Proyek 3 is a focused digital bank-sampah companion for **Rumah Hijau**. The visual direction should feel **fresh, trustworthy, practical, warm, and community-oriented** rather than gamified. The interface is built around one clear promise: users bring clean, sorted recyclable waste to Rumah Hijau, receive a transparent rupiah value based on weight and the active purchase price, and can track that value from one place.

The redesign is intentionally a **major UI refresh of the previous Setor.in mobile application**, not a new unrelated visual identity. The target is a portrait-oriented Android phone experience; every screen, component, spacing decision, and interaction must be optimized for touch on a mobile device. Preserve the previous application's recognizable green foundation and rounded Material 3 language, but remove the visual emphasis on features that no longer exist in Proyek 3. The old product currently uses Poppins, green primary tones, soft cards, a green gradient header, and a pill-shaped bottom navigation. These patterns can be evolved, not discarded.

The visual hierarchy should prioritize **money, waste transactions, QR identity, operating status, and next actions**. Avoid decorative gamification, excessive gradients, dense dashboards, or generic recycling illustrations that compete with the actual task. Use real-world, understandable labels in Bahasa Indonesia.

## 2. Color Palette & Roles

### Primary Foundation

- **Rumah Hijau Green (#0D9146):** primary action color, active navigation, important links, success states, and brand emphasis.
- **Deep Green (#0A7A3A):** darker brand anchor for high-emphasis surfaces, selected states, and strong contrast areas.
- **Fresh Green (#26D077):** supportive accent for highlights and subtle progress/confirmation moments. Use sparingly; do not make every component gradient-based.
- **Soft Green (#E8F8EF):** tinted container for selected states, informational callouts, chips, and subtle section backgrounds.
- **Mist Background (#F5F7FA):** main app canvas; creates separation between white cards without becoming visually heavy.
- **White Surface (#FFFFFF):** cards, bottom sheets, form fields, modal surfaces, and primary content containers.

### Accent & Interactive

- **Info Blue (#3B82F6):** neutral informational states such as date/schedule information, helper links, and status explanations.
- **Warning Amber (#F59E0B):** warnings that require attention but are not errors, such as a closed schedule or pending action.
- **Error Red (#EF4444):** validation errors, failed exchange requests, locked PIN state, destructive actions, and emergency warnings.
- **Success Green (#0D9146):** completed setoran and successful saldo exchange. Keep semantics consistent with the primary brand green.

### Typography & Text Hierarchy

- **Primary Ink (#1A1A2E):** headings, important numerical values, primary body text.
- **Secondary Ink (#667085):** supporting copy, timestamps, labels, and helper text.
- **Outline (#98A2B3):** accessible field borders, dividers, and secondary control outlines.
- **Outline Variant (#E4E7EC):** low-contrast separators and card borders.

### Functional States

Use explicit text labels in addition to color so status remains understandable without color perception:

- BUKA → green badge + "Buka"
- TUTUP → neutral/amber badge + "Tutup"
- MENUNGGU_VERIFIKASI → amber badge + "Menunggu verifikasi"
- SELESAI → green badge + "Selesai"
- DIBATALKAN → red/neutral badge + "Dibatalkan"
- MENUNGGU / DIPROSES → amber/blue badges
- BERHASIL → green badge
- DITOLAK / GAGAL → red badge

## 3. Typography Rules

### Hierarchy & Weights

Use **Poppins** consistently because the legacy app already establishes it as the UI font. The typography should feel friendly but operational, with heavier weights for monetary values and page titles.

- Display: 32/40, weight 700 — large balance or onboarding headline when appropriate.
- Page headline: 22–26/30–34, weight 700 — screen titles and major sections.
- Section title: 18/26, weight 700 — grouped content and card titles.
- Body: 14/21 and 16/24, weight 400 — readable content and descriptions.
- Body emphasis: 14/21, weight 600 — transaction names, actionable labels, amounts in rows.
- Label: 12/18, weight 600 — field labels, status metadata, timestamps.
- Large numeric/stat: 28/36, weight 700 — saldo, total nilai, and key transaction figures.

Money and numerical values should use strong hierarchy: the amount is visually dominant, while currency/unit and supporting metadata remain quieter. Never style every number as bold.

### Spacing Principles

Use a strict 4px base rhythm with most layout spacing falling on 8px, 16px, 24px, and 32px increments. Mobile page content uses approximately 20px side margins. Dense transactional areas may use 16px internal padding, while hero cards use 20–24px.

## 4. Component Stylings

### Buttons

Primary actions are filled green, full-width when they are the main action on a screen, and approximately 52px high to support comfortable touch. Use generously rounded corners (about 16px), not the extreme pill treatment of the old login UI.

Secondary actions use white or transparent surfaces with a green outline or green text. Tertiary actions are text buttons. Destructive actions use the error color and require confirmation for irreversible operations.

Examples:

- Primary: "Setor Sekarang", "Verifikasi Setoran", "Ajukan Tukar Saldo", "Simpan".
- Secondary: "Lihat Riwayat", "Petunjuk arah", "Batal".
- Tertiary: "Lewati", "Lihat semua", "Ubah".

Buttons must have clear disabled, pressed, loading, and error feedback.

### Cards & Containers

Cards should use white surfaces, 16–20px corner radii, and very subtle elevation. Prefer a light border plus soft shadow instead of large floating shadows. Large hero cards can use the brand green background and white foreground content, but gradients should be restrained to one major surface at most per screen.

Avoid stacking too many nested cards. A page should communicate hierarchy through whitespace first, cards second.

### Navigation

Use a **five-destination mobile bottom navigation**:

1. **Beranda**
2. **Harga**
3. **QR** (center action)
4. **Edukasi**
5. **Profil**

The center QR action should be visually prominent and slightly elevated, clearly communicating "Tunjukkan QR saat setor". Keep the bottom bar compact and stable across authenticated screens.

The notification icon remains in the top area of Beranda and opens the notification inbox. The chatbot is accessed through a floating action button and must not obscure primary controls.

### Inputs & Forms

Input fields use white surfaces, visible labels above the field, 14–16px text, and approximately 14–16px corner radii. Keep the border subtle at rest and clearly green on focus. Password/PIN fields expose visibility or numeric controls where useful.

Forms should be vertically scannable, with one clear label per field. Validation messages appear directly below the relevant field. Avoid relying on SnackBars alone for validation.

For financial forms, surface constraints before submission: minimum tukar saldo Rp10.000, available balance, destination type, and saved destination behavior.

### Domain-Specific Components

#### Saldo Card

The hero balance card is the most important component on Beranda. Show:

- "Saldo tersedia"
- large rupiah value
- "Saldo ditahan" only when greater than zero
- primary action "Tukar saldo" when eligible
- optional visibility toggle for the amount

Do not show coins, points, mission progress, or rewards anywhere in the Proyek 3 mobile UI.

#### Waste Price Row

Each active waste type is presented as a compact row with category, material name, and purchase price per kg. Example hierarchy:

"Plastik" → "Botol PET" → "Rp1.800/kg"

Show the last update time as secondary metadata where useful.

#### Transaction Item

A setoran row should surface the date, short transaction code, main waste type or summarized item count, total weight, total rupiah value, and status. The user must be able to open a detail screen showing the full price/weight calculation.

#### Status Badge

Use short, explicit Indonesian labels. The badge is never the only place where status is communicated; key result pages may also use an icon and explanatory text.

#### QR Identity Card

The QR screen uses a large, high-contrast QR code with the user's name and short supporting text. Include a clear four-step explanation:

1. Bawa sampah bersih dan terpilah.
2. Tunjukkan QR ke petugas.
3. Petugas menimbang dan memverifikasi.
4. Saldo masuk ke akun.

The QR itself represents a random unique customer code and should be treated as an identity credential, not as a decorative graphic.

#### Chatbot

The chatbot is a supportive assistant for waste, environment, and Setor.in usage. It must visibly state that answers are general. Do not suggest that the assistant can access saldo, riwayat, or private user data. The UI should offer suggested questions and a graceful off-topic fallback toward FAQ or Rumah Hijau contact information.

## 5. Layout Principles

### Grid & Structure

Use a **strict Android phone, portrait-only, single-column layout**. Treat the design canvas as a mobile device viewport, not as a responsive web page. Every primary authenticated screen should work naturally at common Android phone widths with vertical scrolling for longer content. Do not create desktop navigation, sidebar navigation, data tables intended for desktop, multi-column desktop grids, tablet breakpoints, hover states, or landscape-first layouts.

Use a 20px outer gutter on standard mobile widths. Primary cards span the available width. Two-column layouts are reserved for compact stats where they genuinely improve scanning.

### Whitespace Strategy

Use generous separation between sections, especially after the hero balance area. Prefer approximately 24px between major sections and 12–16px between related content elements.

Avoid filling empty space with decorative graphics. Empty space is part of the information hierarchy.

### Alignment & Visual Balance

Most content is left-aligned. Center alignment is appropriate for onboarding, OTP, QR, empty states, and the chatbot introduction. Monetary totals should align predictably in cards and tables, with labels subordinate to values.

### Responsive Behavior & Touch

Target **Android 8.0+ phones in portrait orientation**. Use touch targets of at least 44–48px for interactive controls. Respect system safe areas, keyboard insets, gesture/navigation areas, and scrolling when forms are open.

The UI should be designed around a compact mobile viewport and remain readable at smaller Android phone widths without horizontal scrolling. Long Indonesian labels should wrap intentionally instead of being clipped. Do not introduce desktop-style hover interactions; use pressed, focused, selected, loading, disabled, and error states suitable for touch.

## 6. Screen Blueprint — Proyek 3

The following screens are the intended mobile UI scope derived from the PRD. F1 is the field-test MVP and F2 adds the complete product experience.

### F0/F1 Authentication Foundation

#### Splash

- Full-screen brand introduction using Setor.in and Rumah Hijau identity.
- Primary visual: logo mark/wordmark, then short line "Pilah Sampah, Raih Rupiah".
- Replace the old generic recycling icon presentation with the actual Rumah Hijau logo when the asset is available.
- Keep motion subtle: fade/scale, short duration, no distracting loops.

#### Onboarding

Three concise slides maximum. Update the legacy copy so it no longer mentions coins, nearby multiple bank sampah, or rewards.

1. "Pilah & Setor Sampah" — explain clean/sorted waste and Rumah Hijau.
2. "Dapatkan Nilai Rupiah" — explain weight × purchase price per kg.
3. "Pantau Saldo & Tukar" — explain balance tracking and exchange flow.

Primary CTA: "Lanjut" / "Mulai". Secondary: "Lewati".

#### Login

- Header with back control only when appropriate.
- Logo/brand lockup.
- Title: "Selamat datang kembali".
- Email and password.
- "Lupa password?"
- Primary "Masuk".
- Secondary Google sign-in button in F2.
- Registration link: "Belum punya akun? Daftar".

The legacy login already follows a clear vertical form but uses very pill-shaped controls; keep the hierarchy and simplify the geometry.

#### Register

Fields: nama, no. HP, alamat, email, password, konfirmasi password. Use a progressive, easy-to-scan form with strong validation. Primary CTA: "Daftar". Explain OTP verification before submission without adding unnecessary copy.

#### OTP

- Six-digit segmented numeric input.
- Clear expiry/resend messaging.
- Primary CTA: "Verifikasi".
- Secondary action: "Kirim ulang kode" with countdown.
- Clear error state for invalid/expired code.

#### Forgot Password

Three states: request OTP → verify OTP → create new password. Keep the UI consistent with authentication screens.

### F1 Core Experience

#### Beranda

Purpose: answer three questions immediately — "Berapa saldo saya?", "Kapan bisa setor?", and "Apa yang harus saya lakukan berikutnya?"

Recommended order:

1. Compact header with Rumah Hijau/Setor.in brand and notification icon.
2. Greeting with customer name.
3. Large saldo tersedia card.
4. Status Rumah Hijau card: BUKA/TUTUP and next schedule.
5. Quick actions: "Tunjukkan QR" and "Lihat Harga".
6. Recent setoran list with status and rupiah value.
7. Small educational teaser.
8. Floating chatbot button.
9. Five-item bottom navigation.

Do not recreate the legacy dashboard's "Koin", "Target Sampah", or "Cek Bank Sampah" menu. Those concepts were removed from Proyek 3.

#### QR Saya

Full-screen focused QR presentation. Keep the QR large and unobstructed. Show customer name, optional code label, and the four-step instruction. Primary visual focus must remain the QR code.

#### Harga Sampah

- Page title: "Harga Sampah".
- Search/filter by category.
- List active material types.
- Price per kg as the dominant number.
- "Diperbarui" timestamp as metadata.
- Read-only behavior.

#### Riwayat Setoran

F1 shows setoran history. Use filter chips such as "Semua", "Selesai", "Menunggu", and "Dibatalkan" only if useful. Date formatting follows WIB and Indonesian conventions.

Each item opens a detail view with transaction ID, date/time, waste types, weight, purchase price/kg, subtotal, total weight, total value, and status.

#### Setoran Detail

Use a calculation-first layout:

- transaction summary
- itemized waste rows
- weight × purchase price
- subtotal per type
- total weight
- total value
- status timeline or status block

### F2 Complete Experience

#### Tukar Saldo

The flow is deliberately stepwise:

1. Enter nominal.
2. Choose Bank or E-Wallet.
3. Fill destination details.
4. Optional "Simpan untuk berikutnya".
5. Review summary.
6. Enter 6-digit PIN.
7. Success/pending confirmation.

Show the minimum exchange amount (Rp10.000) near the amount field. Clearly show available balance and held balance behavior.

#### PIN

Dedicated flows for:

- Create PIN on first exchange.
- Change PIN.
- Forgot PIN via email OTP.
- Locked state after 5 wrong attempts, with a visible 15-minute lock explanation.

Use a calm, security-oriented composition with large numeric input and minimal distractions.

#### Notifikasi

Inbox layout with:

- unread/read distinction
- timestamp
- notification category icon
- concise title and body
- tap-through to related page

Important events: successful setoran, exchange approved/complete, exchange rejected with reason, new education article.

#### Edukasi

List recent articles with category filter, cover image, title, excerpt, and publication date. Detail view includes cover image, article content, and optional video link.

Topics include waste sorting, waste processing, healthy environments, and risks of littering.

#### FAQ

Accordion list. Keep questions short and answers scannable. Use clear disclosure animation and strong accessibility contrast.

#### Lokasi & Jadwal Setor

Because Proyek 3 has one fixed partner, this page is about **Rumah Hijau only**, not a bank-sampah discovery map.

Show:

- Rumah Hijau name
- address
- current status BUKA/TUTUP
- next schedule
- opening and closing time
- note/instructions
- "Petunjuk arah" button opening Google Maps
- optional WhatsApp button only when a phone number is available

The status is server-driven in WIB, so the UI should communicate the time context clearly.

#### Chatbot AI

Conversation screen with:

- header title "Asisten Setor.in"
- small disclaimer "Jawaban bersifat umum"
- suggested question chips
- chat bubbles distinguishing user and assistant
- 500-character input limit
- send/loading/error states
- off-topic fallback directing user to FAQ or Rumah Hijau contact

Never surface personal balance or transaction information inside the chatbot UI.

#### Edit Profil

Fields: nama, no. HP, alamat. Email appears read-only. Password and PIN changes are separate actions. Keep account settings quiet and utilitarian.

## 7. Interaction & Motion

Motion should clarify state changes, not decorate the interface.

Use short 150–250ms transitions for tabs, chips, buttons, and accordions. Use 250–400ms for page-level hero/QR presentation or onboarding transitions. Avoid continuous animations except loading indicators.

Important feedback patterns:

- Save → progress indicator → success state.
- Verification → confirmation dialog → completed status.
- Exchange → PIN → pending/success/failure state.
- Notification → unread badge → read state.
- Chatbot → sending indicator → response → error fallback.

## 8. Empty, Loading, Error & Disabled States

Every data-driven screen needs explicit non-happy paths.

### Empty

Use an icon or quiet illustration, a one-sentence explanation, and one relevant CTA. Example: "Belum ada setoran" + "Setor sampah pertamamu di Rumah Hijau."

### Loading

Prefer skeleton rows or unobtrusive progress indicators over blank screens.

### Error

Explain what failed and what the user can do next. Do not expose technical API errors.

### Disabled

Use reduced contrast but preserve readable text. Disabled primary actions must still communicate the reason where that reason is not obvious.

## 9. Content & Copy Rules

Language: **Bahasa Indonesia**.

Tone: friendly, concise, concrete, and trustworthy. Avoid hype, gamification language, or unnecessary English terminology.

Use the PRD's display formats:

- Rupiah: `Rp1.800`
- Weight: `1,25 kg`
- Date/time: `24 Sep 2026 14:05 WIB`

Preferred verbs: "Setor", "Tunjukkan", "Lihat", "Simpan", "Verifikasi", "Ajukan", "Tukar", "Baca", "Hubungi".

Avoid legacy terms that are no longer valid in Proyek 3: **koin, misi, reward, harga koin, bank sampah terdekat, tukarkan koin**.

## 10. Legacy UI → Proyek 3 Migration Rules

- Replace **Koin** with **Saldo Rupiah**.
- Replace **Tukarkan Koin** with **Tukar Saldo**.
- Remove **Target Sampah / Misi** completely.
- Remove **Cek Bank Sampah** as a discovery feature; replace with a single **Rumah Hijau** location/schedule page.
- Replace old four-item bottom navigation with **Beranda / Harga / QR / Edukasi / Profil**.
- Keep the green brand family, Poppins typography, rounded cards, and Material 3 foundation, but reduce excessive pills and layered cards.
- Make the QR a first-class navigation action.
- Make transaction value and status more prominent than gamification metrics.
- Use a single-partner mental model: the user is always interacting with Rumah Hijau.

## 11. Strict Mobile-Only Stitch Rules

Stitch must interpret this document as a **mobile app design specification**, not a web design system.

- Generate **Android phone screens only**.
- Use **portrait orientation only** unless the user explicitly asks for landscape.
- Use bottom navigation, mobile app bars, sheets, dialogs, and touch-friendly controls rather than sidebars, desktop navbars, or web page headers.
- Do not generate desktop/tablet variants.
- Do not introduce hover states, mouse-first interactions, mega menus, desktop tables, web dashboard layouts, or responsive website breakpoints.
- Keep content vertically scrollable when it exceeds the viewport.
- Design for one-handed and thumb-friendly interaction where practical.
- Preserve Android system safe areas around status bar, navigation/gesture bar, and keyboard.
- Treat the center QR item as a mobile navigation action, not a desktop shortcut.
- If a prompt conflicts with this scope, prioritize this mobile-only scope and the PRD's mobile nasabah requirements.

## 12. Stitch Generation Notes

### Language to Use

Use prompt language such as:

- "Mobile-first Android banking-style wallet UI for a digital bank-sampah app"
- "clean, trustworthy, warm, community-oriented"
- "single-column content with spacious vertical rhythm"
- "green branded hero balance card"
- "high-clarity transaction rows with status badges"
- "elevated center QR action in bottom navigation"
- "quiet white cards on a light neutral background"
- "Poppins typography with strong numerical hierarchy"

Avoid prompts such as "fun recycling game", "eco rewards dashboard", or "bank sampah marketplace" because those concepts contradict Proyek 3.

### Color References

Use the semantic tokens above exactly when a Stitch prompt needs visual color specificity. The base brand is anchored by `#0D9146` / `#0A7A3A`, with `#26D077` as a restrained accent and `#F5F7FA` as the main canvas.

### Component Prompts

**Beranda:**
"Create a mobile-first authenticated home screen for Setor.in at Rumah Hijau. Prioritize a large available-rupiah balance card, Rumah Hijau open/closed status, next deposit schedule, two quick actions for QR and prices, recent setoran transactions, and a small education teaser. Add a notification icon in the header, a floating chatbot action, and a five-destination bottom navigation with QR as the elevated center action. Do not include coins, missions, rewards, or bank-sampah discovery."

**QR:**
"Create a focused QR identity screen for Setor.in. Place a large high-contrast customer QR code in the visual center, customer name below it, and concise four-step instructions explaining how to bring clean sorted waste, show the QR to the officer, wait for weighing and verification, and receive rupiah balance. Keep the screen visually calm and action-oriented."

**Harga:**
"Create a mobile price-list screen for Rumah Hijau showing active recyclable waste types, category, material name, purchase price per kilogram, and last update time. Use compact readable rows, category filters, and a clear read-only presentation."

**Tukar Saldo:**
"Create a step-based exchange flow for a digital bank-sampah wallet. Show available saldo, minimum Rp10.000, destination type bank/e-wallet, destination details, optional save-for-next-time, a confirmation summary, and a final 6-digit PIN step. Make validation and status transitions explicit."

**Chatbot:**
"Create a lightweight Indonesian waste-management chatbot for Setor.in with suggested questions, conversation bubbles, a 500-character input limit, visible general-answer disclaimer, and graceful off-topic fallback to FAQ or Rumah Hijau contact. Do not expose balance or transaction data."

### Incremental Iteration

Generate screens in this order so the design language stabilizes early:

1. Beranda
2. Login
3. QR Saya
4. Harga Sampah
5. Riwayat Setoran
6. Tukar Saldo
7. Edukasi
8. Lokasi & Jadwal
9. Profil
10. Notifikasi
11. Chatbot
12. Authentication support screens (Register, OTP, Forgot Password, PIN)

After generating Beranda, use it as the visual reference for subsequent authenticated screens. Preserve the same header rhythm, card geometry, button geometry, status badge treatment, spacing scale, and bottom navigation across the product.

## 13. Data/Content Constraints for Mockups

Use realistic Indonesian sample data without implying these values are final partner data unless provided:

- Example material: Botol PET, Rp1.800/kg.
- Example weight: 1,25 kg.
- Example timestamp: 24 Sep 2026 14:05 WIB.
- Example exchange: Rp25.000 to an e-wallet.

Mark unknown partner-specific information as placeholder rather than inventing it:

- Rumah Hijau logo asset
- Rumah Hijau complete address and coordinates
- initial waste price catalog
- October/November deposit dates
- Rumah Hijau WhatsApp number
- education article content and FAQ content

## 13. Non-Negotiable Product Truths

The UI must always communicate the following product model correctly:

- There is **one partner location: Rumah Hijau**.
- Waste value is a **rupiah balance** calculated from **weight × purchase price per kg**.
- Balance increases only after a deposit is verified.
- Deposit prices are snapshot at save time and historical transactions do not change when admin prices change later.
- Available balance and held balance are separate concepts.
- Exchange requires at least Rp10.000 and a 6-digit PIN.
- Only one active exchange request is allowed per customer.
- Exchange approval is handled by admin; the customer sees clear status changes.
- Chatbot knowledge is limited to general waste/environment/Setor.in usage and must not use personal data.
- All date/time display is Asia/Jakarta (WIB).

## 14. Final Design Quality Bar

A generated Stitch screen is acceptable only when a user can identify the primary task within three seconds, understand the current rupiah/status state without reading every word, and reach the next meaningful action without navigating through decorative UI.

The redesign should look like a **real operational fintech-style utility for waste collection**, with environmental warmth carried through the brand color, imagery, and educational content—not through gamification mechanics that were removed from the product.
