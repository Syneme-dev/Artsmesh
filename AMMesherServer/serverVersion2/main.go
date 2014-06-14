package main

import(
	"fmt"
	"net"
	"net/http"
	"os"
	"time"
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
	userId string
	groupId string
	lastHeartbeat time.Time
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
	userId 			string 
	userData 		string
	groupId			string
	groupData		string
	superGroup		string
	mergeToGroup	string
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
		case user_new:
			AddNewUser(command.userId, command.groupId, command.userData)
			break
		case group_new:
			AddNewGroup(command.groupId, command.superGroup, command.groupData)
			break
		case group_update:
			UpdataGroup(command.groupId, command.groupData)
			break
		case user_update:
			UpdataUser(command.userId, command.groupId, command.userData)	
			break
		case group_delete:
			DeleteGroup(command.groupId)
			break
		case user_delete:
			DeleteUser(command.userId, command.groupId)
			break
		case group_move:
			MoveGroup(command.groupId, command.superGroup)
			break
		case user_heartbeat:
			UserHeartbeat(command.userId, command.groupId)
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
		handleClient(conn)
	}
}

func handleClient(conn *net.UDPConn){
	
	var buf [1024]byte
	n, addr, err := conn.ReadFromUDP(buf[0:])
	if err != nil {
		fmt.Fprintf(os.Stderr, "ReadFromUDP failed")
		return
	}
	
	fmt.Fprintln(os.Stdout, "Handling Client ...")
	fmt.Fprintf(os.Stdout, "%d bytes received from %s \n", n, addr.String())
	
	len := bytes.Index(buf[:], []byte{0})
	fmt.Fprintf(os.Stdout, "received json len: %d \n", len)
	jsonStream := string(buf[:len])
	fmt.Fprintf(os.Stdout, "received json content: %s \n", jsonStream)

	heartbeatInfo := parseJsonString(jsonStream)
	if	heartbeatInfo == nil {
		return
	}
	
	var command GroupUserCommand
	command.action = user_heartbeat
	command.userId = heartbeatInfo.userId
	command.groupId = heartbeatInfo.groupId
	
	g_command_pipe<- command
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
	userId := strings.Join(r.Form["userId"], "") 
	groupId := strings.Join(r.Form["groupId"], "")
	userData := strings.Join(r.Form["userData"], "")
	
	fmt.Println("")
	fmt.Println("user_add requst information ---------------------")
	fmt.Println(r.Form)
	fmt.Println("path", r.URL.Path)	
	fmt.Println("userId:", userId)
	fmt.Println("groupId:", groupId)
	fmt.Println("userData:", userData)
	fmt.Println("end http requst information ---------------------")
	
	//check value
	
	var command GroupUserCommand
	command.action = user_new
	command.userId = userId
	command.groupId = groupId
	command.userData = userData
	
	g_command_pipe<- command

	fmt.Fprintf(w, "ok")
}

func getAllUsers(w http.ResponseWriter, r *http.Request){
	snapShotLock.RLock()
	userData, err := json.Marshal(snapShot)
	if err != nil{
		fmt.Fprintf(os.Stderr, "error: %s", err.Error())
		return
	}
	snapShotLock.RUnlock()
	
	userDataStr := fmt.Sprintf("%s", userData)
	fmt.Printf("\n%s\n", userDataStr)
	fmt.Fprintf(w, userDataStr)
}

func updateUser(w http.ResponseWriter, r *http.Request){
	r.ParseForm()
	userId := strings.Join(r.Form["userId"], "") 
	groupId := strings.Join(r.Form["groupId"], "")
	userData := strings.Join(r.Form["userData"], "")
	
	fmt.Println("")
	fmt.Println("user_update requst information ---------------------")
	fmt.Println(r.Form)
	fmt.Println("path", r.URL.Path)	
	fmt.Println("userId:", userId)
	fmt.Println("groupId:", groupId)
	fmt.Println("userData:", userData)
	fmt.Println("end http requst information ---------------------")
	
	//check value
	
	var command GroupUserCommand
	command.action = user_update
	command.userId = userId
	command.groupId = groupId
	command.userData = userData
	
	g_command_pipe<- command

	fmt.Fprintf(w, "ok")
}

func deleteUser(w http.ResponseWriter, r *http.Request){
	r.ParseForm()
	userId := strings.Join(r.Form["userId"], "") 
	groupId := strings.Join(r.Form["groupId"], "")
	
	fmt.Println("")
	fmt.Println("user_delete requst information ---------------------")
	fmt.Println(r.Form)
	fmt.Println("path", r.URL.Path)	
	fmt.Println("userId:", userId)
	fmt.Println("groupId:", groupId)
	fmt.Println("end http requst information ---------------------")
	
	//check value
	
	var command GroupUserCommand
	command.action = user_delete
	command.userId = userId
	command.groupId = groupId
	
	g_command_pipe<- command

	fmt.Fprintf(w, "ok")
}

func addGroup(w http.ResponseWriter, r *http.Request){
	r.ParseForm()
	groupId := strings.Join(r.Form["groupId"], "")
	superGroupId := strings.Join(r.Form["superGroupId"], "")
	groupData := strings.Join(r.Form["groupData"], "")
	
	fmt.Println("")
	fmt.Println("group_add requst information ---------------------")
	fmt.Println(r.Form)
	fmt.Println("path", r.URL.Path)	

	fmt.Println("groupId is:", groupId)
	fmt.Println("groupData is:", groupData)
	fmt.Println("superGroupId is:", superGroupId)
	fmt.Println("end http requst information ---------------------")
	
	//check value
	
	var command GroupUserCommand
	command.action = group_new
	command.groupId = groupId
	command.groupData = groupData
	command.superGroup = superGroupId
	
	g_command_pipe<- command

	fmt.Fprintf(w, "ok")
}

func updateGroup(w http.ResponseWriter, r *http.Request){
	r.ParseForm()
	groupId := strings.Join(r.Form["groupId"], "")
	groupData := strings.Join(r.Form["groupData"], "")
	
	fmt.Println("")
	fmt.Println("group_update requst information ---------------------")
	fmt.Println(r.Form)
	fmt.Println("path", r.URL.Path)	

	fmt.Println("groupId is:", groupId)
	fmt.Println("groupData is:", groupData)
	fmt.Println("end http requst information ---------------------")
	
	//check value
	
	var command GroupUserCommand
	command.action = group_update
	command.groupId = groupId
	command.groupData = groupData
	
	g_command_pipe<- command

	fmt.Fprintf(w, "ok")
}

func deleteGroup(w http.ResponseWriter, r *http.Request){
	r.ParseForm()
	groupId := strings.Join(r.Form["groupId"], "")

	fmt.Println("")
	fmt.Println("group_delete requst information ---------------------")
	fmt.Println(r.Form)
	fmt.Println("path", r.URL.Path)	
	fmt.Println("groupId is:", groupId)
	fmt.Println("end http requst information ---------------------")
	
	//check value
	
	var command GroupUserCommand
	command.action = group_delete
	command.groupId = groupId
	
	g_command_pipe<- command

	fmt.Fprintf(w, "ok")
}

func mergeGroup(w http.ResponseWriter, r *http.Request){
	r.ParseForm()
	groupId := strings.Join(r.Form["groupId"], "")
	superGroupId := strings.Join(r.Form["superGroupId"], "")

	fmt.Println("")
	fmt.Println("group_move requst information ---------------------")
	fmt.Println(r.Form)
	fmt.Println("path", r.URL.Path)	
	fmt.Println("groupId is:", groupId)
	fmt.Println("superGroupId is:", superGroupId)
	fmt.Println("end http requst information ---------------------")
	
	//check value
	
	var command GroupUserCommand
	command.action = group_move
	command.groupId = groupId
	command.superGroup = superGroupId
	
	g_command_pipe<- command

	fmt.Fprintf(w, "ok")
}

func unmergeGroup(w http.ResponseWriter, r *http.Request){
	r.ParseForm()
	groupId := strings.Join(r.Form["groupId"], "")
	superGroupId := ""

	fmt.Println("")
	fmt.Println("group_move requst information ---------------------")
	fmt.Println(r.Form)
	fmt.Println("path", r.URL.Path)	
	fmt.Println("groupId is:", groupId)
	fmt.Println("superGroupId is:", superGroupId)
	fmt.Println("end http requst information ---------------------")
	
	//check value
	
	var command GroupUserCommand
	command.action = group_move
	command.groupId = groupId
	command.superGroup = superGroupId
	
	g_command_pipe<- command

	fmt.Fprintf(w, "ok")
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