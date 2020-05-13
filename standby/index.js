var mc = require('minecraft-protocol');

var server = mc.createServer({
    'online-mode': false,
    encryption: true,
    host: '0.0.0.0',
    port: 25565,
    version: '1.15.2',
    motd: 'Lambdacraft standby server',
});

var counter = 0;
server.on('connection', function(client) {
    server.motd = "Lambdacraft Standby Server: " + counter++
});
