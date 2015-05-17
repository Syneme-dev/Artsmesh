package main

import(
	"fmt"
	"strings"
	"net/http"
	"encoding/json"
	"os"
)

type AMRequestGroup struct{
	GroupId 		string
	GroupName 	string
	Description 	string
	LeaderId 	string
	FullName 	string
	Project		string
	Location		string
	Longitude	string
	Latitude		string
	Busy			string
	TimezoneName	string
	ProjectDescription string
	HomePage	string
	Broadcasting string
	BroadcastingURL string
}

type AMRequestUser struct{
	UserId 		string
	NickName 	string
	FullName		string
	Domain		string
	Location  	string
	Description 	string
	PrivateIp 	string
	Ipv6Address string
	PublicIp		string
	IsLeader		string
	IsOnline		string
	ChatPort		string
	PublicChatPort string
	Busy			string
	OSCServer	string
}

type AMRequestChangePassword struct{
	groupId 			string
	oldPassword  	string
	newPassword 		string
}

type AMRequestMessage struct{
	content			string
	fromUserId		string
	fromUserName		string
	toUserId			string
	toGroupId		string
}


///////////////////////Http GoRoutine///////////////////////

func addUser(w http.ResponseWriter, r *http.Request){	
	r.ParseForm()
	
	reqUser := new(AMRequestUser)
	reqUser.UserId = strings.Join(r.Form["userId"], "") 
	reqUser.NickName = strings.Join(r.Form["nickName"], "") 
	reqUser.FullName = strings.Join(r.Form["fullName"], "")
	reqUser.Domain = strings.Join(r.Form["domain"], "") 
	reqUser.Location = strings.Join(r.Form["location"], "") 
	reqUser.Description = strings.Join(r.Form["description"], "") 
	reqUser.PrivateIp = strings.Join(r.Form["privateIp"], "") 
	reqUser.Ipv6Address = strings.Join(r.Form["ipv6Address"], "")
	reqUser.PublicIp = strings.Join(r.Form["publicIp"], "") 
	reqUser.IsLeader = strings.Join(r.Form["isLeader"], "") 
	reqUser.IsOnline = strings.Join(r.Form["isOnline"], "") 
	reqUser.ChatPort = strings.Join(r.Form["chatPort"], "") 
	reqUser.PublicChatPort = strings.Join(r.Form["publicChatPort"], "") 
	reqUser.Busy = strings.Join(r.Form["busy"], "") 
	reqUser.OSCServer = strings.Join(r.Form["oscServer"], "")
	
	
	reqGroup := new(AMRequestGroup)
	reqGroup.GroupId = strings.Join(r.Form["groupId"], "") 
	
	fmt.Println("")
	fmt.Println("user_add requst information ---------------------")
	fmt.Println(r.Form)
	fmt.Println("path", r.URL.Path)	
	fmt.Println("userId:", reqUser.UserId)
	fmt.Println("nickName:", reqUser.NickName)
	fmt.Println("fullName:", reqUser.FullName)
	fmt.Println("domain:", reqUser.Domain)
	fmt.Println("location:", reqUser.Location)
	fmt.Println("description:", reqUser.Description)
	fmt.Println("privateIp:", reqUser.PrivateIp)
	fmt.Println("ipv6Address", reqUser.Ipv6Address)
	fmt.Println("publicIp:", reqUser.PublicIp)
	fmt.Println("isLeader:", reqUser.IsLeader)
	fmt.Println("isOnline:", reqUser.IsOnline)
	fmt.Println("chatPort:", reqUser.ChatPort)
	fmt.Println("publicChatPort:", reqUser.PublicChatPort)
	fmt.Println("busy:", reqUser.Busy)
	fmt.Println("oscServer:", reqUser.OSCServer)
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
	r.ParseForm()

	var command GroupUserCommand
	command.action = user_heartbeat
	command.user = new(AMRequestUser)
	command.user.UserId = strings.Join(r.Form["userId"], "") 
	command.group = new(AMRequestGroup)
	command.group.GroupId = strings.Join(r.Form["groupId"], "")
	command.response = make(chan string)

	g_command_pipe<- command
	response := <-command.response
	fmt.Println(response)

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
	reqUser.FullName = strings.Join(r.Form["fullName"], "") 
	reqUser.Domain = strings.Join(r.Form["domain"], "") 
	reqUser.Location = strings.Join(r.Form["location"], "") 
	reqUser.Description = strings.Join(r.Form["description"], "") 
	reqUser.PrivateIp = strings.Join(r.Form["privateIp"], "") 
	reqUser.Ipv6Address = strings.Join(r.Form["ipv6Address"], "")
	reqUser.PublicIp = strings.Join(r.Form["publicIp"], "") 
	reqUser.IsLeader = strings.Join(r.Form["isLeader"], "") 
	reqUser.IsOnline = strings.Join(r.Form["isOnline"], "") 
	reqUser.ChatPort = strings.Join(r.Form["chatPort"], "") 
	reqUser.PublicChatPort = strings.Join(r.Form["publicChatPort"], "") 
	reqUser.Busy = strings.Join(r.Form["busy"], "") 
	reqUser.OSCServer = strings.Join(r.Form["oscServer"], "")
	
	reqGroup := new(AMRequestGroup)
	reqGroup.GroupId = strings.Join(r.Form["groupId"], "") 
		
	fmt.Println("")
	fmt.Println("user_update requst information ---------------------")
	fmt.Println(r.Form)
	fmt.Println("path", r.URL.Path)	
	fmt.Println("userId:", reqUser.UserId)
	fmt.Println("nickName:", reqUser.NickName)
	fmt.Println("fullName:", reqUser.FullName)
	fmt.Println("domain:", reqUser.Domain)
	fmt.Println("location:", reqUser.Location)
	fmt.Println("description:", reqUser.Description)
	fmt.Println("privateIp:", reqUser.PrivateIp)
	fmt.Println("ipv6Address:", reqUser.Ipv6Address)
	fmt.Println("publicIp:", reqUser.PublicIp)
	fmt.Println("isLeader:", reqUser.IsLeader)
	fmt.Println("isOnline:", reqUser.IsOnline)
	fmt.Println("chatPort:", reqUser.ChatPort)
	fmt.Println("publicChatPort:", reqUser.PublicChatPort)
	fmt.Println("busy:", reqUser.Busy)
	fmt.Println("oscServer:", reqUser.OSCServer)
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
	command.response = make(chan string)
	
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
	reqGroup.FullName = strings.Join(r.Form["fullName"], "")
	reqGroup.Project = strings.Join(r.Form["project"], "")
	reqGroup.Location = strings.Join(r.Form["location"], "")
	reqGroup.Longitude = strings.Join(r.Form["longitude"], "")
	reqGroup.Latitude = strings.Join(r.Form["latitude"], "")
	reqGroup.Busy = strings.Join(r.Form["busy"], "")
	reqGroup.TimezoneName = strings.Join(r.Form["timezoneName"], "")
	reqGroup.ProjectDescription = strings.Join(r.Form["projectDescription"], "")
	reqGroup.HomePage = strings.Join(r.Form["homePage"], "")
	reqGroup.Broadcasting = strings.Join(r.Form["broadcasting"], "")
	reqGroup.BroadcastingURL = strings.Join(r.Form["broadcastingURL"], "")
	
	fmt.Println("")
	fmt.Println("register_group requst information ---------------------")
	fmt.Println(r.Form)
	fmt.Println("path", r.URL.Path)	
	fmt.Println("groupId:", reqGroup.GroupId)
	fmt.Println("groupName:", reqGroup.GroupName)
	fmt.Println("description:", reqGroup.Description)
	fmt.Println("leaderId:", reqGroup.LeaderId)
	fmt.Println("fullname:", reqGroup.FullName)
	fmt.Println("project:", reqGroup.Project)
	fmt.Println("location:", reqGroup.Location)
	fmt.Println("longitude:", reqGroup.Longitude)
	fmt.Println("latitude:", reqGroup.Latitude)
	fmt.Println("busy:", reqGroup.Busy)
	fmt.Println("timezoneName:", reqGroup.TimezoneName)
	fmt.Println("ProjectDescription:", reqGroup.ProjectDescription)
	fmt.Println("HomePage:", reqGroup.HomePage)
	fmt.Println("Broadcasting:", reqGroup.Broadcasting)
	fmt.Println("BroadcastingURL:", reqGroup.BroadcastingURL)
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
	reqGroup.FullName = strings.Join(r.Form["fullName"], "")
	reqGroup.Project = strings.Join(r.Form["project"], "")
	reqGroup.Location = strings.Join(r.Form["location"], "")
	reqGroup.Longitude = strings.Join(r.Form["longitude"], "")
	reqGroup.Latitude = strings.Join(r.Form["latitude"], "")
	reqGroup.Busy = strings.Join(r.Form["busy"], "")
	reqGroup.TimezoneName = strings.Join(r.Form["timezoneName"], "")
	reqGroup.ProjectDescription = strings.Join(r.Form["projectDescription"], "")
	reqGroup.HomePage = strings.Join(r.Form["homePage"], "")
	reqGroup.Broadcasting = strings.Join(r.Form["broadcasting"], "")
	reqGroup.BroadcastingURL = strings.Join(r.Form["broadcastingURL"], "")
	
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
	fmt.Println("longitude:", reqGroup.Longitude)
	fmt.Println("latitude:", reqGroup.Latitude)
	fmt.Println("busy:", reqGroup.Busy)
	fmt.Println("timezoneName:", reqGroup.TimezoneName)
	fmt.Println("ProjectDescription:", reqGroup.ProjectDescription)
	fmt.Println("HomePage:", reqGroup.HomePage)
	fmt.Println("Broadcasting:", reqGroup.Broadcasting)
	fmt.Println("BroadcastingURL:", reqGroup.BroadcastingURL)
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

func sendMessage(w http.ResponseWriter, r *http.Request){
	r.ParseForm()

	reqMessage := new(AMRequestMessage)
	reqMessage.content = strings.Join(r.Form["content"], "")
	reqMessage.fromUserId = strings.Join(r.Form["fromUserId"], "")
	reqMessage.fromUserName = strings.Join(r.Form["fromUserName"], "")
	reqMessage.toUserId = strings.Join(r.Form["toUserId"], "")
	reqMessage.toGroupId = strings.Join(r.Form["toGroupName"], "")

	fmt.Println("")
	fmt.Println("send_message requst information ---------------------")
	fmt.Println(r.Form)
	fmt.Println("path", r.URL.Path)	
	fmt.Println("message is:", reqMessage.content)
	fmt.Println("message from:", reqMessage.fromUserName)
	fmt.Println("message to:", reqMessage.toUserId)
	fmt.Println("message to:", reqMessage.toGroupId)
	fmt.Println("end http requst information ---------------------")
	
	//check value
	var command GroupUserCommand
	command.action = message_send
	command.message = reqMessage
	command.response = make(chan string)
	
	g_command_pipe<- command

	response := <-command.response
	fmt.Fprintf(w, response)
}

func getMessage(w http.ResponseWriter, r *http.Request){
	r.ParseForm()

	reqUser := new(AMRequestUser)
	reqUser.UserId = strings.Join(r.Form["userId"], "") 
	reqUser.NickName = strings.Join(r.Form["nickName"], "")
	
	fmt.Println("")
	fmt.Println("send_message requst information ---------------------")
	fmt.Println(r.Form)
	fmt.Println("path", r.URL.Path)	
	fmt.Println("user name is:", reqUser.NickName)
	fmt.Println("end http requst information ---------------------")
	
	var command GroupUserCommand
	command.action = message_get
	command.user = reqUser
	command.response = make(chan string)
	
	response := <-command.response
	fmt.Fprintf(w, response)
}


func startRestServer(){
	fmt.Fprintln(os.Stdout, "starting rest server...")

	restport := fmt.Sprintf(":%d", g_rest_port)
	http.HandleFunc("/users/getall", getAllUsers)
	http.HandleFunc("/users/update", updateUser)
	http.HandleFunc("/users/delete", deleteUser)
	http.HandleFunc("/users/add", addUser)
	http.HandleFunc("/groups/add", addGroup)
	http.HandleFunc("/groups/update", updateGroup)
	http.HandleFunc("/groups/delete", deleteGroup)
	http.HandleFunc("/groups/merge",  mergeGroup)
	http.HandleFunc("/groups/unmerge", unmergeGroup)
	http.HandleFunc("/message/send", sendMessage)
	http.HandleFunc("/message/receive", getMessage)

	err := http.ListenAndServe(restport, nil)
	if	err != nil{
		fmt.Println("listen and serve failed!")
		os.Exit(1)
	}
}
