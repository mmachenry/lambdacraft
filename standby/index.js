"use strict";

const mc = require('minecraft-protocol');
const Compute = require('@google-cloud/compute');

const serverVmName = 'instance-1';
const gcpZone = 'us-central1-a';

const compute = new Compute();
const zone = compute.zone(gcpZone);
const vm = zone.vm(serverVmName);

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
    console.log(`Received connection number ${counter}.`);

    vm.start().then((data) => {
        const operation = data[0];
        const apiResponse = data[1];
        console.log(operation);
        console.log(apiResponse);
    });
});