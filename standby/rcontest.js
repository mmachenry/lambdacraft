import { Rcon } from "rcon-client"
 
const rcon = await Rcon.connect({
    host: "localhost", port: 25575, password: "1234"
})
 
console.log(await rcon.send("list"))
 
let responses = await Promise.all([
    rcon.send("help"),
    rcon.send("whitelist list")
])
 
for (response of responses) {
    console.log(response)
}
 
rcon.end()
