const mc = require('minecraft-protocol');
const proxy = require("node-tcp-proxy");
const { ECSClient, RunTaskCommand, waitUntilTasksRunning } = require("@aws-sdk/client-ecs");
const { Rcon } = require("rcon-client")
 
const createProxy = () => {
    const newProxy = proxy.createProxy(25565, "209.182.110.15", 25565);
    // newProxy.end(); // To end the proxy
}

const hostMiniServer = () => {
    const server = mc.createServer({
      'online-mode': false,
      encryption: true,
      host: '0.0.0.0',
      port: 25565,
      version: '1.17',
      motd: 'Lambdacraft standby server',
    });

    server.on('connection', (client) => {
        // server.motd = "Lambdacraft Standby Server: " + counter++
        console.log(`Received connection.`)
        // Don't try to start the server multiple times.
    })
}

const startAndWaitUntilECSTaskRunning = async (region, clusterARN, taskDefinition) => {
    const ecsClient = new ECSClient({ "region": region })
    const runTaskCommand = new RunTaskCommand({
        cluster: clusterARN,
        taskDefinition: taskDefinition,
        /*
        launchType: launchType,
        networkConfiguration: {
            awsvpcConfiguration: {
                assignPublicIp: assignPublicIp,
                subnets: subnets,
                securityGroups: securityGroups
            }
        }
        */
    })
    const ecsTask = await ecsClient.send(runTaskCommand)
    const taskArn = ecsTask.tasks?.[0].taskArn
    if (typeof taskArn !== "string") {
        throw Error("Task ARN is not defined.")
    }
    const waitECSTask = await waitUntilTasksRunning(
        {
            "client": ecsClient,
            "maxWaitTime": 600,
            "maxDelay": 1,
            "minDelay": 1,
        }, {
            "cluster": clusterARN,
            "tasks": [taskArn],
        })
    if (waitECSTask.state !== 'SUCCESS') {
        consol.log("server running")
    } else {
        console.log("Wait state was not success: ", wait.ECSTask.state)
    }
}

const serverActive = async () => {
    const rcon = await Rcon.connect({
        host: "localhost", port: 25575, password: "LambdaCraft"
    })
    console.log(await rcon.send("list"))
    rcon.end()
}

serverActive();
