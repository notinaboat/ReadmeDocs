#!/bin/bash

# HTML Header.
cat << EOF
<html>
<head>
<meta charset="utf-8"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.2.0/styles/default.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.2.0/highlight.min.js"></script>
<script>hljs.highlightAll();</script>
</head>
<body>
<pre>
<code>
EOF

# Code from stdin.
cat | sed '
    s/\&/\&amp;/g 
    s/</\&lt;/g
    s/>/\&gt;/g
'

# Footer with `git describe` output.
cat << EOF
</code>
</pre>
<hr>
<small><i>
EOF
echo "<pre>Version: $(git describe --tags) <a href=\"https://git-scm.com/docs/git-describe\">(git describe)</a></pre>"
cat << EOF
</i></small>
</body>
</html>
EOF
