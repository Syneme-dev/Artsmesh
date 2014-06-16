package main

import(
	"fmt"
	"time"
	"sync"
)

type UserList struct{
	version	 	int
	groupId 		string
	groupName 	string
	users		map[string]*UserNode
}

type UserNode struct{
	userId 		string
	userData 	string
	timestamp   time.Time
}

type ULSnapshot struct{
	Version		int
	GroupId		string
	GroupName	string
	UserDTOs		[]*UserDTO
}

type UserDTO struct{
	UserId 		string
	UserData 	string
}


var ul *UserList
var snapShotLock sync.RWMutex
var snapShot *ULSnapshot

func InitUserList(){
	ul = new(UserList)
	ul.version = 0
	ul.groupId = ""
	ul.groupName = ""
	ul.users = make(map[string]*UserNode, 100)

	snapShot = new(ULSnapshot)
	makeSnapShot()
}

func UpdataGroup(groupName string)(bool){
	
	ul.groupName = groupName
	makeSnapShot()
	return true
}

func AddNewUser(userId string, userData string, groupId string, groupName string)(bool){
	
	if ul.groupId == ""{
		ul.groupId = groupId
		ul.groupName = groupName
	}
	
	existUser := ul.users[userId]
	if existUser != nil{
		return false
	}
	
	newUser := new(UserNode)
	newUser.userId = userId
	newUser.userData = userData
	newUser.timestamp = time.Now()
	ul.users[newUser.userId] = newUser

	makeSnapShot()
	
	return true
}

func UpdataUser(userId string, userData string)(bool){
	
	existUser := ul.users[userId]
	if existUser == nil{
		return false
	}
	
	existUser.userData = userData
	existUser.timestamp = time.Now()

	makeSnapShot()
	return true
}

func UserHeartbeat(userId string )(bool){
	
	existUser := ul.users[userId]
	if existUser == nil{
		return false
	}
	
	existUser.timestamp = time.Now()
	return true
}

func CheckTimeout(){
	hasChanged := false
	
	for k, v := range ul.users{
		dur := time.Now().Sub(v.timestamp)
		if dur.Seconds() > g_user_timeout{
			delete(ul.users, k)
		}
	}
	
	if hasChanged{
		makeSnapShot()
	}
}

func DeleteUser(userId string  )(bool){
	
	existUser := ul.users[userId]
	if existUser == nil{
		return false
	}
	
	delete(ul.users, userId)
	makeSnapShot()
	
	return true
}

func makeSnapShot(){
	ul.version++
	
	snapShotLock.Lock()
	
	snapShot.Version = ul.version
	snapShot.GroupId = ul.groupId
	snapShot.GroupName = ul.groupName
	
	for _, v := range ul.users{
		userDto := new(UserDTO)
		userDto.UserId = v.userId
		userDto.UserData = v.userData
	}
	
	snapShot.Version = ul.version
	
	snapShotLock.Unlock()
	
	fmt.Println("Printing snapshot:-------------------")
	fmt.Println("version is:", snapShot.Version)
	printSnapshot(snapShot)
	fmt.Println("End Printng--------------------------")
}

func printSnapshot(snap *ULSnapshot){
	fmt.Println("Version is:", snap.Version)
	fmt.Println("Group Id is:", snap.GroupId)
	fmt.Println("Group name is:", snap.GroupName)

	fmt.Println("printing users:")
	for _, v := range snap.UserDTOs{
		fmt.Printf("userid=%s, userdata=%s\n", v.UserId, v.UserData)
	}
	fmt.Println("end printing users:")
}

func RLockSnapShot(){
	snapShotLock.RLock()
}

func RUnlockSnapShot(){
	snapShotLock.RUnlock()
}

