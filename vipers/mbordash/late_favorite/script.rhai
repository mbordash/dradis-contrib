// Late favorite: in the last minutes of a crypto market, when the price sits
// well clear of the strike, buy the side it favors and hold it to settlement.
//
// The venue settles on its own index (Kalshi uses CF Benchmarks), not on the
// feed in ctx.oracle (Binance), and the two can differ by tens of dollars. The
// `basis` parameter is how far the feed reads ABOVE the settlement index; the
// distance to the strike is measured from the feed minus that. `min_fair`
// keeps it to real favorites rather than near-strike coin flips, and
// `fair_cap` limits how sure it may be (BTC's tails are fat).
//
// It stops entering `min_secs` before the close. In the last minute or two the
// feed says little about the settlement: Kalshi settles on an average of the
// index over the final minute, so part of the outcome is already fixed, and a
// small basis error outweighs the move left. There the market's price is the
// better estimate, and a large disagreement with it is a warning, not an edge.
fn entry(ctx) {
    if ctx.oracle == () || ctx.strike == () || ctx.secs_to_close == () {
        return #{ hold: "needs an oracle, a strike and a close time" };
    }
    let t = ctx.secs_to_close;
    if t > ctx.params.window_secs { return #{ hold: `more than ${ctx.params.window_secs}s to the close` }; }
    if t < ctx.params.min_secs { return #{ hold: `less than ${ctx.params.min_secs}s to the close` }; }

    // The price in the settlement's terms, and its distance to the strike in
    // standard deviations over the time left. The typical one-hour move is a
    // parameter (a fraction of the price), scaled by the square root of the
    // time left.
    let level = ctx.oracle - ctx.params.basis;
    let move_left = ctx.params.hourly_vol * level * (to_decimal(t) / 3600).sqrt();
    let z = (level - ctx.strike) / move_left;
    let p_yes = norm_cdf(z);
    let side = if p_yes > 0.5 { "yes" } else { "no" };
    let fair = if side == "yes" { p_yes } else { 1 - p_yes };
    // The normal curve's tails are too thin for BTC: cap the claim.
    if fair > ctx.params.fair_cap { fair = ctx.params.fair_cap; }
    if fair < ctx.params.min_fair { return #{ hold: `fair ${fair} below ${ctx.params.min_fair} (z ${z})` }; }

    let book = if side == "yes" { ctx.yes } else { ctx.no };
    if book.ask > ctx.params.max_price { return #{ hold: `ask ${book.ask} above ${ctx.params.max_price}` }; }
    let edge = fair - book.ask - taker_fee(book.ask);
    if edge < ctx.params.min_edge { return #{ hold: `edge ${edge} below ${ctx.params.min_edge}` }; }

    #{ buy: side, price: book.ask, shares: ctx.params.contracts,
       reason: `fair ${fair}, edge ${edge}, level ${level} vs strike ${ctx.strike}, z ${z}` }
}

// Held to the settlement: nothing to decide.
fn exit(ctx, pos) {
    ()
}
