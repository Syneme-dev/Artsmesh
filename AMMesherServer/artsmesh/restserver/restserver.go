package restserver

import (
	"fmt"
	"errors"
	"os"
    "github.com/ant0ine/go-json-rest/rest"
    "net/http"
	"artsmesh/amusers"
)

type AMRestServer struct{
	Response  *amusers.AMUserRESTResponse
	RestPort string
}

func (server *AMRestServer) StartRestServer(){
	fmt.Fprintln(os.Stdout, "starting rest server...")
	
	server.Response = new(amusers.AMUserRESTResponse)
	server.Response.Version = "1"
	server.Response.UserListData = nil
	
	var err error
	if server.RestPort == ""{
		err = errors.New("didn't set rest server port")
		fmt.Fprintln(os.Stderr, err.Error())
		os.Exit(1)
	}
	
	 handler := rest.ResourceHandler{
        EnableRelaxedContentType: true,
    }
	
    err = handler.SetRoutes(
        rest.RouteObjectMethod("GET", "/users", server, "GetAllUsers"),
    )
	if	err != nil{
		fmt.Fprintln(os.Stderr, err.Error())
		os.Exit(1)
	}
	
	err = http.ListenAndServe(server.RestPort, &handler)
	if	err != nil{
		fmt.Fprintln(os.Stderr, err.Error())
		os.Exit(1)
	}
}

func (server *AMRestServer) GetAllUsers(w rest.ResponseWriter, r *rest.Request) {
	fmt.Fprintln(os.Stdout, "GetAllUsers requst coming...")
	usersObj := server.Response
	if	usersObj != nil{
		w.WriteJson(&usersObj)
	}
}
