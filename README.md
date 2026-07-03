# Honest Ledger

A personal-finance app for India that keeps you honest about money you owe.

It does three things: tracks what you borrow and how much it actually costs you, does the EMI math *before* you commit to a purchase, and keeps an eye on the recurring bills and subscriptions that quietly drain a monthly budget.

Built with Flutter, local-first, INR throughout.

## Why

Most "buy now, pay later" and card-EMI offers are priced to look cheaper than they are. A "No Cost EMI" still carries 18% GST on the interest the bank waives, plus a processing fee. Slice, mPokket, and BNPL lenders layer their own charges on top. It's easy to lose a few thousand rupees a year to costs you never sat down and added up.

Honest Ledger adds them up. Every borrowing carries a full repayment ledger, and the home screen shows a single lifetime figure: how much you've borrowed, how much you've repaid, and how much of that was pure cost.

## Features

**Money-leak tracker.** Log each borrowing — Slice, mPokket, a BNPL plan, a card EMI — with the lender, the purchase, and a running repayment ledger. Each borrowing rolls up into a lifetime *borrowed vs. repaid vs. wasted* view.

**EMI calculator.** Enter amount, rate, and tenure to get the monthly instalment, total interest, and a full amortization schedule.

**No-Cost EMI analyzer.** Takes an advertised "No Cost EMI" offer and shows what it actually costs once GST and processing fees are included — advertised price vs. real price, with a plain verdict.

**Recurring tracker.** Subscriptions, fixed bills, and running EMIs in one place, normalized to a single monthly outflow figure with upcoming dues. Marking a due as paid advances its next date.

**This Month.** The home screen leads with what's still to pay this calendar month — due, paid, remaining — and opens a month statement: every dated due, anything overdue carried in from earlier, and a 12-month outflow timeline showing when each EMI ends and money frees up. Set a monthly income to see what's left after obligations.

**Catch-up.** Come back after weeks away and a quiet "while you were away" card lists everything that went past unlogged — pre-checked, settled in one tap, with EMI repayments dated on their due dates so the interest math stays honest.

**Cards.** Statement-level card tracking: enter one number a month (the bill total) and the app splits it into the EMI portion — derived from the card's linked borrowings — and other spends, with utilization against an optional limit. Card bills fold their EMIs in on the month view, so no rupee is ever counted twice.

**Lender catalog.** A built-in, research-backed catalog of Indian lender and card-EMI terms (card EMI as percent-with-cap plus 18% GST, plus the fintech BNPL rates), editable and extendable from Settings.

## Tech

- **Flutter 3.44 / Dart 3.12**
- **Riverpod** (code generation) for state, **get_it** for singletons — Riverpod owns "what the screen is doing", get_it owns "what exists once"
- **Drift (SQLite)** for local persistence, with schema migrations
- **go_router** for a four-tab bottom-nav shell (Home · Cards · Tools · Settings)
- **freezed** / **json_serializable** for models
- Feature-first clean architecture: a pure-Dart domain layer with repository interfaces, so a backend can drop in later behind the same contracts with no changes to UI or domain code

The design language ("The Honest Ledger") is dark-first: an ink base, a brass accent, and an ember tone reserved for cost and wasted money. Amounts are set in a tabular monospace so columns line up like a real ledger.

## Project structure

```
lib/
  app/            MaterialApp.router, theme wiring, go_router shell
  core/           theme, database, DI, formatters, finance math, validation
  features/       money_leak, cards, emi_calculator, no_cost_emi, recurring,
                  lenders, home, settings, tools
  shared/         reusable widgets (cards, money text, animated counter, ...)
```

Each feature is split into `domain` (entities + repository interfaces), `data` (Drift mappers + repository implementations), and `presentation` (Riverpod controllers + screens + widgets).

The full design and architecture write-up lives in [`docs/design.md`](docs/design.md).

## Getting started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Riverpod / Drift / freezed codegen
flutter run
```

## Tests

```bash
flutter test
```

Unit and widget tests cover the finance math, borrowing repositories and summaries, the lender catalog, and the input forms.

## Status

Local-first and feature-complete for daily use. Reminders and a sync backend are planned; the repository interfaces are already in place for the backend to slot behind.

This is a personal project, shared publicly as a reference.
