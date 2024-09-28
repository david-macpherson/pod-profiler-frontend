import axios from 'axios'

// create an axios instance
const webRequest = axios.create({
    baseURL: (import.meta.env.VITE_REST_API_URL === undefined ? './' : import.meta.env.VITE_REST_API_URL) + '/results',
    timeout: 50000 // request timeout
})

export default webRequest
