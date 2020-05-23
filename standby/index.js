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

    vm.start()
    .then((vm_response) => {
        const operation = vm_response[0]
        const apiResponse = vm_response[1]
        console.log(operation)
        console.log(apiResponse)
        const newIp = "127.0.0.1"
        const newARecord = dnsZone.record('a', {
            name: 'ninjavitis.com.',
            data: newIp,
            ttl: ttl
        })
        return dnsZone.replaceRecords('a', newARecord)
    }).then((dns_response) => {
        const change = dns_response[0];
        const apiResponse = dns_response[1];
    }).catch((err) => {
        console.log(err)
    })
})
