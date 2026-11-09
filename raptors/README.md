# Raptors (not open yet)

Raptors are DRADIS's signal scouts: they connect to an outside data source
(prices, funding, order flow, news) and hand the vipers a normalized feed.

Unlike a viper, a raptor needs the network, so it cannot run in the viper
sandbox, and it will not be imported at runtime the way vipers are. How
contributed raptors will reach DRADIS (reviewed Rust that ships in a release,
or a declarative feed description run by DRADIS's own code) is still being
designed. Open an issue to discuss a raptor idea before writing one.
