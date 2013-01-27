cd ~/everwhere

git push

echo '<template name="last-commit">' > lastcommitdate.html
git log -1 --format="%ci" >> lastcommitdate.html
echo '</template>' >> lastcommitdate.html

meteor deploy --debug everwh.re
meteor deploy --debug everwhere.meteor.com