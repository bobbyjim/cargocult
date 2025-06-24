grammar G {
	rule TOP { <author-line> }
	rule author-line { 'AUTHOR:' <text-line> }
	rule text-line { <-[\n]>+ }
}

say G.parse("AUTHOR: This is a test."); 

