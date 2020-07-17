<h2>SwiftBlocksUI: Xcode Setup
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

Work in Progress. Extract from 
[Instant “SwiftUI” Flavoured Slack Apps](https://www.alwaysrightinstitute.com/swiftblocksui/),
needs adjustments.

TODO:
- Add app setup links
- Adjust content for standalone page
- Fix video

<hr>

To get going, we need to create an Xcode tool project and
add the
[SwiftBlocksUI](https://github.com/SwiftBlocksUI/SwiftBlocksUI.git)
and
[cows](https://github.com/AlwaysRightInstitute/cows.git)
package dependencies.

> All this can be done with any editor on any platform,
> the app even runs as a single file shell script via swift-sh!

Startup Xcode, select "New Project" and then the "Command Line Tool" template:
<center>
  <img src="https://www.alwaysrightinstitute.com/images/blocksui/xcode-1-cmdline-tool-cut.png" />
</center>

Give the project a name (I've choosen "AvocadoToast") and save it wherever
you like. Then select the project in the sidebar, and choose the
"Swift Packages" option and press the "+" button:
<center>
  <img src="https://www.alwaysrightinstitute.com/images/blocksui/xcode-4-pkgs-empty-marked-up.png" />
</center>

In the upcoming package browser enter the SwiftBlocksUI package URL:
"`https://github.com/SwiftBlocksUI/SwiftBlocksUI.git`".
<center>
  <img src="https://www.alwaysrightinstitute.com/images/blocksui/xcode-5-pkgs-swiftblocksui-cut.png" />
</center>

In the following dialog which lists the contained products,
you can choose all you want, but `SwiftBlocksUI` is the one required:
<center>
  <img src="https://www.alwaysrightinstitute.com/images/blocksui/xcode-6-pkgs-product-cut.png" />
</center>

> SwiftBlocksUI is the module which brings all the others together.
> They can also be used individually.

Repeat the process to add the
[cows](https://github.com/AlwaysRightInstitute/cows.git)
package, using this url:
`https://github.com/AlwaysRightInstitute/cows.git` 
(one can also just search for "cows" in that panel).

Xcode project ✅