import System.Process (readProcess)
import Control.Concurrent (threadDelay)
import Data.List (isPrefixOf)
import System.Environment (getEnv)
import Network.Wreq (get)

main :: IO ()
main = do
    port <- getEnv "RCON_PORT"
    putStrLn port
    stopInactiveServer 0
    shutdownVM

-- A wrapper around readProcess to call the rcon-cli script with given args.
rcon :: [String] -> IO String
rcon cmds =
    readProcess
        "/home/mmachenry/bin/rcon-cli"
        (["--password", "minecraft"] ++ cmds)
        ""

-- Infinitely loops to check server activity. Upon multi loops with no activity
-- it will send a message to shutdown the server and then this loop will also
-- terminate.
stopInactiveServer :: Int -> IO ()
stopInactiveServer tries = do
    threadDelay (10 * 1000000)
    inactive <- serverIsInactive
    putStrLn ("Server inactive: " ++ show inactive)
    if inactive
    then if (tries > 2)
         then stopServer
         else stopInactiveServer (tries + 1)
    else stopInactiveServer 0
    
-- Connects to server with rcon. Returns True if players online now.
serverIsInactive :: IO Bool
serverIsInactive = do
    message <- rcon ["list"]
    return $ "There are 0 of a max" `isPrefixOf` message

-- Connects to server with rcon, announces shutdown and issues stop command.
stopServer :: IO ()
stopServer = do
    _ <- rcon ["say", "The server is inactive. Stopping."]
    _ <- rcon ["stop"]
    return ()

shutdownVM :: IO ()
shutdownVM = do
    r <- get "https://us-central1-minecraft-experimentation.cloudfunctions.net/stopInstance"
    print r
