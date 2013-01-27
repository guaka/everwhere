cd "$(dirname "$0")"/..

git push

echo '<template name="last-commit">' > lastcommitdate.html
git log -1 --format="%ci" >> lastcommitdate.html
echo '</template>' >> lastcommitdate.html

meteor deploy --debug everwh.re
