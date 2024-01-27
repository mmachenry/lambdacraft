import { useState } from 'react'
import axios from 'axios'

const url = "https://oa5ejfbo46.execute-api.us-east-1.amazonaws.com/prod/start_server"

interface IStatus {
  message: string;
  info: object;
  ips: string[];
}

function App() {
  const [status, setStatus] = useState<IStatus|null>(null)

  axios.get({
    method: 'get',
    url: url,
    withCredentials: false,
  }).then((response) => {
    console.log(response)
    //setStatus(response)
  })

  return (
    <>
      {status ? JSON.stringify(status) : "null" }
    </>
  )
}

export default App
