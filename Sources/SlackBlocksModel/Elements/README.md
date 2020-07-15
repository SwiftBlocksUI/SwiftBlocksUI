#  Block Elements

TODO: some docs

Those are the elements which can be used within blocks,
documented over here:
[BlockKit Block Elements](https://api.slack.com/reference/block-kit/block-elements)

### Select Elements

This is a little special, because there are "multi" and "single" selection versions of each
Select. Only the "multi" seem to be documented still, even though a max_select=1
doesn't trigger an old style single select (but the multiselect popup).

Out of lazyness we encode the Multi versions as single versions if the max-count is set
to 1.
