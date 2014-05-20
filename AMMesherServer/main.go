package main

import (
    "fmt"
    "github.com/ant0ine/go-json-rest/rest"
    "net/http"
    "sync"
	"time"
	"net"
	"os"
	"strings"
	"strconv"
)

var users = Users{ Store: map[string]*User{} }
var ch = make(chan int)
var userTimeout time.Duration = time.Second *30


func main() {
	if len(os.Args) < 3{
		fmt.Println(os.Stderr, "Usage: %s restport:port ttlport:port", os.Args[0])
		os.Exit(1)
	}
	
	restport := fmt.Sprintf(":%s", os.Args[1])
	ttlport := fmt.Sprintf(":%s", os.Args[2])
	fmt.Println("the restful port is:" + restport + " and the ttlport is" + ttlport)
	
	ticker := time.NewTicker(time.Second * 5)
	
	go StartTTLServer(ttlport)
	go StartRestServer(restport)
    go CheckUserTTL(*ticker)
	
	x := <- ch
	fmt.Println(x)
}


type User struct {
    Id   string
    Name string
	Domain string
	Location string
	PublicIp string
	PrivateIp string
	Description string
	ChatPort string
	ChatPortMap string
	GroupName string
	LastActiveTime time.Time
}

type Users struct {
    sync.RWMutex
	Version int
    Store map[string]*User
}

func (u *Users)FindAndUpdateUserLAT(userid string){
	 for _, user := range u.Store {
        if	user.Id == userid{
			user.LastActiveTime = time.Now()
		}
    }
}

func (u *Users) GetAllUsers(w rest.ResponseWriter, r *rest.Request) {
	id := r.PathParam("id")
    u.RLock()
	ver := fmt.Sprintf("{version:%d}", u.Version);
    users := make([]User, len(u.Store))
    i := 0
    for _, user := range u.Store {
        users[i] = *user
        i++
    }
	u.FindAndUpdateUserLAT(id)
    u.RUnlock()
	w.WriteJson(&ver)
    w.WriteJson(&users)
}

func (u *Users) PostUser(w rest.ResponseWriter, r *rest.Request) {	
	fmt.Print("PostUser called")
    user := User{}
    err := r.DecodeJsonPayload(&user)
    if err != nil {
		fmt.Println(err.Error())
        rest.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
   
	u.Lock()
    id := fmt.Sprintf("%d", len(u.Store)+1) // stupid
    user.Id = id
	user.LastActiveTime = time.Now()
    u.Store[id] = &user
	u.Version++;
	ver := fmt.Sprintf("{version:%d}", u.Version);
    u.Unlock()
	
	w.WriteJson(&ver)
   // w.WriteJson(&user)
}

func (u *Users) PutUser(w rest.ResponseWriter, r *rest.Request) {
    id := r.PathParam("id")
    u.Lock()
    if u.Store[id] == nil {
        rest.NotFound(w, r)
        return
    }
    user := User{}
    err := r.DecodeJsonPayload(&user)
    if err != nil {
        rest.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
    user.Id = id
	user.LastActiveTime = time.Now()
    u.Store[id] = &user
	u.Version++
	ver := fmt.Sprintf("{version:%d}", u.Version);
    u.Unlock()
	w.WriteJson(&ver)
    //w.WriteJson(&user)
}

func (u *Users) DeleteUser(w rest.ResponseWriter, r *rest.Request) {
    id := r.PathParam("id")
    u.Lock()
    delete(u.Store, id)
	u.Version++	
	ver := fmt.Sprintf("{version:%d}", u.Version);
    u.Unlock()
    w.WriteHeader(http.StatusOK)
	w.WriteJson(&ver)
}

func StartRestServer(port string){
	 handler := rest.ResourceHandler{
        EnableRelaxedContentType: true,
    }
	
    handler.SetRoutes(
        rest.RouteObjectMethod("GET", "/users/:id", &users, "GetAllUsers"),
        rest.RouteObjectMethod("POST", "/users", &users, "PostUser"),
        rest.RouteObjectMethod("PUT", "/users/:id", &users, "PutUser"),
        rest.RouteObjectMethod("DELETE", "/users/:id", &users, "DeleteUser"),
    )
	http.ListenAndServe(port, &handler)
}

func StartTTLServer(port string){
	udpAddr, err := net.ResolveUDPAddr("udp4", port)
	checkError(err)
	conn, err := net.ListenUDP("udp", udpAddr)
	checkError(err)
	for{
		HandleClient(conn)
	}
}

func checkError(err error){
		if err != nil{
		fmt.Fprintf(os.Stderr, "Fatal Error", err.Error())
		os.Exit(1)
	}
}

func HandleClient(conn *net.UDPConn){
	var buf [512]byte
	n, addr, err := conn.ReadFromUDP(buf[0:])
	if err != nil {
		return
	}
	
	ttlstring := string(buf[:n])
	idAndVer := strings.Split(ttlstring, ",")
	
	if len(idAndVer) != 2{
		fmt.Println("error packets")
		return;
	}
	
	idStr := idAndVer[0]
	verStr := idAndVer[1]
	fmt.Println("id is:" + idStr + " version is:" + verStr)
	
	ver,err := strconv.Atoi(verStr)
	if err != nil{
		fmt.Println("convert version failed!" + err.Error())
		return
	}

	var actVer int
	
	users.Lock()
	u := users.Store[idStr]
	if u == nil{
		fmt.Println("no user find!")
		users.Unlock()
		return
	}
	u.LastActiveTime = time.Now()
	actVer = users.Version
	users.Unlock()
	
	if	actVer != ver{
		actVerStr := strconv.Itoa(actVer)
		conn.WriteToUDP([]byte(actVerStr), addr)
	}
}

func CheckUserTTL(ticker time.Ticker){
	for t := range ticker.C {
		delIds := make([]string, len(users.Store))
		curtime := time.Now()
		users.Lock()
	    i := 0
		j := 0
    	for _, user := range users.Store {
			dur := curtime.Sub(user.LastActiveTime)
			if userTimeout < dur{
				fmt.Println("user" + user.Name + "timeout, will be deleted")
				fmt.Println("duration is:", dur)
				fmt.Println("timeout is:", userTimeout)
				fmt.Println("Timer expired, check Users", t.String())
				delIds[j] = user.Id	
				j++	
			} 
        	i++
    	}
		
		i = 0
		for i < j {
			delete(users.Store, delIds[i])
			i++
		}
		users.Unlock()
	}
}