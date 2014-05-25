package main

import (
	"os"
	"fmt"
	"flag"
	"artsmesh/restserver"
	"artsmesh/udpserver"
)

var g_rest_port int
var g_heartbeat_port int
var g_user_timeout float64
var g_ipv6 bool

const(
	default_rest_port = 8080
	default_heartbeat_port = 8082
	default_user_timeout = 30.0
	default_ipv6 = false
	usage = "-rest_port 8080 -heartbeat_port8082 -user_timeout 30 -ipv6"
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

func main() {
	checkArgs()

	restport := fmt.Sprintf("localhost:%d", g_rest_port)
	udpport := fmt.Sprintf("localhost:%d", g_heartbeat_port)
	isIpv4 := !g_ipv6
	usertimeout := g_user_timeout
	
	restServer := restserver.AMRestServer{Restport:restport}
	udpServer := udpserver.AMUdpServer{UserTimeout : usertimeout, IsIpv4: isIpv4, UdpPort:udpport }
	udpServer.RestServer = &restServer
	
	go udpServer.StartUdpServer()
	restServer.StartRestServer()
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


