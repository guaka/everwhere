
require = __meteor_bootstrap__.require
path = require("path")
fs = require('fs')
FB = null

fbPath = 'node_modules/fb'

base = path.resolve('.');
if base == '/'
  base = path.dirname(global.require.main.filename);

publicPath = path.resolve(base+'/public/'+fbPath);
staticPath = path.resolve(base+'/static/'+fbPath);

if (path.existsSync(publicPath))
  FB = require(publicPath)
else if (path.existsSync(staticPath))
  FB = require(staticPath)
else
  console.log('node_modules not found')
