# Late Favorite

In the last ten minutes of an hourly crypto strike market ("Will Bitcoin be
above $74,400 at 2 PM?"), the price is often far enough from the strike that
one side is a clear favorite. Late Favorite estimates how likely that side is
to win, and buys it when the market's ask is cheap enough to leave an edge
after fees. It holds every position to settlement.

## The idea

With `t` seconds left, the price has to move from where it is to the strike.
The script measures that distance in standard deviations of the typical move
over the time remaining:

    level = oracle - basis
    move  = hourly_vol * level * sqrt(t / 3600)
    z     = (level - strike) / move
    fair  = norm_cdf(z)          (for YES; 1 - that for NO)

It then buys the favored side when:

- `fair` is at least `min_fair` (a real favorite, not a coin flip),
- the ask is at most `max_price`,
- `fair - ask - taker fee` is at least `min_edge`.

`fair` is capped at `fair_cap`, because crypto has fatter tails than the
normal curve: a "99%" favorite loses more often than one time in a hundred.

## Parameters to set for your market

- **`basis`** (default 0): how many dollars the price feed (`ctx.oracle`,
  Binance) reads above the index the venue settles on. Kalshi settles BTC on
  CF Benchmarks; on BTC we measured Binance about $20 above it. Polymarket
  settles each market on the source its rules name. Measure the gap for your
  venue and coin, and set it here; a wrong basis shifts every estimate.
- **`hourly_vol`** (default 0.003 = 0.3%): the typical one-hour move as a
  fraction of the price. BTC is usually 0.2–0.5%; ETH and SOL run higher. Too
  low and the script is overconfident.
- **`window_secs`** (default 600): how close to the close it may start
  entering.
- **`min_secs`** (default 120): when it stops entering. In the last minute
  or two the feed says little about the settlement (Kalshi settles on an
  average of the index over the final minute, and a small basis error
  outweighs the move left), so the market's price is the better estimate
  there. Keep it below `window_secs`.

## What to expect

This is an idea to try on paper, not a proven strategy. The original ran on
paper on Kalshi BTC hourly markets for a few days in November 2026 with a
handful of trades. Its one early loss came from a missing-price bug since
fixed in DRADIS (the oracle read as zero). Run it on paper for a few weeks
before you consider it live, and compare its paper results with what the
market priced.

Things to watch:

- A wrong `basis` or `hourly_vol` makes it confident where it should not be.
- Near the close, books are thin; the default size is 5 contracts.
- It holds to settlement. There is no stop.
- In early paper results, trades the model rated at least 0.8 did better
  than near-strike ones, where one loss costs several wins. If yours look the
  same, try a higher `min_fair`.

## Changes

- **1.0.1:** stops entering `min_secs` (default 120) before the close,
  instead of 30 seconds. On paper, its worst late entry bought at 0.20 with
  under a minute left because the model read the feed as a 0.66 favorite; the
  market was right.
- **1.0.0:** first version.

## Venues

Written for any venue with crypto strike markets: Kalshi, Polymarket US and
Polymarket International. It needs a strike, an oracle price and a close time
(`ctx.strike`, `ctx.oracle`, `ctx.secs_to_close`); on a market without them it
holds and says why.

Community content, MIT licensed. Not investment advice, and not reviewed for
profitability.
