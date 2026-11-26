---
name: test
description: What to test and what not to. Use whenever writing or adding tests, or deciding whether a change needs tests.
---

A test is worth writing only when running the code tells you something that reading it can't. Test as little as
possible to reach confidence that the code works, and spend that effort where you are most likely to be wrong.

## Don't test what reading proves

If reading the code is enough to see there is no bug, write no test. Such a test only restates the code and has to be
maintained with it. For example:

1. Constructors, getters, setters, and plain property mapping.
2. Passthroughs and delegation that only forward a call.
3. Straight-line logic whose every path you can follow in your head.
4. A mock returning what it was set up to return.

## Test what reading can't settle

Write a test for anything you are not completely sure behaves exactly as you read it, or whose behavior you can't
work out from the code at all. Your confidence after reading is not reliable on its own, so treat these as needing a
test even when the code looks obviously right:

1. **Crossing into code you didn't write**: how a framework or library actually behaves, such as query translation,
   serialization, model or config binding, validation, or UI reactivity. A test that pins this down is a learning
   test.
2. **Computations**: algorithms, formulas, aggregations, conversions, anything that produces a result you would
   have to work out by hand to check. Reading shows the steps, not that the output is right, and off-by-one,
   boundary and accumulation errors hide there. Trivial arithmetic such as a sum of two fields isn't included.
3. **Semantics that are easy to misread**: regex, date and time, time zones, culture-sensitive parsing and formatting,
   floating point, rounding, string comparison and sorting.
4. **Timing and evaluation order**: concurrency, async ordering, cancellation, deferred or lazy evaluation.
5. **Combinations too many to trace**: many branches or inputs that interact, edge cases at boundaries, empty and
   null inputs where the outcome isn't obvious.
6. **Behavior that depends on code you haven't read**, and existing code whose behavior you can't tell by reading it.
   For the latter, record what it does now before changing it; that is a characterization test.
7. **A bug that got through.** It proves reading wasn't enough for that code, so fix it with a test that reproduces
   it.
