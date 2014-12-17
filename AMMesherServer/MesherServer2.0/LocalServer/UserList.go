package main

import(
	"fmt"
	"time"
	"sync"
)

type UserStore struct{
	userData 	*AMRequestUser
	timestamp   time.Time
}

type GroupStore struct{
	version		int
	groupData   	*AMRequestGroup
	password	 	string
	userStores 	map[string]*UserStore	
}

type Snapshot struct{
	Version int
	GroupData   	*AMRequestGroup
	UsersData 	[]*AMRequestUser
}

var g_store *GroupStore
var snapShotLock sync.RWMutex
var snapShot *Snapshot

func InitUserList(){
	g_store = new(GroupStore)
	g_store.version = 0
	g_store.password = ""
	g_store.groupData = nil
	g_store.userStores = make(map[string]*UserStore, 100)

	snapShot = new(Snapshot)
	snapShot.Version = g_store.version;
	//makeSnapShot()
}


func RegisterGroup(group *AMRequestGroup)(string){
	fmt.Println("RegisterGroup------------BEGIN");
	defer fmt.Println("RegisterGroup------------END");
	
	if g_store.groupData == nil{
		g_store.groupData = group
		makeSnapShot()
		return "ok"
	}
	
	return "group already exist"
}

func UpdataGroup(group *AMRequestGroup)(string){
	
	fmt.Println("UpdataGroup------------BEGIN");
	defer fmt.Println("UpdataGroup------------END");
	
	if g_store.groupData.GroupId == group.GroupId{
		g_store.groupData.GroupName = group.GroupName
		g_store.groupData.Description = group.Description
		g_store.groupData.LeaderId = group.LeaderId
		g_store.groupData.FullName = group.FullName
		g_store.groupData.Location = group.Location
		g_store.groupData.Longitude = group.Longitude
		g_store.groupData.Latitude = group.Latitude
		g_store.groupData.TimezoneName = group.TimezoneName
		g_store.groupData.Project = group.Project
		g_store.groupData.Busy = group.Busy
		
		makeSnapShot()
		return "ok"
	}
	
	return "group not found"
}

func ChangeGroupPassword(passwordOper *AMRequestChangePassword)(string){
	
	fmt.Println("ChangeGroupPassword------------BEGIN");
	defer fmt.Println("ChangeGroupPassword------------END");
	
	if g_store.groupData.GroupId == passwordOper.groupId{
		if g_store.password == passwordOper.oldPassword{
			g_store.password = passwordOper.newPassword
			return "ok"
		}else{
			return "password is wrong"
		}			
	}
	return "group not found"
}

func RegisterUser(user *AMRequestUser)(string){
	
	fmt.Println("RegisterUser------------BEGIN");
	defer fmt.Println("RegisterUser------------END");
	
	if g_store.groupData == nil {
		return "group not found"
	}
	
	exsitUser := g_store.userStores[user.UserId]
	if	exsitUser != nil {
		return "user already exist!"
	}
	
	uStore := new(UserStore)
	uStore.timestamp = time.Now()
	uStore.userData = user
	g_store.userStores[user.UserId] = uStore
	makeSnapShot()
	
	return "ok"
}

func UpdataUser(user *AMRequestUser)(string){
	
	fmt.Println("UpdataUser------------BEGIN");
	defer fmt.Println("UpdataUser------------END");
	
	existUser := g_store.userStores[user.UserId]
	if existUser == nil{
		return "user not found"
	}
	
	existUser.timestamp = time.Now()
	existUser.userData = user

	makeSnapShot()
	
	return "ok"
}

func UserHeartbeat(userId string) {
	
	fmt.Println("UserHeartbeat------------BEGIN");
	defer fmt.Println("UserHeartbeat------------END");
	
	existUser := g_store.userStores[userId]
	if existUser == nil{
		fmt.Println("user not exist!");
		return
	}
	
	existUser.timestamp = time.Now()
}

func CheckTimeout(){
	fmt.Println("CheckTimeout------------BEGIN");
	defer fmt.Println("CheckTimeout------------END");
	
	hasChanged := false
	var deleteKeys []string
	
	for k, v := range g_store.userStores{
		dur := time.Now().Sub(v.timestamp)
		if dur.Seconds() > g_user_timeout{
			fmt.Printf("user %s duration is %f seconds\n", v.userData.NickName, dur.Seconds())
			fmt.Printf("user timeout is %f seconds, will delete!\n", g_user_timeout)	
			deleteKeys = append(deleteKeys, k)
			hasChanged = true
		}
	}
	
	for _,k := range deleteKeys{
		delete(g_store.userStores, k)
	}
	
	if hasChanged{
		makeSnapShot()
	}
}

func DeleteUser(userId string){
	fmt.Println("DeleteUser------------BEGIN");
	defer fmt.Println("DeleteUser------------END");
	
	existUser := g_store.userStores[userId]
	if existUser == nil{
		fmt.Println("user not exist!");
		return
	}
	
	delete(g_store.userStores, userId)
	makeSnapShot()
}

func makeSnapShot(){
	g_store.version++
	newSnapShot := new(Snapshot)

	newSnapShot.Version = g_store.version
	newSnapShot.GroupData = new(AMRequestGroup)
	newSnapShot.GroupData.GroupId = g_store.groupData.GroupId
	newSnapShot.GroupData.GroupName = g_store.groupData.GroupName
	newSnapShot.GroupData.Description = g_store.groupData.Description
	newSnapShot.GroupData.LeaderId = g_store.groupData.LeaderId
	newSnapShot.GroupData.FullName = g_store.groupData.FullName
	newSnapShot.GroupData.Project = g_store.groupData.Project
	newSnapShot.GroupData.Location = g_store.groupData.Location
	newSnapShot.GroupData.Longitude = g_store.groupData.Longitude
	newSnapShot.GroupData.Latitude = g_store.groupData.Latitude
	newSnapShot.GroupData.TimezoneName = g_store.groupData.TimezoneName
	newSnapShot.GroupData.Busy = g_store.groupData.Busy
	
		
	fmt.Println("-------------g_store.userStores count is:", len(g_store.userStores))
	for _, v := range g_store.userStores{
		
		userData := new(AMRequestUser)
		userData.UserId = v.userData.UserId
		userData.NickName = v.userData.NickName
		userData.FullName = v.userData.FullName
		userData.Domain = v.userData.Domain
		userData.Location = v.userData.Location
		userData.Description = v.userData.Description
		userData.IsOnline = v.userData.IsOnline
		userData.IsLeader = v.userData.IsLeader
		userData.PrivateIp = v.userData.PrivateIp
		userData.PublicIp = v.userData.PublicIp
		userData.ChatPort = v.userData.ChatPort
		userData.PublicChatPort = v.userData.PublicChatPort
		userData.Busy = v.userData.Busy
		userData.OSCServer = v.userData.OSCServer
		
		newSnapShot.UsersData = append(newSnapShot.UsersData , userData)
	}
	
	fmt.Println("-------------newSnapShot.usersData count is:", len(newSnapShot.UsersData))
	
	snapShotLock.Lock()
	snapShot = newSnapShot
	snapShotLock.Unlock()
	
	fmt.Println("Printing snapshot:-------------------")
	printSnapshot(snapShot)
	fmt.Println("End Printng--------------------------")
}

func printSnapshot(snap *Snapshot){
	fmt.Println("Version is:", snap.Version)
	fmt.Println("Group Name is:", snap.GroupData.GroupName)
	for _, v := range snap.UsersData{
		fmt.Printf("nickname=%s", v.NickName)
	}
}

func RLockSnapShot(){
	snapShotLock.RLock()
}

func RUnlockSnapShot(){
	snapShotLock.RUnlock()
}

