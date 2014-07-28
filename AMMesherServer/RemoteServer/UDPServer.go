package main

import (
	"fmt"
	"net"
	"os"
	"bytes"
	"strings"
	"encoding/json"
	"io"
)

type UserHeartbeatInfo struct{
	UserId 		string
	GroupId 	string
}

type UserHeartbeatResposeDTO struct{
	Version  	string
	HasMessage	string
}

///////////////////////Udp GoRoutine///////////////////////
func startUdpServer(){
	fmt.Fprintln(os.Stdout, "starting heartbeating server ...")
	var udpAddr *net.UDPAddr
	var err error
	
	udpport := fmt.Sprintf(":%d", g_heartbeat_port)
	if g_ipv6 {
		udpAddr, err = net.ResolveUDPAddr("udp6", udpport)
		
	}else{
		udpAddr, err = net.ResolveUDPAddr("udp4", udpport)
	}
	
	if	err  != nil{
		fmt.Println("Fatal Error", err.Error())
		os.Exit(1)
	}
	
	fmt.Fprintln(os.Stdout, "heartbeating server address is:" + udpAddr.String())
	
	conn, err := net.ListenUDP("udp", udpAddr)
	if	err  != nil{
		fmt.Println("Fatal Error", err.Error())
		os.Exit(1)
	}
	
	for{
		handleClient(conn)
	}
}

func handleClient(conn *net.UDPConn){
	
	var buf [1024]byte
	n, addr, err := conn.ReadFromUDP(buf[0:])
	if err != nil {
		fmt.Println("ReadFromUDP failed")
		return
	}
	
	fmt.Println("Handling Client ...")
	fmt.Printf("%d bytes received from %s \n", n, addr.String())
	
	len := bytes.Index(buf[:], []byte{0})
	fmt.Printf("received json len: %d \n", len)
	jsonStream := string(buf[:len])
	fmt.Printf("received json content: %s \n", jsonStream)

	heartbeatInfo := parseJsonString(jsonStream)
	if	heartbeatInfo == nil {
		fmt.Printf("json format is not correct\n")
		return
	}
	
	fmt.Printf("heartbeat userid is %s\n", heartbeatInfo.UserId)
	fmt.Printf("heartbeat groupid is %s\n", heartbeatInfo.GroupId)
	
	var command GroupUserCommand
	command.action = user_heartbeat
	command.user = new(AMRequestUser)
	command.user.UserId = heartbeatInfo.UserId
	command.group = new(AMRequestGroup)
	command.group.GroupId = heartbeatInfo.GroupId
	command.response = make(chan string)

	g_command_pipe<- command
	response := <-command.response
	fmt.Println(response)

	ss := RLockSnapShot()
	version := ss.Version
	RUnlockSnapShot()
	
	udpResponse := new(UserHeartbeatResposeDTO)
	exsistUser := getUserById(heartbeatInfo.UserId)
	if exsistUser != nil{
		if exsistUser.messages != nil{
			udpResponse.HasMessage = "YES"
		}else{
			udpResponse.HasMessage = "NO"
		}
	}
	
	udpResponse.Version = fmt.Sprintf("%d", version)
	
	udpResStr, err := json.Marshal(udpResponse)
	if err != nil{
		fmt.Fprintf(os.Stderr, "error: %s", err.Error())
		return
	}
	
	bytes := []byte(udpResStr)
	_, err = conn.WriteToUDP(bytes, addr)
	if	err != nil{
		fmt.Fprintf(os.Stdout, "Write to Udp failed!")
	}
}

func parseJsonString(contentStr string) *UserHeartbeatInfo{
	var err error
	var info UserHeartbeatInfo
	dec := json.NewDecoder(strings.NewReader(contentStr))
	for{
		err = dec.Decode(&info); 
		 if err == io.EOF {
			break;
		}else if err != nil{
			fmt.Println("parse json string failed")
			fmt.Println(os.Stderr, err.Error())
			return nil;
		}
	}
	
	return &info
}

