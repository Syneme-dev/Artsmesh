package main

import(
	"fmt"
	"net"
	"net/http"
	"os"
	"flag"
	"bytes"
	"strings"
	"encoding/json"
	"io"
)

var g_rest_port int
var g_heartbeat_port int
var g_user_timeout float64
var g_ipv6 bool
var g_command_pipe chan GroupUserCommand

type UserHeartbeatInfo struct{
	UserId 		string
	GroupId 		string
}

type UserHeartbeatResposeDTO struct{
	Version  	string
}

type AMRequestGroup struct{
	GroupId 		string
	GroupName 	string
	Description 	string
	LeaderId 	string
}

type AMRequestUser struct{
	UserId 		string
	NickName 	string
	Domain		string
	Location  	string
	Description 	string
	PrivateIp 	string
	PublicIp		string
	IsLeader		string
	IsOnline		string
	ChatPort		string
	PublicChatPort string
}


type CommandAction int
const(
	user_new	 CommandAction= iota
	user_update
	user_delete
	user_heartbeat
	group_new
	group_update
	group_delete
	group_move
)

type GroupUserCommand struct{
	action  	CommandAction
	group 			*AMRequestGroup
	superGroup 		*AMRequestGroup
	user 			*AMRequestUser
	passworOper 		*AMRequestChangePassword
	response  		chan string
}

type AMRequestChangePassword struct{
	groupId 			string
	oldPassword  	string
	newPassword 		string
}

const(
	default_rest_port = 8080
	default_heartbeat_port = 8080
	default_user_timeout = 30.0
	default_ipv6 = false
	usage = "-rest_port 8080 -heartbeat_port 8082 -user_timeout 30 -ipv6"
)

var Usage = func() {
    fmt.Fprintf(os.Stderr, "Usage of %s:%s\n", os.Args[0], usage)
	os.Exit(1)
}

func init(){
	flag.Usage = Usage
	flag.IntVar(&g_rest_port, "rest_port", default_rest_port, usage)
	flag.IntVar(&g_heartbeat_port, "heartbeat_port", default_heartbeat_port, usage)
	flag.Float64Var(&g_user_timeout, "user_timeout", default_user_timeout, usage)
	flag.BoolVar(&g_ipv6, "ipv6", default_ipv6, usage)
}

func checkArgs(){

	flag.Parse()

	fmt.Printf("rest_port is:%d\n", g_rest_port)
	fmt.Printf("heartbeat_port is%d\n", g_heartbeat_port)
	fmt.Printf("user_timeout is%f\n", g_user_timeout)
	fmt.Printf("use ipv6: %t\n", g_ipv6)
	
	if g_rest_port <= 1024 || g_rest_port>= 65535{
		fmt.Printf("rest_port is out of range!")
		os.Exit(1)
	}
		
	if g_heartbeat_port <= 1024 || g_heartbeat_port>= 65535{
		fmt.Printf("heartbeat_port is out of range!")
		os.Exit(1)
	}
	
	if g_user_timeout <= 10 || g_user_timeout>= 1000{
		fmt.Printf("user_timeout should be between 10 and 1000")
		os.Exit(1)
	}	
}

func main(){
	
	checkArgs()
	g_command_pipe = make(chan GroupUserCommand, 10)
	InitGroupList()
	
	go startRestServer()
	go startUdpServer()
	
	executeCommand()
}

func executeCommand(){
	for{
		command := <-g_command_pipe
		switch command.action{
			
		case group_new:
			response := AddNewGroup(command.group, command.superGroup.GroupId)
			command.response<- response
			
		case user_new:
			response := AddNewUser(command.user, command.group.GroupId)
			command.response<- response
		
		case group_update:
			response := UpdataGroup(command.group)
			command.response<- response

		case user_update:
			response := UpdataUser(command.user, command.group.GroupId)	
			command.response<- response

		case group_delete:
			DeleteGroup(command.group.GroupId)

		case user_delete:
			DeleteUser(command.user.UserId, command.group.GroupId)

		case group_move:
			response := MoveGroup(command.group.GroupId, command.superGroup.GroupId)
			command.response<- response

		case user_heartbeat:
			response := UserHeartbeat(command.user.UserId, command.group.GroupId)
			command.response<- response
		}
	}
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

///////////////////////Http GoRoutine///////////////////////

func addUser(w http.ResponseWriter, r *http.Request){	
	r.ParseForm()
	
	reqUser := new(AMRequestUser)
	reqUser.UserId = strings.Join(r.Form["userId"], "") 
	reqUser.NickName = strings.Join(r.Form["nickName"], "") 
	reqUser.Domain = strings.Join(r.Form["domain"], "") 
	reqUser.Location = strings.Join(r.Form["location"], "") 
	reqUser.Description = strings.Join(r.Form["description"], "") 
	reqUser.PrivateIp = strings.Join(r.Form["privateIp"], "") 
	reqUser.PublicIp = strings.Join(r.Form["publicIp"], "") 
	reqUser.IsLeader = strings.Join(r.Form["isLeader"], "") 
	reqUser.IsOnline = strings.Join(r.Form["isOnline"], "") 
	reqUser.ChatPort = strings.Join(r.Form["chatPort"], "") 
	reqUser.PublicChatPort = strings.Join(r.Form["publicChatPort"], "") 
	
	reqGroup := new(AMRequestGroup)
	reqGroup.GroupId = strings.Join(r.Form["groupId"], "") 
	
	fmt.Println("")
	fmt.Println("user_add requst information ---------------------")
	fmt.Println(r.Form)
	fmt.Println("path", r.URL.Path)	
	fmt.Println("userId:", reqUser.UserId)
	fmt.Println("nickName:", reqUser.NickName)
	fmt.Println("domain:", reqUser.Domain)
	fmt.Println("location:", reqUser.Location)
	fmt.Println("description:", reqUser.Description)
	fmt.Println("privateIp:", reqUser.PrivateIp)
	fmt.Println("publicIp:", reqUser.PublicIp)
	fmt.Println("isLeader:", reqUser.IsLeader)
	fmt.Println("isOnline:", reqUser.IsOnline)
	fmt.Println("chatPort:", reqUser.ChatPort)
	fmt.Println("publicChatPort:", reqUser.PublicChatPort)
	fmt.Println("groupId:", reqGroup.GroupId)

	fmt.Println("end http requst information ---------------------")
	
	var command GroupUserCommand
	command.action = user_new
	command.user = reqUser
	command.group = reqGroup
	command.response = make(chan string)
	
	g_command_pipe<- command
	response := <-command.response
	fmt.Fprintf(w, response)
}

func getAllUsers(w http.ResponseWriter, r *http.Request){
	ss := RLockSnapShot()
	userData, err := json.Marshal(ss)
	if err != nil{
		fmt.Fprintf(os.Stderr, "error: %s", err.Error())
		return
	}
	RUnlockSnapShot()
	
	userDataStr := fmt.Sprintf("%s", userData)
	fmt.Printf("\n%s\n", userDataStr)
	fmt.Fprintf(w, userDataStr)
}

func updateUser(w http.ResponseWriter, r *http.Request){
	r.ParseForm()
	
	reqUser := new(AMRequestUser)
	reqUser.UserId = strings.Join(r.Form["userId"], "") 
	reqUser.NickName = strings.Join(r.Form["nickName"], "") 
	reqUser.Domain = strings.Join(r.Form["domain"], "") 
	reqUser.Location = strings.Join(r.Form["location"], "") 
	reqUser.Description = strings.Join(r.Form["description"], "") 
	reqUser.PrivateIp = strings.Join(r.Form["privateIp"], "") 
	reqUser.PublicIp = strings.Join(r.Form["publicIp"], "") 
	reqUser.IsLeader = strings.Join(r.Form["isLeader"], "") 
	reqUser.IsOnline = strings.Join(r.Form["isOnline"], "") 
	reqUser.ChatPort = strings.Join(r.Form["chatPort"], "") 
	reqUser.PublicChatPort = strings.Join(r.Form["publicChatPort"], "") 
	
	reqGroup := new(AMRequestGroup)
	reqGroup.GroupId = strings.Join(r.Form["groupId"], "") 
		
	fmt.Println("")
	fmt.Println("user_update requst information ---------------------")
	fmt.Println(r.Form)
	fmt.Println("path", r.URL.Path)	
	fmt.Println("userId:", reqUser.UserId)
	fmt.Println("nickName:", reqUser.NickName)
	fmt.Println("domain:", reqUser.Domain)
	fmt.Println("location:", reqUser.Location)
	fmt.Println("description:", reqUser.Description)
	fmt.Println("privateIp:", reqUser.PrivateIp)
	fmt.Println("publicIp:", reqUser.PublicIp)
	fmt.Println("isLeader:", reqUser.IsLeader)
	fmt.Println("isOnline:", reqUser.IsOnline)
	fmt.Println("chatPort:", reqUser.ChatPort)
	fmt.Println("publicChatPort:", reqUser.PublicChatPort)
	fmt.Println("end http requst information ---------------------")
	
	//check value
	
	var command GroupUserCommand
	command.action = user_update
	command.user = reqUser
	command.group = reqGroup
	command.response = make(chan string)
	
	g_command_pipe<- command
	
	response := <-command.response
	fmt.Fprintf(w, response)
}

func deleteUser(w http.ResponseWriter, r *http.Request){
	r.ParseForm()
	
	reqUser := new(AMRequestUser)
	reqUser.UserId = strings.Join(r.Form["userId"], "") 
	
	reqGroup := new(AMRequestGroup)
	reqGroup.GroupId = strings.Join(r.Form["groupId"], "") 
	
	fmt.Println("")
	fmt.Println("user_delete requst information ---------------------")
	fmt.Println(r.Form)
	fmt.Println("path", r.URL.Path)	
	fmt.Println("userId:", reqUser.UserId)
	fmt.Println("groupId:", reqGroup.GroupId)
	fmt.Println("end http requst information ---------------------")
	
	//check value
	
	var command GroupUserCommand
	command.action = user_delete
	command.user = reqUser
	command.group = reqGroup
	
	g_command_pipe<- command
	
	response := <-command.response
	fmt.Fprintf(w, response)
}

func addGroup(w http.ResponseWriter, r *http.Request){
	r.ParseForm()
		
	reqGroup := new(AMRequestGroup)
	reqGroup.GroupId = strings.Join(r.Form["groupId"], "")
	reqGroup.GroupName = strings.Join(r.Form["groupName"], "")
	reqGroup.Description = strings.Join(r.Form["description"], "")
	reqGroup.LeaderId = strings.Join(r.Form["leaderId"], "")
	
	fmt.Println("")
	fmt.Println("register_group requst information ---------------------")
	fmt.Println(r.Form)
	fmt.Println("path", r.URL.Path)	
	fmt.Println("groupId:", reqGroup.GroupId)
	fmt.Println("groupName:", reqGroup.GroupName)
	fmt.Println("description:", reqGroup.Description)
	fmt.Println("leaderId:", reqGroup.LeaderId)
	fmt.Println("end http requst information ---------------------")
	
	var command GroupUserCommand
	command.action = group_new
	command.group = reqGroup
	command.superGroup = new(AMRequestGroup)
	command.superGroup.GroupId = ""
	command.response = make(chan string)
	
	g_command_pipe<- command
	
	response := <-command.response
	fmt.Fprintf(w, response)
}

func updateGroup(w http.ResponseWriter, r *http.Request){
	r.ParseForm()
	
	reqGroup := new(AMRequestGroup)
	reqGroup.GroupId = strings.Join(r.Form["groupId"], "")
	reqGroup.GroupName = strings.Join(r.Form["groupName"], "")
	reqGroup.Description = strings.Join(r.Form["description"], "")
	reqGroup.LeaderId = strings.Join(r.Form["leaderId"], "")
	
	fmt.Println("")
	fmt.Println("group_update requst information ---------------------")
	fmt.Println(r.Form)
	fmt.Println("path", r.URL.Path)	
	fmt.Println("groupId:", reqGroup.GroupId)
	fmt.Println("groupName:", reqGroup.GroupName)
	fmt.Println("description:", reqGroup.Description)
	fmt.Println("leaderId:", reqGroup.LeaderId)
	fmt.Println("end http requst information ---------------------")
	
	var command GroupUserCommand
	command.action = group_update
	command.group = reqGroup
	command.response = make(chan string)
	
	g_command_pipe<- command
	
	response := <-command.response
	fmt.Fprintf(w, response)
}

func deleteGroup(w http.ResponseWriter, r *http.Request){
	r.ParseForm()
	
	reqGroup := new(AMRequestGroup)
	reqGroup.GroupId = strings.Join(r.Form["groupId"], "")

	fmt.Println("")
	fmt.Println("group_delete requst information ---------------------")
	fmt.Println(r.Form)
	fmt.Println("path", r.URL.Path)	
	fmt.Println("groupId is:", reqGroup.GroupId)
	fmt.Println("end http requst information ---------------------")
	
	//check value
	
	var command GroupUserCommand
	command.action = group_delete
	command.group = reqGroup
	command.response = make(chan string)
	
	g_command_pipe<- command

	response := <-command.response
	fmt.Fprintf(w, response)
}

func mergeGroup(w http.ResponseWriter, r *http.Request){
	r.ParseForm()
	
	reqGroup := new(AMRequestGroup)
	reqSuperGroup := new(AMRequestGroup)
	reqGroup.GroupId = strings.Join(r.Form["groupId"], "")
	reqSuperGroup.GroupId =  strings.Join(r.Form["superGroupId"], "")

	fmt.Println("")
	fmt.Println("group_move requst information ---------------------")
	fmt.Println(r.Form)
	fmt.Println("path", r.URL.Path)	
	fmt.Println("groupId is:", reqGroup.GroupId)
	fmt.Println("superGroupId is:", reqSuperGroup.GroupId)
	fmt.Println("end http requst information ---------------------")
	
	//check value
	
	var command GroupUserCommand
	command.action = group_move
	command.group = reqGroup
	command.superGroup = reqSuperGroup
	command.response = make(chan string)
	
	g_command_pipe<- command

	response := <-command.response
	fmt.Fprintf(w, response)
}

func unmergeGroup(w http.ResponseWriter, r *http.Request){
	r.ParseForm()
	
	reqGroup := new(AMRequestGroup)
	reqSuperGroup := new(AMRequestGroup)
	reqGroup.GroupId = strings.Join(r.Form["groupId"], "")
	reqSuperGroup.GroupId =  ""

	fmt.Println("")
	fmt.Println("group_move requst information ---------------------")
	fmt.Println(r.Form)
	fmt.Println("path", r.URL.Path)	
	fmt.Println("group is:", reqGroup.GroupName)
	fmt.Println("end http requst information ---------------------")
	
	//check value
	
	var command GroupUserCommand
	command.action = group_move
	command.group = reqGroup
	command.superGroup = reqSuperGroup
	command.response = make(chan string)
	
	g_command_pipe<- command

	response := <-command.response
	fmt.Fprintf(w, response)
}

func startRestServer(){
	fmt.Fprintln(os.Stdout, "starting rest server...")

	restport := fmt.Sprintf(":%d", g_rest_port)
	http.HandleFunc("/users/getall",  getAllUsers)
	http.HandleFunc("/users/update",  updateUser)
	http.HandleFunc("/users/delete",  deleteUser)
	http.HandleFunc("/users/add",  addUser)
	http.HandleFunc("/groups/add",  addGroup)
	http.HandleFunc("/groups/update",  updateGroup)
	http.HandleFunc("/groups/delete",  deleteGroup)
	http.HandleFunc("/groups/merge",  mergeGroup)
	http.HandleFunc("/groups/unmerge",  unmergeGroup)

	err := http.ListenAndServe(restport, nil)
	if	err != nil{
		fmt.Println("listen and serve failed!")
		os.Exit(1)
	}
}