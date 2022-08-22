#!/bin/zsh -e

mydir=${0:a:h}
cd $mydir/.

(
  echo "
<h1>Tracey's published GitHub repositories</h1>

<ul>"

  for REPO in $(wget -qO- 'https://api.github.com/users/traceypooh/repos?per_page=1000'| jq -r '.[] |select(.has_pages) .name' |sort |fgrep -v traceypooh.github.com); do
    set -x
    URL=traceypooh.github.io/$REPO
    set +x
    GH=github.com/traceypooh/$REPO
    [ $REPO = "blogtini" ]  &&  URL=$REPO.com
    [ $REPO = "poohbot" ]   &&  URL=$REPO.com

    echo "
<li>
  <b>
    <a href='https://$URL'>$REPO</a>
  <b>
  <small>
    <i>
      (<a href='https://$GH'>github source</a>)
    </i>
  </small>
</li>"

  done
  echo "</ul>"
) >| index.html
