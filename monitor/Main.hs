import System.Process (readProcess)
import System.IO (hSetBuffering, stdout, BufferMode(..))
import Control.Concurrent (threadDelay)
import Control.Monad (void)
import Data.List (isPrefixOf)
import System.Environment (getEnv)

main :: IO ()
main = do
    hSetBuffering stdout NoBuffering
    threadDelay (2 * 60 * 1000000)
    stopInactiveServer 0

-- A wrapper around readProcess to call the rcon-cli script with given args.
rcon :: [String] -> IO String
rcon cmds = do
    port <- getEnv "RCON_PORT"
    host <- getEnv "LAMBDACRAFT_HOST"
    readProcess
        "/rcon-cli"
        (["--password", "minecraft",
          "--port", port,
          "--host", host] ++ cmds)
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
    void $ rcon ["say", "The server is inactive. Stopping."]
    void $ rcon ["stop"]
