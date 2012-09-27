set sw=2
set ts=2
set expandtab
"" I sometimes double-quote my comments, and want wrapping to know this.
let &comments = ':"",' . &comments
