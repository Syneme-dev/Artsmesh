package restserver

import (
	"fmt"
	"os"
    "log"
    "net/http"
	"artsmesh/amusers"
	"encoding/json"
)

type AMRestServer struct{
	Response  *amusers.AMUserRESTResponse
	RestPort string
}

func (server *AMRestServer) getUsers(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(os.Stdout, "GetAllUsers requst coming...")
	usersObj := server.Response
	
	userlist, err := json.Marshal(usersObj)
	if err == nil{
		userlistStr := string(userlist[:])
		fmt.Fprintf(w, userlistStr)
	}
}

func (server *AMRestServer) StartRestServer(){
	fmt.Fprintln(os.Stdout, "starting rest server...")
	
	server.Response = new(amusers.AMUserRESTResponse)
	server.Response.Version = "1"
	server.Response.UserListData = nil
	
	
	http.HandleFunc("/", server.getUsers)
	err := http.ListenAndServe(server.RestPort, nil)
	if	err != nil{
		log.Fatal("listen and serve failed!")
		os.Exit(1)
	}
}


