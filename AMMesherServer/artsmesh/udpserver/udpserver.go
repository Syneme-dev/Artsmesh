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
)

type AMUdpServer struct{
	UserTimeout float64
	IsIpv4 bool
	UdpPort string
	RestServer *restserver.AMRestServer
	ChangeNumber int
	ChangeTime time.Time
	//UserHeadNode *amusers.AMUserStorage
	UserIdList *list.List
	UserData map[string] *amusers.AMUserStorage
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
	
	server.UserIdList = list.New()
	server.UserData = map[string]*amusers.AMUserStorage{}
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
	var buf [512]byte

	n, addr, err := conn.ReadFromUDP(buf[0:])
	if err != nil {
		return
	}
	
	fmt.Fprintln(os.Stdout, "Handling Client ...")
	fmt.Fprintf(os.Stdout, "%d bytes received from %s \n", n, addr.String())
	
	len := bytes.Index(buf[:], []byte{0})
	jsonStream := string(buf[:len])
	fmt.Fprintf(os.Stdout, "received json content: %s \n", jsonStream)

	req := server.ParseJsonString(jsonStream)
	if	req == nil {
		return
	}
	if	req.UserContent.Id == ""{
		return
	}
	
	if req.Action == "delete"{	
		server.HandleDeleteUser(req.UserContent.Id)
	}else{
		server.HandleUpdateUser(req)
	}
	
	interval := time.Now().Sub(server.ChangeTime)
	if server.ChangeNumber > 0 || interval.Seconds() > 5{
		
		fmt.Fprintf(os.Stdout, "change number: %d, time interval: %f", 
					server.ChangeNumber, interval.Seconds())
		
		//update the rest server
		userArrObj := new(amusers.AMUserResonse)
		userArrObj.Data = make([]amusers.AMUser, server.UserIdList.Len())
		i := 0
		for _, userData := range server.UserData {
			userArrObj.Data[i] = *userData.UserContent.Copy()	
        	i++
		}
	
		userArrObj.Version = server.RestServer.UserArrayObj.Version+1
		server.RestServer.UserArrayObj = userArrObj
		
		server.ChangeNumber = 0 
		server.ChangeTime = time.Now()
	}
}

func (server *AMUdpServer)FindUserId(id string)*list.Element{
	
	for e := server.UserIdList.Front(); e != nil; e = e.Next(){
		if e.Value == id{
			return e
		}
	}
	
	return nil
}

//{"Action":"new","UserContent": {"Id":"123", "Name":"wangwei","Public_ip":"192.168.1.1","Private_ip":"192.168.1.1","Local_leader":"test123","Groupname":"test123","Domain":"test123","Location":"test123","Description":"test123"},"UserContentMd5":"12345"}
func (server *AMUdpServer)HandleUpdateUser(req *amusers.AMUserRequset){
	
	id := req.UserContent.Id
	userStorage := server.UserData[id]
	if userStorage==nil {
		fmt.Fprintf(os.Stdout, "Adding new user %s\n", id)
		userStorage := new(amusers.AMUserStorage)
		userStorage.UserContent = *req.UserContent.Copy()
		userStorage.UserContentMd5 = req.UserContentMd5
		userStorage.LastHeartbeat = time.Now()
		server.UserData[id] = userStorage
		server.UserIdList.PushBack(id)
		server.ChangeNumber++
		
	}else if req.UserContentMd5 == ""{
		fmt.Fprintf(os.Stdout, "update user %s\n", id)
		userStorage.LastHeartbeat = time.Now()
		
		e:=server.FindUserId(id)
		if e == nil{
			fmt.Fprintf(os.Stderr, "Fatal Errror, map and list data conflict!")		
		}
		
		server.UserIdList.MoveToBack(e)
	}else{
		if req.UserContentMd5 == userStorage.UserContentMd5{
			fmt.Fprintf(os.Stdout, "received the resend update package, drop it")
		}else{
			fmt.Fprintf(os.Stdout, "received the update package")
			userStorage.UserContent = *req.UserContent.Copy()
			userStorage.LastHeartbeat = time.Now()
			
			e:=server.FindUserId(id)
			if e == nil{
				fmt.Fprintf(os.Stderr, "Fatal Errror, map and list data conflict!")		
			}
		
			server.UserIdList.MoveToBack(e)
			server.ChangeNumber++
		}
	}
}

func (server *AMUdpServer)HandleDeleteUser(userId string){
	
	userStorage := server.UserData[userId]
	fmt.Fprintf(os.Stdout, "Deleting user %s\n", userId)

	if (userStorage == nil){
		fmt.Fprintf(os.Stdout, "don't have this user %s\n", userId)
		return
	}

	e := server.FindUserId(userId)
	if e == nil{
		fmt.Fprintf(os.Stderr, "Fatal Errror, map and list data conflict!")		
	}
	
	server.UserIdList.Remove(e)
	delete(server.UserData, userId)
}

func (server *AMUdpServer) ParseJsonString(contentStr string) *amusers.AMUserRequset{
	var err error
	var req amusers.AMUserRequset
	dec := json.NewDecoder(strings.NewReader(contentStr))
	for{
		err = dec.Decode(&req); 
		 if err == io.EOF {
			//fmt.Fprintf(os.Stdout, "client request is: %s\n", req.Action)
			if	req.UserContent.Id != ""{
				fmt.Fprintf(os.Stdout, "userinfo is: %s\n", req.UserContent.Id)
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

