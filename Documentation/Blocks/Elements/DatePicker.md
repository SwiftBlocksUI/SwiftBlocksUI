<h2>`DatePicker` Blocks
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

A picker to pick a date. That is year, month and day - NOT time.

The `selection` can be bound to either of those:
- `DatePicker.YearMonthDay` (a BlocksUI struct w/ year/month/day properties)
- a Foundation `Date` (use w/ care)
- a Foundation `DateComponents`

Example:
```
DatePicker("Pick a date!", selection: $date)
```

A `DatePicker` in an [`Actions`](../TopLevel/Actions.md) block,
and as an [`Accessory`](Accessory.md) in a
[`Section`](../TopLevel/Section.md) block:
![block types](https://zeezide.de/img/blocksui/BlockTypes-Annotated.png)

Docs: https://api.slack.com/reference/block-kit/block-elements#multi_select
