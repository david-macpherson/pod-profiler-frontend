import webRequest from './utilities/webRequest'
import { HTTPMethods } from './utilities/httpMethods'
import type { AxiosPromise } from 'axios'
import Papa from 'papaparse'
import type { Result } from './types/result'

export function getData(): AxiosPromise<Array<string>> {
    return webRequest({
        url: '/index.json',
        method: HTTPMethods.GET
    })
}

export function getAPIData(csvFile: string): AxiosPromise<Array<Result> | null> {
    return webRequest({
        url: '/' + csvFile,
        method: HTTPMethods.GET,
        transformResponse: [
            (data) => {
                let parsedData = Papa.parse<Result>(data, {
                    header: true,
                    delimiter: ',',
                    dynamicTyping: true,
                    newline: '\n',
                    skipEmptyLines: true
                })

                if (parsedData.errors.length > 0) {
                    parsedData.errors.forEach((error: Papa.ParseError) => {
                        console.error(error.type + ' ' + error.code + ' ' + error.message)
                    })
                    return null
                }

                return parsedData.data
            }
        ]
    })
}
