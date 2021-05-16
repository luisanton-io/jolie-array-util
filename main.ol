from console import Console

type FindUniqueRequest {
    array1*: any
    array2*: any
}

type FindUniqueResponse {
    array*: any
}

type RemoveDuplicatesRequest {
    array*: any
}

type RemoveDuplicatesResponse {
    array*: any
}

interface IArrayUtils {
    RequestResponse:
        findUniqueInFirst(FindUniqueRequest)(FindUniqueResponse),
        removeDuplicates(RemoveDuplicatesRequest)(RemoveDuplicatesResponse)
}


service ArrayUtils {
    execution: concurrent

    embed Console as Console
    
    inputPort http {
        location: "socket://localhost:8080"
        protocol: http { format = "json" }
        interfaces: IArrayUtils
    }
    
    outputPort local {
        location: "socket://localhost:8080"
        protocol: http { format = "json" }
        interfaces: IArrayUtils
    }

    main {
        [findUniqueInFirst(req)(res) {
            for (counter = 0, counter < #req.array1, counter++) {
                found = false
                for (counter2 = 0, !found && counter2 < #req.array2, counter2++) {
                    if (req.array1[counter] == req.array2[counter2]) {
                        found = true
                    }
                }

                if (!found) {
                    res.array[#res.array] = req.array1[counter]
                }
            }

            removeDuplicates@local(res)(res)
        }]
        
        [removeDuplicates(req)(res) {
            for(counter = 0, counter < #req.array, counter++) {
                found = false
                counter2 = 0
                while(!found && counter2 < #res.array) {
                    if (req.array[counter] == res.array[counter2++]) {
                        found = true
                    }
                }

                if (!found) {
                    res.array[#res.array] = req.array[counter]
                }

            }   
        }]
    
    }
}