package restserver

import (
	"fmt"
	"os"
    "log"
    "net/http"
	"artsmesh/amusers"
	"encoding/json"
	"sync"
)

type AMRestServer struct{
	Response  *amusers.AMUserRESTResponse
	RestPort string
	RestLock sync.RWMutex
}

func(server *AMRestServer) GetResponseData()(*amusers.AMUserRESTResponse){
	server.RestLock.RLock()
	usersObj := server.Response
	server.RestLock.RUnlock()
	return usersObj
}
	
func(server *AMRestServer) SetResponseData(data *amusers.AMUserRESTResponse){
	server.RestLock.Lock()
	server.Response = data
	server.Response.Version = data.Version
	server.Response.UserListData = data.UserListData
	server.RestLock.Unlock()
}

func (server *AMRestServer) getUsers(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(os.Stdout, "GetAllUsers requst coming...")
	usersObj := server.GetResponseData()
	
	userlist, err := json.Marshal(usersObj)
	if err == nil{
		userlistStr := string(userlist[:])
		fmt.Fprintf(w, userlistStr)
	}
}

func (server *AMRestServer) StartRestServer(){
	fmt.Fprintln(os.Stdout, "starting rest server...")
	
	server.Response = new(amusers.AMUserRESTResponse)
	server.Response.Version = "0"
	server.Response.UserListData = nil
	
	
	http.HandleFunc("/", server.getUsers)
	err := http.ListenAndServe(server.RestPort, nil)
	if	err != nil{
		log.Fatal("listen and serve failed!")
		os.Exit(1)
	}
}


