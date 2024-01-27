import { useState } from 'react'
import axios from 'axios'
import moment from 'moment'

const url = "https://oa5ejfbo46.execute-api.us-east-1.amazonaws.com/prod/start_server"

interface IStatus {
  message: string;
  info: object;
  ips: string[];
}

function App() {
  const [status, setStatus] = useState<IStatus|null>(null)

  axios.get(url).then((response) => {
    setStatus(response.data)
  })

  return (
    <>
      {status === null ? (
        <p>null</p>
      ) : (
      <>
        <p>{status.message}</p>
        <p>{moment(status?.info?.tasks[0].createdAt).fromNow()}</p>
        <p>{status?.info?.tasks[0].lastStatus} to
           {status?.info?.tasks[0].desiredStatus}</p>
        <p>{status?.info?.ips[0]}</p>
      </>
      )}
    </>
  )
}

export default App
