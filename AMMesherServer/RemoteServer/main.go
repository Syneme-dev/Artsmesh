package main

import(
	"fmt"
	"os"
	"flag"
)

var g_rest_port int
var g_heartbeat_port int
var g_user_timeout float64
var g_ipv6 bool
var g_command_pipe chan GroupUserCommand

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
	message_send
	message_get
)

type GroupUserCommand struct{
	action  	CommandAction
	group 			*AMRequestGroup
	superGroup 		*AMRequestGroup
	user 			*AMRequestUser
	passworOper 		*AMRequestChangePassword
	message			*AMRequestMessage
	
	response  		chan string
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
			response := DeleteGroup(command.group.GroupId)
			command.response<- response

		case user_delete:
			response := DeleteUser(command.user.UserId, command.group.GroupId)
			command.response<- response
			
		case group_move:
			response := MoveGroup(command.group.GroupId, command.superGroup.GroupId)
			command.response<- response

		case user_heartbeat:
			response := UserHeartbeat(command.user.UserId, command.group.GroupId)
			command.response<- response
			
		case message_send:
			response := SendMsgToUser(command.user.UserId, command.message)
			command.response<- response
			
		case message_get:
			response := GetMsgByUserId(command.user.UserId)
			command.response<- response
		}
	}
}


