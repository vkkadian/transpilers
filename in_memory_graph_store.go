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
    // Execute SPARQL query
    iter := store.QuadStore().ExecuteString(query)
    defer iter.Close()
    
    // Print query solutions
    for {
        // Next solution
        sol, ok := iter.NextSolution()
        if !ok {
            break
        }
        // Print solution variables
        fmt.Println(sol)
    }
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
            err := loadTurtleFiles(filepath.Join(directory, fileInfo.Name()), store)
            if err != nil {
                return err
            }
        } else {
            // If Turtle file, load into Cayley graph
            if fileInfo.Mode().IsRegular() && filepath.Ext(fileInfo.Name()) == ".ttl" {
                err := readAndLoadTurtleFile(filepath.Join(directory, fileInfo.Name()), store.QuadWriter())
                if err != nil {
                    return err
                }
            }
        }
    }
    return nil
}

// readAndLoadTurtleFile reads a Turtle file and adds its quads to the graph
func readAndLoadTurtleFile(filePath string, w quad.Writer) error {
    file, err := os.Open(filePath)
    if err != nil {
        return err
    }
    defer file.Close()

    // Read the Turtle file and add its quads to the writer
    dec := quad.NewDecoder(file, quad.Turtle)
    for {
        q, err := dec.ReadQuad()
        if err != nil {
            if err == io.EOF {
                break
            }
            return err
        }
        w.WriteQuad(q)
    }

    return nil
}
