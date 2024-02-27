package main

import (
    "fmt"
    "os"

    "github.com/cayleygraph/cayley"
    "github.com/cayleygraph/cayley/graph"
    "github.com/cayleygraph/cayley/quad"
    "github.com/cayleygraph/cayley/schema"
    "github.com/cayleygraph/quad/voc/rdf"
)

func main() {
    // Initialize Cayley graph
    store := makeCayleyMemoryGraph()
    defer store.Close()

    // Directory containing Turtle files
    directory := "/path/to/directory"

    // Load Turtle files recursively into Cayley graph
    err := loadTurtleFiles(directory, store)
    if err != nil {
        fmt.Println("Error loading Turtle files:", err)
        return
    }

    // Query the graph (code for recursive property path query goes here)
    // Query the graph (recursive property path SPARQL query)
    query := `
        PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
        PREFIX ex: <http://example.org/>
    
        SELECT ?s ?o
        WHERE {
            ?s ex:property1 ?o .
            {
                ?s ex:property2 ?o .
                ?o ex:property3 ?s .
            } UNION {
                ?s ex:property4 ?o .
                ?o ex:property5* ?s .
            }
        }
    `
    readFromStore(query, store)
}

// makeCayleyMemoryGraph creates an in-memory Cayley graph
func makeCayleyMemoryGraph() *cayley.Handle {
    // Initialize Cayley graph in memory
    graph.InitQuadStore("memstore", nil)

    // Open and use the memory store
    store, err := cayley.NewMemoryGraph()
    if err != nil {
        fmt.Println("Error creating memory graph:", err)
        os.Exit(1)
    }

    return store
}

// loadTurtleFiles recursively loads Turtle files from a directory into a Cayley graph
func loadTurtleFiles(directory string, store *cayley.Handle) error {
    // Open directory
    dir, err := os.Open(directory)
    if err != nil {
        return err
    }
    defer dir.Close()

    // Get list of files in directory
    fileInfos, err := dir.Readdir(-1)
    if err != nil {
        return err
    }

    // Iterate over files
    for _, fileInfo := range fileInfos {
        if fileInfo.IsDir() {
            // If directory, recursively call loadTurtleFiles
            err := loadTurtleFiles(directory+"/"+fileInfo.Name(), store)
            if err != nil {
                return err
            }
        } else {
            // If Turtle file, load into Cayley graph
            if fileInfo.Mode().IsRegular() && fileInfo.Name()[len(fileInfo.Name())-4:] == ".ttl" {
                err := store.LoadQuadFile(fmt.Sprintf("%s/%s", directory, fileInfo.Name()), rdf.Default)
                if err != nil {
                    return err
                }
            }
        }
    }
    return nil
}
func readFromStore(query string, store *cayley.Handle) error {

// Execute SPARQL query
solutions := make(chan quad.Value)
err := store.ExecuteQuadPath(query).Iterate(nil).EachValue(nil, func(value quad.Value) {
    solutions <- value
})
if err != nil {
    fmt.Println("Error executing SPARQL query:", err)
    return err
}

// Print query solutions
for sol := range solutions {
    fmt.Println(sol)
}

  
}
