#!/bin/bash
pkill -f "hugo server" || true
cd /Users/joonkyu_kang/wiki/SmallzooDevWiki
hugo server -D 