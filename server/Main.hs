import System.Process (readProcess)
import System.IO (hSetBuffering, stdout, BufferMode(..))
import Control.Concurrent (threadDelay)
import Control.Monad (void)
import Data.List (isPrefixOf)
import System.Posix.Daemonize (daemonize)
import System.Environment (getArgs)

main :: IO ()
main = daemonize monitorServer

-- The main process to monitor the server and shut it down if it's inactive
monitorServer :: IO ()
monitorServer = stopInactiveServer 0

-- A wrapper around readProcess to call the rcon-cli script with given args.
rcon :: [String] -> IO String
rcon cmds =
    readProcess "/usr/local/bin/rcon-cli"
        (["--password", "LambdaCraft"] ++ cmds) ""

-- Infinitely loops to check server activity. Upon multi loops with no activity
-- it will send a message to shutdown the server and then this loop will also
-- terminate.
stopInactiveServer :: Int -> IO ()
stopInactiveServer tries = do
    threadDelay (2*60*oneSecond)
    inactive <- serverIsInactive
    if inactive
    then if (tries > 2)
         then stopServer
         else stopInactiveServer (tries + 1)
    else stopInactiveServer 0
    where oneSecond = 1000000
    
-- Connects to server with rcon. Returns True if players online now.
serverIsInactive :: IO Bool
serverIsInactive = do
    message <- rcon ["list"]
    return $ "There are 0 of a max" `isPrefixOf` message

-- Connects to server with rcon, announces shutdown and issues stop command.
stopServer :: IO ()
stopServer = do
    void $ rcon ["say", "The server is inactive. Stopping."]
    void $ rcon ["stop"]
