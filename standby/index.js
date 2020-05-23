"use strict";

const mc = require('minecraft-protocol');
const Compute = require('@google-cloud/compute');
const {DNS} = require('@google-cloud/dns');

const serverVmName = 'instance-1';
const gcpZone = 'us-central1-a';

const compute = new Compute();
const zone = compute.zone(gcpZone);
const vm = zone.vm(serverVmName);

const dns = new DNS();
const dnsZone = dns.zone('ninjavitis-zone');
const ttl = 30;

var server = mc.createServer({
    'online-mode': false,
    encryption: true,
    host: '0.0.0.0',
    port: 25565,
    version: '1.15.2',
    motd: 'Lambdacraft standby server',
});

function updateDns(newIp) {
      const newARecord = dnsZone.record('a', {
        name: 'ninjavitis.com.',
        data: newIp,
        ttl: ttl
      });

      dnsZone.replaceRecords('a', newARecord).then((data) => {
        const change = data[0];
        const apiResponse = data[1];
      });
}

var counter = 0;
server.on('connection', (client) => {
    server.motd = "Lambdacraft Standby Server: " + counter++
    console.log(`Received connection number ${counter}.`);

    vm
        .start()
        .then((data) => {
            const operation = data[0];
            const apiResponse = data[1];
            console.log(operation);
            console.log(apiResponse);
        })
        .catch(() => {
            console.log(`something bad happened during VM startup.`)
        });
});