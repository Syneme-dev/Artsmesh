package udpserver

import (
	"net"
	"fmt"
	"os"
	"io"
	"errors"
	"strings"
	"bytes"
	"time"
	"artsmesh/restserver"
	"artsmesh/amusers"
	"encoding/json"
	"container/list"
	"strconv"
)

type AMUdpServer struct{
	UserTimeout float64
	IsIpv4 bool
	UdpPort string
	RestServer *restserver.AMRestServer
	ChangeNumber int
	ChangeTime time.Time
	UserStoreList *list.List
}

func (server *AMUdpServer)StartUdpServer(){

	fmt.Fprintln(os.Stdout, "starting heartbeating server ...")
	
	var udpAddr *net.UDPAddr
	var err error
	if	server.RestServer == nil{
		err = errors.New("did not set rest server")
		fmt.Fprintln(os.Stderr, err.Error())
		os.Exit(1)
	}
	
	server.UserStoreList = list.New()
	server.ChangeNumber = 0
	server.ChangeTime = time.Now()

	if server.IsIpv4 {
		udpAddr, err = net.ResolveUDPAddr("udp4", server.UdpPort)
	}else{
		udpAddr, err = net.ResolveUDPAddr("udp6", server.UdpPort)
	}
	if	err  != nil{
		fmt.Fprintf(os.Stderr, "Fatal Error", err.Error())
		os.Exit(1)
	}
	
	fmt.Fprintln(os.Stdout, "heartbeating server address is:" + udpAddr.String())
	
	conn, err := net.ListenUDP("udp", udpAddr)
	if	err  != nil{
		fmt.Fprintf(os.Stderr, "Fatal Error", err.Error())
		os.Exit(1)
	}
	
	for{
		server.HandleClient(conn)
	}
}

func (server *AMUdpServer) HandleClient(conn *net.UDPConn){
	var buf [1024]byte

	n, addr, err := conn.ReadFromUDP(buf[0:])
	if err != nil {
		fmt.Fprintf(os.Stdout, "ReadFromUDP failed")
		return
	}
	
	fmt.Fprintln(os.Stdout, "Handling Client ...")
	fmt.Fprintf(os.Stdout, "%d bytes received from %s \n", n, addr.String())
	
	len := bytes.Index(buf[:], []byte{0})
	fmt.Fprintf(os.Stdout, "received json len: %d \n", len)
	jsonStream := string(buf[:len])
	fmt.Fprintf(os.Stdout, "received json content: %s \n", jsonStream)

	req := server.ParseJsonString(jsonStream)
	if	req == nil {
		return
	}

	var isDone bool = false
	if req.Action == "delete"{	
		server.HandleDeleteUser(req.UserId)
	}else if req.Action == "new"{
		isDone = server.HandleNewUser(req)
	}else if req.Action == "update"{
		isDone = server.HandleUpdateUser(req)
	}else if req.Action == "heartbeat"{
		isDone = server.HandleUpdateUser(req)
	}else{
		return 	
	}
	
	if server.ChangeNumber > 0 {
		server.UpdateRestServer()
	}
	
	if req.Action == "delete"{
		return
	}
	
	var udpres amusers.AMUserUDPResponse
	udpres.Action = req.Action
	udpres.Version = server.RestServer.Response.Version
	if isDone == true{
		udpres.UserContentMd5 = req.UserContentMd5
		udpres.IsSucceeded = "YES"
	}else{
		udpres.IsSucceeded = "NO"
	}
	
	udpResStr, err := json.Marshal(udpres)
	if err == nil{
		fmt.Fprintf(os.Stdout, "the udp response is: %s\n", udpResStr)	
	
		udpResBytes := []byte(udpResStr)
		_, err := conn.WriteToUDP(udpResBytes, addr)
		if	err != nil{
			fmt.Fprintf(os.Stdout, "Write to Udp failed!")
			return
		}
	}else{
		fmt.Fprintf(os.Stdout, "error: %s", err.Error())	
		return
	}

}

func (server *AMUdpServer)UpdateRestServer(){
	fmt.Fprintf(os.Stdout, "There are %d user on server now!\n",  server.UserStoreList.Len())
		
	var RESTResponse amusers.AMUserRESTResponse
	for e := server.UserStoreList.Front(); e != nil; e = e.Next(){
		userValue := e.Value.(amusers.AMUserStorage)
		RESTResponse.UserListData = append(RESTResponse.UserListData, userValue.UserContent.Copy())
	}
	
	ver, err := strconv.Atoi(server.RestServer.Response.Version)
	if	err != nil {
		fmt.Fprintf	(os.Stderr, "version is incorrect:%s", server.RestServer.Response.Version)
		return;
	}
		
	RESTResponse.Version = fmt.Sprintf("%d", ver + 1)
	server.RestServer.Response = &RESTResponse
		
	server.ChangeNumber = 0 
	server.ChangeTime = time.Now()
}


func (server *AMUdpServer)HandleNewUser(req *amusers.AMUserUDPRequest)bool{
	fmt.Fprintf(os.Stdout, "will add new user")
	var userStoreNew amusers.AMUserStorage
	userStoreNew.UserContent = req.UserContent
	userStoreNew.UserContentMd5 = req.UserContentMd5
	userStoreNew.LastHeartbeat = time.Now()
	server.UserStoreList.PushBack(userStoreNew)
	server.ChangeNumber++
	return true
}


func (server *AMUdpServer)HandleUpdateUser(req *amusers.AMUserUDPRequest)bool{
	
	e := server.UserStoreList.Front()
	for e != nil {
		userValue := e.Value.(amusers.AMUserStorage)
		if	userValue.UserContent.UserId == req.UserId{
			if  userValue.UserContentMd5 != req.UserContentMd5{
				fmt.Fprintf(os.Stdout, "Update request\n")
				userValue.UserContent = req.UserContent
				server.ChangeNumber++
			}
				
			userValue.LastHeartbeat = time.Now()
			server.UserStoreList.MoveToBack(e)
			return true
		}else{
			dur := time.Now().Sub(userValue.LastHeartbeat)
			if dur.Seconds() > server.UserTimeout{
				fmt.Fprintf(os.Stdout, "will remove use")
				server.UserStoreList.Remove(e)
				server.ChangeNumber++
				e = server.UserStoreList.Front()
			}else{
				e = e.Next()
			}
		}
	}

	return false
}

func (server *AMUdpServer)HandleDeleteUser(userId string){
	fmt.Fprintf(os.Stdout, "Deleting user %s\n", userId)
	for e := server.UserStoreList.Front(); e != nil; e = e.Next(){
		userValue := e.Value.(amusers.AMUserStorage)
		if userValue.UserContent.UserId  == userId {
			server.UserStoreList.Remove(e)
			break
		}
	}
}

func (server *AMUdpServer) ParseJsonString(contentStr string) *amusers.AMUserUDPRequest{
	var err error
	var req amusers.AMUserUDPRequest
	dec := json.NewDecoder(strings.NewReader(contentStr))
	for{
		err = dec.Decode(&req); 
		 if err == io.EOF {
			//fmt.Fprintf(os.Stdout, "client request is: %s\n", req.Action)
			if	req.UserContent.UserId != ""{
				fmt.Fprintf(os.Stdout, "userinfo is: %s\n", req.UserContent.UserId)
			}
			break;
		}else if err != nil{
			fmt.Fprintf(os.Stderr, "parse json string failed: %s\n", contentStr)
			fmt.Fprintln(os.Stderr, err.Error())
			return nil;
		}
	}
	
	return &req
}

