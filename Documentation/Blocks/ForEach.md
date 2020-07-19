<h2>`ForEach` Blocks
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

ForEach loops over collections of [`Identifiable`](https://nshipster.com/identifiable/)
objects (structs, enums, objects).
They "repeat" the content within.

```swift
enum BreadType: CaseIterable, Hashable, Identifiable {
  case wheat, white, rhy
  var name: String { return "\(self)".capitalized }
}

struct BreadPicker: Blocks {
  
  @Binding<BreadType> var breadType

  var body: some View {
    Picker("Bread", selection: $breadType) {
      ForEach(BreadType.allCases) { breadType in
        Text(breadType.name).tag(breadType)
      }
    }
  }
}
```
