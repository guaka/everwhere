cd "$(dirname "$0")"/..

git push

echo '<template name="last-commit">' > lastcommitdate.html
git log -1 --format="%ci" >> lastcommitdate.html
echo '</template>' >> lastcommitdate.html

meteor deploy everwhere.meteor.com

cp -av . /tmp/everwherenotest
pushd /tmp/everwherenotest

rm -rf client/lib/jasmine*
rm -rf client/lib/contrib/jasmine*
find . -iname "*.spec.coffee" -exec rm '{}' ';'
meteor deploy --debug everwh.re

popd
rm -rf /tmp/everwherenotest