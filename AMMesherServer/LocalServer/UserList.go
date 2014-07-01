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
	
	if g_store.groupData == nil{
		g_store.groupData = group
		makeSnapShot()
		return "ok"
	}
	fmt.Println("RegisterGroup------------END");
	return "group already exist"
}

func UpdataGroup(group *AMRequestGroup)(string){
	
	fmt.Println("UpdataGroup------------BEGIN");
	
	if g_store.groupData.GroupId == group.GroupId{
		g_store.groupData.GroupName = group.GroupName
		g_store.groupData.Description = group.Description
		g_store.groupData.LeaderId = group.LeaderId
		makeSnapShot()
		return "ok"
	}
	fmt.Println("UpdataGroup------------END");
	return "group not found"
}

func ChangeGroupPassword(passwordOper *AMRequestChangePassword)(string){
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
	
	fmt.Println("RegisterUser------------END");
	return "ok"
}

func UpdataUser(user *AMRequestUser)(string){
	
	fmt.Println("UpdataUser------------BEGIN");
	
	existUser := g_store.userStores[user.UserId]
	if existUser == nil{
		return "user not found"
	}
	
	existUser.timestamp = time.Now()
	existUser.userData = user

	makeSnapShot()
	
	fmt.Println("UpdataUser------------END");
	return "ok"
}

func UserHeartbeat(userId string) {
	
	fmt.Println("UserHeartbeat------------BEGIN");
	
	existUser := g_store.userStores[userId]
	if existUser == nil{
		fmt.Println("user not exist!");
		return
	}
	
	existUser.timestamp = time.Now()
	fmt.Println("UserHeartbeat------------END");
}

func CheckTimeout(){
	fmt.Println("CheckTimeout------------BEGIN");
	
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
	
	fmt.Println("CheckTimeout------------END");
}

func DeleteUser(userId string){
	fmt.Println("DeleteUser------------BEGIN");
	
	existUser := g_store.userStores[userId]
	if existUser == nil{
		fmt.Println("user not exist!");
		return
	}
	
	delete(g_store.userStores, userId)
	makeSnapShot()
	
	fmt.Println("DeleteUser------------END");
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
		
	fmt.Println("-------------g_store.userStores count is:", len(g_store.userStores))
	for _, v := range g_store.userStores{
		
		userData := new(AMRequestUser)
		userData.UserId = v.userData.UserId
		userData.NickName = v.userData.NickName
		userData.Domain = v.userData.Domain
		userData.Location = v.userData.Location
		userData.Description = v.userData.Description
		userData.IsOnline = v.userData.IsOnline
		userData.IsLeader = v.userData.IsLeader
		userData.PrivateIp = v.userData.PrivateIp
		userData.PublicIp = v.userData.PublicIp
		userData.ChatPort = v.userData.ChatPort
		userData.PublicChatPort = v.userData.PublicChatPort
		
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

