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

var counter = 0;
server.on('connection', (client) => {
    server.motd = "Lambdacraft Standby Server: " + counter++
    console.log(`Received connection number ${counter}.`)
    // Don't try to start the server multiple times.
    if (counter > 1) {
        return
    }

    vm.start()
    .then(() => {
        return vm.waitFor('RUNNING')
    }).then(() => {
        return vm.get()        
    }).then((data) => {
        const response = data[1];
        const newIp = response.networkInterfaces[0].accessConfigs[0].natIP
        const newARecord = dnsZone.record('a', {
            name: 'ninjavitis.com.',
            data: newIp,
            ttl: ttl
        })

        return dnsZone.replaceRecords('a', newARecord)
    }).then(() => {
        // May want to wait for DNS update to complete and log it here.
    }).catch((err) => {
        console.log(err)
    })
})
