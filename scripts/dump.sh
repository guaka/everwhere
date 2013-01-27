cd "$(dirname "$0")"/..

mongodump $(meteor mongo -U everwh.re | coffee scripts/url2args.cfee)