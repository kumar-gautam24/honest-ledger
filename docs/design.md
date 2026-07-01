# Recurring Tracker — Design & Plan

**Date:** 2026-06-30
**Status:** Awaiting approval ("go") before implementation
**Stack:** Flutter 3.44 / Dart 3.12 · Riverpod (code-gen) · Drift (SQLite) · get_it · Dio · go_router · INR/India

---

## 1. Context

A single Flutter app to **track recurring money obligations** (EMI loans, subscriptions, fixed bills) and to **reason about EMIs before committing** to them. The user wants a scalable, clean-architecture foundation now (local-only data) that can later plug into a backend with zero changes to UI/domain code.

Three problems it solves:
1. *"What am I paying every month, and what's due next?"* → **Recurring tracker**.
2. *"If I buy this at ₹X on EMI, what's the real monthly cost and total interest?"* → **EMI calculator**.
3. *"Is this 'No Cost EMI' actually free?"* (No — 18% GST on interest + processing fee) → **No-cost EMI analyzer**.
4. Plus **reminders** so a due date is never missed.

---

## 2. Architecture — Feature-first Clean Architecture (simplified)

Three layers per feature. **Domain is pure Dart** (no Flutter/Drift imports), so business logic is unit-testable and survives a backend swap.

- **Domain** — entities, repository *interfaces*, use cases.
- **Data** — Drift DAOs + models/mappers + repository *implementations*. Local now; a `RemoteDataSource` (Dio) drops in later behind the same repository interface.
- **Presentation** — Riverpod `@riverpod` controllers (`AsyncNotifier`) + screens + widgets.

### Dependency Injection — get_it + Riverpod boundary
- **get_it** owns singletons: Drift database, Dio client, datasources, repositories, services (notifications).
- **Riverpod** owns UI state and exposes controllers; providers pull their dependencies from get_it (`sl<RecurringRepository>()`).
- Rule of thumb: *get_it = "what exists once", Riverpod = "what the screen is currently doing".*

### Folder structure
```
lib/
  main.dart                      # bootstrap: init DI, run app
  app/
    app.dart                     # MaterialApp.router + theme wiring
    router/app_router.dart       # go_router (bottom-nav shell)
  core/
    theme/                       # DESIGN SYSTEM (see §5)
      app_theme.dart  app_colors.dart  app_typography.dart  app_spacing.dart
    constants/app_constants.dart # GST_RATE=0.18, default tenures, currency
    di/injector.dart             # get_it registrations
    database/                    # Drift db + tables + DAOs
      app_database.dart  tables/  daos/
    network/                     # Dio client + interceptors (for backend later)
      dio_client.dart  api_endpoints.dart
    error/  failures.dart  exceptions.dart
    utils/ result.dart  money_formatter.dart  date_x.dart
  shared/widgets/                # reusable design-system widgets (AppButton, AppCard, AppTextField...)
  features/
    recurring/      { data/ domain/ presentation/ }   # core tracker
    emi_calculator/ { domain/ presentation/ }          # pure calc, no data layer
    no_cost_emi/    { domain/ presentation/ }
    reminders/      { data/ domain/ presentation/ }
    settings/       { presentation/ }                  # theme mode, currency, reminder prefs
```

### Modeling
- **freezed + json_serializable** for domain entities & future API DTOs (immutability + JSON for backend).
- Drift generates row classes; **mappers** convert Drift row ↔ domain entity (keeps domain Drift-free).
- **Result type** (sealed `Result<T>` or `fpdart`'s `Either`) for repository return values; map exceptions → `Failure`.

---

## 3. Modules

### 3.1 Recurring Tracker (core)
- **Entity `RecurringItem`**: id, title, type (`emi | subscription | fixed`), amount, currency, frequency (`weekly | monthly | quarterly | yearly | custom`), startDate, nextDueDate, endDate?, category, notes, isActive, reminder settings, (for EMI type) linked principal/rate/tenure/remaining-installments.
- **Drift table** `recurring_items` + DAO with reactive `Stream` queries (`watchAll`, `watchUpcoming`, sort by `nextDueDate`).
- **Use cases**: addItem, updateItem, deleteItem, watchAllItems, getUpcomingDues(window), getMonthlyOutflow (normalize every frequency to a monthly figure).
- **Screens**: Home/Dashboard (total monthly outflow, breakdown by type/category, next 7/30-day dues), Items list (filter/sort), Add/Edit item, Item detail.

### 3.2 EMI Calculator (pure domain)
Inputs: principal `P`, annual rate `R%`, tenure `n` (months), rate type (`reducing | flat`), processing fee (flat ₹ or % of P), GST rate (default 18%).
- **Reducing balance:** `r = R/12/100`; `EMI = P·r·(1+r)ⁿ / ((1+r)ⁿ − 1)`.
- **Flat:** `interest = P·R·T/100`; `EMI = (P + interest) / n`.
- **Outputs:** monthly EMI, total interest, processing fee + 18% GST on fee, **total payable**, effective annual rate.
- **Amortization schedule** (reducing): per month → opening balance, interest = balance·r, principal = EMI − interest, closing balance. Renders as a table.
- No data layer — stateless calculation, exposed via a Riverpod controller; results optionally "Save as recurring item".

### 3.3 No-Cost EMI Analyzer (the truth-teller)
The catch (researched): in a "No Cost EMI", the seller discounts the bank's interest so monthly = `P/n`, **but**:
- You still pay **18% GST on the bank's interest amount**.
- Processing fee still applies, **+ 18% GST on the fee**.
- Any forfeited upfront discount is effectively your interest.

Inputs: price `P`, tenure `n`, bank nominal rate `R` (to derive the interest the bank charges), processing fee, optional forfeited upfront discount.
- `bankInterest = reducingEMI(P,R,n)·n − P`
- `hiddenGST = 0.18 · bankInterest`
- `feeCost = fee + 0.18·fee`
- **`trueCost = P + hiddenGST + feeCost (+ forfeitedDiscount)`**, plus the **effective interest rate** vs the advertised "0%".
- Output is a clear "Advertised vs Actual" breakdown card.

### 3.4 Reminders / Notifications
- **flutter_local_notifications + timezone** to schedule local notifications for `nextDueDate` (e.g. 1 day before, configurable).
- `NotificationService` (registered in get_it) handles permission request, schedule, cancel/reschedule on item add/edit/delete.
- Reschedule on app start to stay in sync; respect per-item reminder toggle.

### 3.5 Settings
Theme mode (light/dark/system), default currency, default GST rate, default reminder lead-time. Stored in **SharedPreferences** (lightweight key-value — the one place it's the right tool; Drift holds the structured data).

---

## 4. Packages (pubspec)

| Concern | Package |
|---|---|
| State | `flutter_riverpod`, `riverpod_annotation` · dev: `riverpod_generator`, `build_runner`, `custom_lint`, `riverpod_lint` |
| DB | `drift`, `sqlite3_flutter_libs`, `path_provider` · dev: `drift_dev` |
| DI | `get_it` |
| Network (later) | `dio` |
| Key-value | `shared_preferences` |
| Routing | `go_router` |
| Models | `freezed_annotation`, `json_annotation` · dev: `freezed`, `json_serializable` |
| Formatting | `intl` |
| Notifications | `flutter_local_notifications`, `timezone` |
| Typography | `google_fonts` (or bundled fonts) |
| FP/Result | `fpdart` (optional; else hand-rolled sealed `Result`) |

---

## 5. Design System (central theme)

> Will be refined with the `frontend-design` skill at build time. Proposed direction below.

- **Material 3**, seeded `ColorScheme` for light & dark. Direction: a clean **fintech** feel — one confident brand/primary color, restrained neutrals, semantic colors for *due-soon / overdue / paid*, money figures in tabular numerals.
- **Tokens** (no magic numbers in widgets): `AppSpacing` (4·8·12·16·24·32), `AppRadius`, `AppColors`, `AppTypography` (display→label scale via google_fonts).
- **Shared widgets** in `shared/widgets/`: `AppScaffold`, `AppButton`, `AppCard`, `AppTextField`, `MoneyText`, `SectionHeader` — so screens compose tokens, never raw styles.

---

## 6. Build Order (phased — full plan comes from writing-plans)

1. **Foundation** — deps, folder skeleton, design-system theme, get_it skeleton, go_router bottom-nav shell, Drift db skeleton, `main.dart` bootstrap.
2. **EMI Calculator** — pure domain math + tests, then UI + amortization table. (Self-contained, high-value, fully testable first.)
3. **No-Cost EMI Analyzer** — domain math + tests, then UI breakdown.
4. **Recurring Tracker** — Drift tables/DAO, repo + mappers, CRUD, dashboard (monthly-outflow + upcoming dues).
5. **Reminders** — NotificationService, scheduling wired to item lifecycle, settings.
6. **Backend-ready** (later) — `RemoteDataSource` (Dio) + repo wiring behind existing interfaces; no UI/domain changes.

---

## 7. Testing

- **Unit (critical):** EMI math (reducing, flat, schedule) and no-cost true-cost math — financial accuracy is non-negotiable; assert against worked examples.
- **Repository:** in-memory Drift database.
- **Widget:** dashboard, EMI calculator, add/edit item.

---

## 8. Verification (end-to-end)

- `flutter pub get` && `dart run build_runner build --delete-conflicting-outputs` clean.
- `flutter analyze` clean; `flutter test` green (esp. EMI/no-cost suites).
- `flutter run`: add a recurring item → appears on dashboard, monthly outflow updates, due date shows; schedule a reminder and confirm it fires; run EMI calc and verify EMI/interest against a known calculator; run no-cost analyzer and confirm GST + fee surface in "true cost".
