#!/bin/zsh -eux

mydir=${0:a:h}
cd $mydir/.

# regen sitemap
wget -qO sitemap.xml https://traceypooh.github.io/poohtini/sitemap.xml
perl -i -pe 's=</urlset>=\n  <url>\n    <loc>http://traceypooh.github.com/</loc>\n  </url>\n</urlset>=' \
  sitemap.xml


wget -qO- 'https://api.github.com/users/traceypooh/repos?per_page=1000'| jq -r '.[] |select(.has_pages) | [.name, .description] | @tsv' |sort |fgrep -v traceypooh.github.com |tee repos.tsv

(
  echo "
<link href='https://esm.ext.archive.org/bootstrap@5.1.3/dist/css/bootstrap.min.css' rel='stylesheet'>
<style>
  body { margin: 50px }
  a { text-decoration:none }
  img { max-width:100%; height:auto; }
</style>

<h1>Tracey's published GitHub repositories</h1>

<ul>"

  IFS=$'\n'; # NEWLINE / ENTER / RETURN splitting, not SPACE
  for LINE in $(cat repos.tsv); do
    set -x
    REPO=$(echo "$LINE" | cut -f1)
    DESC=$(echo "$LINE" | cut -f2-)
    URL=traceypooh.github.io/$REPO
    set +x
    GH=github.com/traceypooh/$REPO
    [ $REPO = "blogtini" ]  &&  URL=$REPO.com
    [ $REPO = "poohbot" ]   &&  URL=$REPO.com

    [ $REPO = "blogtini" ]  &&  DESC="$DESC<br><img src='https://blogtini.com/img/blogtini.png'>"

    echo "
<li>
  <b>
    <a href='https://$URL'>$REPO</a>
  </b>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <small>
    <i>
      <a style='color:gray' href='https://$GH'>(source)</a>
    </i>
  </small>
  <p>$DESC</p>
</li>"

  done
  echo "</ul>"
) >| index.html
