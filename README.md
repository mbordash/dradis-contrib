# dradis-contrib

Community contributions to [DRADIS](https://github.com/mbordash/DRADIS), the
trading engine for prediction markets (Kalshi, Polymarket US, Polymarket
International).

Today that means **vipers**: trading strategies written as small, sandboxed
scripts. Every viper merged here is published, signed, to the community
registry at [dradis.live/vipers](https://dradis.live/vipers), where any DRADIS
operator can browse it and import it from the Control Tower (Build a Viper →
Community). An imported viper always arrives switched off and on paper.

```
vipers/<publisher>/<name>/
  manifest.json   name, parameters with defaults and ranges, market classes, venues
  script.rhai     the strategy: fn entry(ctx) and fn exit(ctx, pos)
  README.md       what it does, why, and what to watch
raptors/          signal sources (not open yet; see raptors/README.md)
```

## How a viper gets published

1. You open a pull request adding or changing `vipers/<your login>/<name>/`.
   See [CONTRIBUTING.md](CONTRIBUTING.md).
2. CI checks it the way DRADIS checks a script before saving it: it compiles,
   reads only parameters it defines, stays within the size limits, and the
   folder layout and publisher match.
3. A maintainer reviews it. Review looks for clarity, honesty in the README
   and anything that could harm an operator. It is not a test of profitability.
4. After merge, a maintainer publishes it as a new version. The registry
   signs each version with a key kept offline, and DRADIS checks that
   signature before it shows or imports anything. Published versions never
   change; a bad one is withdrawn with a reason.

## Disclaimer

Community content, MIT licensed. Not investment advice, and not reviewed for
profitability. Run anything you import on paper first.
