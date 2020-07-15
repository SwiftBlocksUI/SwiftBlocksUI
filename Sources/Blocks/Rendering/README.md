#  Blocks Primitives

A Blocks primitive is a basic element which knows how to render into the
API representation of blocks.
This is in contrast to "user level" Blocks called "components". Components compose other 
Blocks, but do not touch the outgoing representation of API blocks.

A primitive conforms to the `BlocksPrimitive` protocol, which provides a single method:

    func render(in context: BlocksContext) throws

It is pretty confusing, but remember that there are two things: "Blocks", which is what
is used to build SwiftBlocksUI applications. Similar to SwiftUI "Views". Those declare what
content should be _generated_.
And then there are the API level "Block" objects, which is what would be the DOM in HTML
or the RenderGraph in SwiftUI.


## Implementation

The implementation is a little wonky because no classes / inheritance is used,
just enum's and composition. Hence there is A TON of `switch` ing and specific
knowledge about the blocks being built.

The pro thing (depending on your preferences) is that everything is properly typed out :-)
Add a new block in the API? Swift will force you fix all your existing primitives in the
renderers.

Also the nesting is tracked as flags, which is ugh, but done to avoid having to track a full
tree of elements (vs the flat array of blocks).

Another weird thing right now is request handling. Since the block rendering affects
the elementID structure, we essentially have to regenerate everything for the take
values and invoke action phases. 
Can be fixed by adding a proper shadow DOM eventually, this would also remove the
requirement to use State for a distinct transacion.


### The blocks "tree"

The API blocks tree is not really a tree, it is a plain list of API `Block` objects (an enum).
Those blocks can't be nested, but depending on the block they may have other child
specific subelements.
