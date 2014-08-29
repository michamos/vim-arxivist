#!/usr/bin/python

# arxiv2md.py: fetch the latest arXiv listings and transform them to markdown
# Copyright (C) 2014 Micha Moskovic

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
# OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 
from __future__ import print_function
import feedparser
import subprocess
import time
import re

def parse_archive(archive, updates=True, link_to="pdf"):
    out = u""
    d = feedparser.parse("http://export.arxiv.org/rss/{}?version=2.0".format(archive))
    day = time.strftime("%F", d.feed.updated_parsed)
    if updates:
        update_string=u"with replacements"
    else:
        update_string=u""
    out=out + u"<h1>{} arXiv of {} {}</h1>\n".format(a, day, update_string)
    for entry in d.entries:
        if (not updates) and entry.title.endswith("UPDATED)"):
            break
        out = out + u"<h2>{}</h2>\n".format(entry.title)
        out = out + u"<a href='{}'>Link</a>\n".format(entry.link.replace("abs",link_to,1))
        out = out + entry.summary+u"\n"
    pandoc = subprocess.Popen("pandoc -R -f html -t markdown --atx-headers".split(), stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    (result,error) = pandoc.communicate(input=out)
    pandoc.stdout.close()
    # Pandoc conversion to markdown escapes LaTeX, we need to unescape it
    result = re.sub(r"\\([\\$^_*<>])", r"\1", result)
    if error:
        result = result + u"*ERROR: Pandoc conversion failed with error {}*\n".format(error)
    return result

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="fetch the latest arXiv listings and transform them to markdown")
    parser.add_argument("archive", help="an archive to fetch", nargs="+")
    parser.add_argument("-r", "--replacements", help="also fetch the replacements", action="store_true", default=False)
    parser.add_argument("-a", "--link-to-abstract", help="make the links point to the abstracts rather than the PDFs", action="store_true", default=False)
    args = parser.parse_args()
    if args.link_to_abstract:
        link_to = "abs"
    else:
        link_to = "pdf"
    for a in args.archive:
        print(parse_archive(a,args.replacements,link_to))

