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
	"time"
)

var g_rest_port int
var g_heartbeat_port int
var g_user_timeout float64
var g_ipv6 bool

var g_command_pipe chan GroupUserCommand
var g_ticker *time.Ticker

type UserHeartbeatInfo struct{
	UserId 		string
}

type UserHeartbeatResposeDTO struct{
	Version  	string
}

type AMRequestGroup struct{
	GroupId 		string
	GroupName 	string
	Description 	string
	LeaderId 	string
	FullName 	string
	Project		string
	Location		string
	Busy			string
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
	Busy			string
}

type AMRequestChangePassword struct{
	groupId 			string
	oldPassword  	string
	newPassword 		string
}

type CommandAction int
const(
	group_register CommandAction= iota
	group_update
	group_change_password
	user_register 
	user_update
	user_delete
	user_heartbeat
	check_heartbeat
)

type GroupUserCommand struct{
	action  			CommandAction
	group 			*AMRequestGroup
	user 			*AMRequestUser
	passworOper 		*AMRequestChangePassword
	response  		chan string
}

const(
	default_rest_port = 9090
	default_heartbeat_port = 9090
	default_user_timeout = 30.0
	default_ipv6 = false
	usage = "-rest_port 9090 -heartbeat_port 9090 -user_timeout 30 -ipv6"
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
	g_ticker = time.NewTicker(time.Millisecond * 10000)
	
	InitUserList()
	
	go startRestServer()
	go startUdpServer()
	go userTimeout()
	
	executeCommand()
}

func executeCommand(){
	for{
		command := <-g_command_pipe
		switch command.action{
			
		case group_register:
			response := RegisterGroup(command.group)
			command.response<- response
						
		case group_update:
			response := UpdataGroup(command.group)
			command.response<- response
			
		case group_change_password:
			response := ChangeGroupPassword(command.passworOper)
			command.response<- response
		
		case user_register:
			response := RegisterUser(command.user)
			command.response<- response
			
		case user_update:
			response := UpdataUser(command.user)	
			command.response<- response

		case user_delete:
			DeleteUser(command.user.UserId)

		case user_heartbeat:
			UserHeartbeat(command.user.UserId)
			
		case check_heartbeat:
			CheckTimeout()
		}
	}
}

////////////////////////check heartbeat goroutine//////////
func userTimeout(){
	
	for t := range g_ticker.C {
		fmt.Println("check timeour users", t)
		var command GroupUserCommand
		command.action = check_heartbeat

		g_command_pipe<- command
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
	
	var command GroupUserCommand
	command.action = user_heartbeat
	user := new(AMRequestUser)
	user.UserId = heartbeatInfo.UserId
	command.user = user
	
	g_command_pipe<- command

	RLockSnapShot()
	version := snapShot.Version
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

func register_group(w http.ResponseWriter, r *http.Request){	
	r.ParseForm()
	
	reqGroup := new(AMRequestGroup)
	reqGroup.GroupId = strings.Join(r.Form["groupId"], "")
	reqGroup.GroupName = strings.Join(r.Form["groupName"], "")
	reqGroup.Description = strings.Join(r.Form["description"], "")
	reqGroup.LeaderId = strings.Join(r.Form["leaderId"], "")
	reqGroup.FullName = strings.Join(r.Form["fullName"], "")
	reqGroup.Project = strings.Join(r.Form["project"], "")
	reqGroup.Location = strings.Join(r.Form["location"], "")
	reqGroup.Busy = strings.Join(r.Form["busy"], "")
	
	fmt.Println("")
	fmt.Println("register_group requst information ---------------------")
	fmt.Println(r.Form)
	fmt.Println("path", r.URL.Path)	
	fmt.Println("groupId:", reqGroup.GroupId)
	fmt.Println("groupName:", reqGroup.GroupName)
	fmt.Println("description:", reqGroup.Description)
	fmt.Println("leaderId:", reqGroup.LeaderId)
	fmt.Println("fullName:", reqGroup.FullName)
	fmt.Println("project:", reqGroup.Project)
	fmt.Println("location:", reqGroup.Location)
	fmt.Println("busy:", reqGroup.Busy)
	fmt.Println("end http requst information ---------------------")
	
	var command GroupUserCommand
	command.action = group_register
	command.group = reqGroup
	command.response = make(chan string)
	
	g_command_pipe<- command
	
	response := <-command.response
	fmt.Fprintf(w, response)
}

func register_user(w http.ResponseWriter, r *http.Request){	
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
	reqUser.Busy = strings.Join(r.Form["busy"], "") 
	
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
	fmt.Println("busy:", reqUser.Busy)

	fmt.Println("end http requst information ---------------------")
	
	var command GroupUserCommand
	command.action = user_register
	command.user = reqUser
	command.group = reqGroup
	command.response = make(chan string)
	
	g_command_pipe<- command
	response := <-command.response
	fmt.Fprintf(w, response)
}

func update_user(w http.ResponseWriter, r *http.Request){
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
	reqUser.Busy = strings.Join(r.Form["busy"], "") 
		
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
	fmt.Println("busy:", reqUser.Busy)
	fmt.Println("end http requst information ---------------------")
	
	//check value
	
	var command GroupUserCommand
	command.action = user_update
	command.user = reqUser
	command.response = make(chan string)
	
	g_command_pipe<- command
	
	response := <-command.response
	fmt.Fprintf(w, response)
}

func update_group(w http.ResponseWriter, r *http.Request){
	r.ParseForm()
	
	reqGroup := new(AMRequestGroup)
	reqGroup.GroupId = strings.Join(r.Form["groupId"], "")
	reqGroup.GroupName = strings.Join(r.Form["groupName"], "")
	reqGroup.Description = strings.Join(r.Form["description"], "")
	reqGroup.LeaderId = strings.Join(r.Form["leaderId"], "")
	reqGroup.FullName = strings.Join(r.Form["fullName"], "")
	reqGroup.Project = strings.Join(r.Form["project"], "")
	reqGroup.Location = strings.Join(r.Form["location"], "")
	reqGroup.Busy = strings.Join(r.Form["busy"], "")
	
	fmt.Println("")
	fmt.Println("group_update requst information ---------------------")
	fmt.Println(r.Form)
	fmt.Println("path", r.URL.Path)	
	fmt.Println("groupId:", reqGroup.GroupId)
	fmt.Println("groupName:", reqGroup.GroupName)
	fmt.Println("description:", reqGroup.Description)
	fmt.Println("leaderId:", reqGroup.LeaderId)
	fmt.Println("fullName:", reqGroup.FullName)
	fmt.Println("project:", reqGroup.Project)
	fmt.Println("location:", reqGroup.Location)
	fmt.Println("busy:", reqGroup.Busy)
	fmt.Println("end http requst information ---------------------")
	
	var command GroupUserCommand
	command.action = group_update
	command.group = reqGroup
	command.response = make(chan string)
	
	g_command_pipe<- command
	
	response := <-command.response
	fmt.Fprintf(w, response)
}

func delete_user(w http.ResponseWriter, r *http.Request){
	r.ParseForm()
	
	reqUser := new(AMRequestUser)
	reqUser.UserId = strings.Join(r.Form["userId"], "") 
	
	fmt.Println("")
	fmt.Println("user_delete requst information ---------------------")
	fmt.Println(r.Form)
	fmt.Println("path", r.URL.Path)	
	fmt.Println("userId:", reqUser.UserId)
	fmt.Println("end http requst information ---------------------")
	
	//check value
	
	var command GroupUserCommand
	command.action = user_delete
	command.user = reqUser
	
	g_command_pipe<- command
	
	//response := <-command.response
	//fmt.Fprintf(w, response)
}

func change_group_password(w http.ResponseWriter, r *http.Request){
	r.ParseForm()
	
	passwordOper := new(AMRequestChangePassword)
	passwordOper.groupId = strings.Join(r.Form["groupId"], "") 
	passwordOper.oldPassword = strings.Join(r.Form["oldPassword"], "") 
	passwordOper.newPassword = strings.Join(r.Form["newPassword"], "") 
	
	fmt.Println("")
	fmt.Println("change_group_password requst information ---------------------")
	fmt.Println(r.Form)
	fmt.Println("path", r.URL.Path)	
	fmt.Println("groupId:", passwordOper.groupId)
	fmt.Println("end http requst information ---------------------")
	
	//check value
	
	var command GroupUserCommand
	command.action = group_change_password
	command.passworOper = passwordOper
	command.response = make(chan string)
	
	g_command_pipe<- command
		
	response := <-command.response
	fmt.Fprintf(w, response)
}

func getAllUsers(w http.ResponseWriter, r *http.Request){
	RLockSnapShot()
	userData, err := json.Marshal(snapShot)
	if err != nil{
		fmt.Fprintf(os.Stderr, "error: %s", err.Error())
		return
	}
	RUnlockSnapShot()
	
	userDataStr := fmt.Sprintf("%s", userData)
	fmt.Printf("\ngetall users: %s\n", userDataStr)
	fmt.Fprintf(w, userDataStr)
}

func startRestServer(){
	fmt.Fprintln(os.Stdout, "starting rest server...")

	restport := fmt.Sprintf(":%d", g_rest_port)
	http.HandleFunc("/groups/register", register_group)
	http.HandleFunc("/groups/update",  update_group)
	http.HandleFunc("/groups/change_password",  change_group_password)
	http.HandleFunc("/users/register", register_user)
	http.HandleFunc("/users/update",  update_user)
	http.HandleFunc("/users/unregister",  delete_user)
	http.HandleFunc("/users/getall",  getAllUsers)
	
	err := http.ListenAndServe(restport, nil)
	if	err != nil{
		fmt.Println("listen and serve failed!")
		fmt.Println(err.Error())
		os.Exit(1)
	}
}