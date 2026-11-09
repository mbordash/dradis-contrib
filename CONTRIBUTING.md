# Contributing a viper

## Start in DRADIS

Write and test the viper in your own DRADIS, under Build a Viper. Run it on
paper long enough to see it trade. Then export it (the Export button) or copy
its files, and lay them out here:

```
vipers/<your GitHub login, lowercase>/<name>/
  manifest.json
  script.rhai
  README.md
```

- `<name>` must equal `name` in `manifest.json`: 3-32 characters of `a-z`,
  `0-9` and `_`, starting with a letter. Names are unique across the registry.
- Remove any `origin` field from `manifest.json` (it records where a local
  copy came from).
- Contributions under your folder are yours. To propose a change to someone
  else's viper, open an issue or ask them first.

## The README

Say what the viper does, the idea behind it, which venues and markets you ran
it on and for how long, and what an operator should watch. Be plain about how
much evidence there is: "a week on paper, 12 trades" is useful; a win rate
without a sample size is not. Markdown only; raw HTML is not rendered.

## Defaults

DRADIS runs on Kalshi, Polymarket US and Polymarket International. Prefer
defaults that are safe everywhere (small size, a modest exposure cap). If a
parameter depends on the venue or coin (a settlement-index basis, a
volatility), default it neutrally and explain in the README how to set it.

## New versions

Change the files in place and open a pull request saying what changed. The
maintainer picks the version number when publishing (MAJOR.MINOR.PATCH).
Operators who imported an earlier version see an update offer with a diff.

## Run the checks yourself

CI runs the same check DRADIS runs before saving a script. Locally, from a
DRADIS checkout (copy a config profile to `src/config.rs` first, as its README
says):

```
cargo run --no-default-features --features kalshi,registry-tool \
  --bin viper-registry -- check ../dradis-contrib/vipers/<login>/<name>
```

## Rules

- License: everything here is MIT (see LICENSE). By opening a pull request you
  license your contribution under it.
- No vipers designed to manipulate a market, and no attempts to get around
  the script sandbox. Either gets the contribution removed.
- American spelling in READMEs and comments (favor, behavior, canceled), so
  the published pages read consistently.
- Maintainers may withdraw a published version that turns out to be harmful,
  with the reason shown to operators who imported it.
