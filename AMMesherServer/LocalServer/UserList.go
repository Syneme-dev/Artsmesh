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
	
	if ul.groupName == ""{
		fmt.Printf("!!!new group name:%s", ul.groupName);
		ul.groupName = groupName
	}
	
	if ul.groupId == ""{
		fmt.Printf("!!!new group id %s:\n", ul.groupId);
		ul.groupId = groupId
	}
	
	existUser := ul.users[userId]
	if existUser != nil{
		fmt.Println("user already exist!");
		return false
	}
	
	fmt.Println("will add user to list:", userId);

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
	var deleteKeys []string
	
	for k, v := range ul.users{
		dur := time.Now().Sub(v.timestamp)
		if dur.Seconds() > g_user_timeout{
			fmt.Printf("user %s duration is %f seconds\n", v.userId, dur.Seconds())
			fmt.Printf("user timeout is %f seconds, will delete!\n", g_user_timeout)	
			deleteKeys = append(deleteKeys, k)
			hasChanged = true
		}
	}
	
	fmt.Println("the user count is", len(ul.users))
	fmt.Println("will delete count:", len(deleteKeys))

	for _,k := range deleteKeys{
		fmt.Printf("k is %s\n", k)
		delete(ul.users, k)
	}
	
	fmt.Println("after delete count is", len(ul.users))
	
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
	newSnapShot := new(ULSnapshot)

	newSnapShot.Version = ul.version
	newSnapShot.GroupId = ul.groupId
	newSnapShot.GroupName = ul.groupName
	
	fmt.Println("-------------ul.user count is:", len(ul.users))
	for _, v := range ul.users{
		userDto := new(UserDTO)
		userDto.UserId = v.userId
		userDto.UserData = v.userData
		newSnapShot.UserDTOs = append(newSnapShot.UserDTOs, userDto)
	}
	
	fmt.Println("-------------newSnapShot.UserDTOs count is:", len(newSnapShot.UserDTOs))
	
	snapShotLock.Lock()
	snapShot = newSnapShot
	snapShotLock.Unlock()
	
	fmt.Println("Printing snapshot:-------------------")
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

