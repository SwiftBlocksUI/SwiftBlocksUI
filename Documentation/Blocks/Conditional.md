<h2>Conditional Blocks
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

Conditionals are directly supported by the function builder syntax:

```
  if order.spread != .none {
    TitledField("Spread") { 
      order.spread.name 
    }
  }
  else {
    Text("It ain't got no spread!")
  }
}
```

