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
	
	updResponse := server.HandleUDPRequest(req)
	if server.ChangeNumber > 0 {
		server.UpdateRestServer()
	}

	if updResponse != nil{
		curData := server.RestServer.GetResponseData()
		updResponse.Version = curData.Version
		
		server.SendUDPResponse(addr, conn, updResponse)
	}
}

func (server *AMUdpServer)SendUDPResponse(addr *net.UDPAddr, conn *net.UDPConn, resObj *amusers.AMUserUDPResponse){
	udpResStr, err := json.Marshal(resObj)
	if err != nil{
		fmt.Fprintf(os.Stdout, "error: %s", err.Error())
		return
	}
	
	udpResBytes := []byte(udpResStr)
	_, err = conn.WriteToUDP(udpResBytes, addr)
	if	err != nil{
		fmt.Fprintf(os.Stdout, "Write to Udp failed!")
	}
}

func (server *AMUdpServer)UpdateRestServer(){
	fmt.Fprintf(os.Stdout, "There are %d user on server now!\n",  server.UserStoreList.Len())
	server.ChangeNumber = 0 
	
	var RESTResponse amusers.AMUserRESTResponse
	for e := server.UserStoreList.Front(); e != nil; e = e.Next(){
		userValue := e.Value.(*amusers.AMUserStorage)
		RESTResponse.UserListData = append(RESTResponse.UserListData, userValue.UserContent.Copy())
	}
	
	curData := server.RestServer.GetResponseData()
	ver, err := strconv.Atoi(curData.Version)
	if	err != nil {
		fmt.Fprintf	(os.Stderr, "version is incorrect:%s", server.RestServer.Response.Version)
		return;
	}
	
	RESTResponse.Version = fmt.Sprintf("%d", ver + 1)
	server.RestServer.SetResponseData(&RESTResponse)
}


//func (server *AMUdpServer)ValidateMd5(req *amusers.AMUserUDPRequest)bool{
	
//}

func (server *AMUdpServer)HandleUDPRequest(req *amusers.AMUserUDPRequest)*amusers.AMUserUDPResponse{
	var udpres amusers.AMUserUDPResponse
	
	//delete timeout user
	for e := server.UserStoreList.Front(); e != nil; e = e.Next(){
		
		userValue := e.Value.(*amusers.AMUserStorage)
		dur := time.Now().Sub(userValue.LastHeartbeat)
		fmt.Fprintf(os.Stdout, "user time interval is:%f\n", dur.Seconds())
		fmt.Fprint(os.Stdout, userValue.LastHeartbeat, time.Now())
		
		
		if dur.Seconds() > server.UserTimeout{
			fmt.Fprintf(os.Stdout, "will remove use")
			server.UserStoreList.Remove(e)
			server.ChangeNumber++
		}else{
			break	
		}
	}
	
	//deal with delete user request
	if req.UserContentMd5 == "-1"{
		
		for e := server.UserStoreList.Front(); e != nil; e = e.Next(){			
			userValue := e.Value.(*amusers.AMUserStorage)
			if	userValue.UserContent.UserId == req.UserId{
				server.UserStoreList.Remove(e)
				server.ChangeNumber++
				break
			}
		}
		
		return nil
	}
	
	//deal with heartbeat or update
	for e := server.UserStoreList.Front(); e != nil; e = e.Next(){
		userValue := e.Value.(*amusers.AMUserStorage)
		if	userValue.UserContent.UserId == req.UserId{
			
			if  req.UserContentMd5 != "" && userValue.UserContentMd5 != req.UserContentMd5{
				//fmt.Fprintf(os.Stdout, "req.UserContentMd5:\n", req.UserContentMd5)
				//fmt.Fprintf(os.Stdout, "userValue.UserContentMd5:\n", req.UserContentMd5)
				fmt.Fprintf(os.Stdout, "Update request\n")
				userValue.UserContent = req.UserContent
				userValue.UserContentMd5 = req.UserContentMd5
				server.ChangeNumber++
			}
			udpres.UserContentMd5 = userValue.UserContentMd5
			userValue.LastHeartbeat = time.Now()
			fmt.Fprint(os.Stdout, "update heartbeat time!!!!!!!!!!!!!\n", userValue.LastHeartbeat)
			server.UserStoreList.MoveToBack(e)
			
			return &udpres
		}
	}
	
	//didn't find user
	if  req.UserContentMd5 != "" {
		//new user
		fmt.Fprintf(os.Stdout, "will add new user")
		var userStoreNew amusers.AMUserStorage
		userStoreNew.UserContent = req.UserContent
		userStoreNew.UserContentMd5 = req.UserContentMd5
		userStoreNew.LastHeartbeat = time.Now()
		fmt.Fprint(os.Stdout, "update heartbeat time\n", userStoreNew.LastHeartbeat)
		server.UserStoreList.PushBack(&userStoreNew)
		server.ChangeNumber++
		
		udpres.UserContentMd5 = userStoreNew.UserContentMd5
		return &udpres
	}else{
		udpres.UserContentMd5 = "0"//expired user 
		return &udpres
	}	
}

//func (server *AMUdpServer)HandleDeleteUser(userId string){
//	fmt.Fprintf(os.Stdout, "Deleting user %s\n", userId)
//	for e := server.UserStoreList.Front(); e != nil; e = e.Next(){
//		userValue := e.Value.(amusers.AMUserStorage)
//		if userValue.UserContent.UserId  == userId {
//			server.UserStoreList.Remove(e)
//			server.ChangeNumber++
//			break
//		}
//	}
//}

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

