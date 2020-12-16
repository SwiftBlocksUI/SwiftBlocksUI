<h2>`TimePicker` Blocks
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

A picker to pick a time. That is hour and minute - NOT a date, no seconds.

The `selection` can be bound to either of those:
- `TimePicker.HourMinute` (a BlocksUI struct w/ hour/minute properties)
- a Foundation `DateComponents`

Example:
```
TimePicker("Pick a time!", selection: $time)
```

Docs: https://api.slack.com/reference/block-kit/block-elements#timepicker
