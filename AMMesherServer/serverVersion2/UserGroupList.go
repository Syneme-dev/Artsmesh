package main

import(
	"fmt"
	"time"
	"sync"
	"container/list"
)

type UserNode struct{
	userId 		string
	groupId 	string
	userData 	string
	timestamp   time.Time
}

type GroupNode struct{
	groupId 		string
	superGroupId 	string
	groupData   	string
	users    		map[string]*UserNode
	subgroups		map[string]*GroupNode	
}

type DTOUser struct{
	UserId 		string
	UserData 	string
}

type DTOGroup struct{
	GroupId 	string
	GroupData 	string
	Users 		[]*DTOUser
	SubGroups   []*DTOGroup
}

type DTOSnapShot struct{
	Data		*DTOGroup
	Version		int
}

type GroupList struct{
	global_version 	int
	rootGroup 		*GroupNode
	timeSort		*list.List
	groupIndex		map[string]*GroupNode
	userIndex		map[string]*UserNode
}

var gl GroupList

var snapShotLock sync.RWMutex
var snapShot *DTOSnapShot

func InitGroupList(){
	var rootGroup = new(GroupNode)
	rootGroup.groupId = ""
	rootGroup.superGroupId = ""
	rootGroup.groupData = "RootGoup"
	rootGroup.users = nil
	rootGroup.subgroups = make(map[string]*GroupNode, 100)

	gl.global_version = 0
	gl.rootGroup = rootGroup
	gl.timeSort = list.New()
	gl.groupIndex = make(map[string]*GroupNode, 100)
	gl.userIndex = make(map[string]*UserNode, 1000)
	
	gl.groupIndex[""] = rootGroup
	
	snapShot = new(DTOSnapShot)
	makeSnapShot()
}

func AddNewGroup(groupId string, superGroupId string, groupData string)(bool){
	
	fmt.Println("AddNewGroup Method Called...")
	
	if groupId == superGroupId {
		fmt.Println("groupId can not be equal to superGroupId")
		return false
	}
	
	existGroup := getGroupById(groupId)
	if existGroup != nil{
		fmt.Println("group alread exist!")
		return false 
	}
	
	superGroup := getGroupById(superGroupId)
	if	superGroup == nil{
		fmt.Println("super group is not exist, add to the root group")
		superGroup = gl.rootGroup
	}else{
		fmt.Println("super group is: ", superGroup.groupData)
	}
	
	var newGroup  = new(GroupNode)
	newGroup.groupId = groupId
	newGroup.groupData = groupData
	newGroup.users = make(map[string]*UserNode, 100)
	newGroup.subgroups = make(map[string]*GroupNode, 10)
	
	addGroupToSuper(newGroup, superGroup)
	makeGroupIndex(newGroup)
	makeSnapShot()
	
	fmt.Println("AddNewGroup Method Finished!")

	return true
}

func MoveGroup(groupId string, toGroupId string)(bool){
	
	if groupId == toGroupId{
		return false
	}
	
	group := getGroupById(groupId)
	toGroup := getGroupById(toGroupId)
	
	if group == nil || toGroup == nil{
		return false
	}
	
	oldSuperGroupId := group.superGroupId
	if oldSuperGroupId == toGroupId{
		//alread in
		return false
	}
	
	oldSuper := removeFromSuperGroup(group)
	addGroupToSuper(group, toGroup)
	tryRemoveEmptyGroup(oldSuper)
	
	makeSnapShot()
	
	return true
}

func DeleteGroup(groupId string){
	group := getGroupById(groupId)
	if group == nil{
		return
	}
	
	oldSuper := removeFromSuperGroup(group)
	tryRemoveEmptyGroup(oldSuper)	
	removeFromGroupIndex(group)
	makeSnapShot()
}

func UpdataGroup(groupId string, groupData string)(bool){

	group := getGroupById(groupId)
	if group == nil{
		return false
	}
	
	group.groupData = groupData
	makeSnapShot()
	return true
}

func AddNewUser(userId string, groupId, userData string)(bool){
	
	existUser := getUserById(userId)
	if existUser != nil{
		return false
	}
	
	group := getGroupById(groupId)
	if group == nil{
		return false	
	}
	
	newUser := new(UserNode)
	newUser.userId = userId
	newUser.userData = userData
	
	addUserToGroup(newUser, group)
	makeUserIndex(newUser)
	updateUserTimestamp(newUser)
	makeSnapShot()
	
	return true
}

func UpdataUser(userId string, groupId, userData string)(bool){
	existUser := getUserById(userId)
	if existUser == nil{
		return false
	}
	
	group := getGroupById(groupId)
	if group == nil{
		return false
	}
	
	existUser.userData = userData
	updateUserTimestamp(existUser)
	makeSnapShot()
	
	return true
}

func UserHeartbeat(userId string, groupId string)(bool){
	
	group := getGroupById(groupId)
	user := getUserById(userId)
	
	if group ==nil || user == nil{
		return false
	}
	
	updateUserTimestamp(user)
	return true
}

func DeleteUser(userId string, groupId string)(bool){
	
	existUser := getUserById(userId)
	if existUser == nil{
		return false
	}
	
	group := getGroupById(groupId)
	if group == nil {
		return false
	}
	
	superGroup := removeUserFromGroup(existUser)
	tryRemoveEmptyGroup(superGroup)
	
	removeUserFromIndex(existUser)
	removeFromTimeSort(existUser)
	makeSnapShot()
	
	return true
}

func RemoveTimeoutUser(){
	for e := gl.timeSort.Front(); e != nil;{
		user := e.Value.(UserNode)
		dur := time.Now().Sub(user.timestamp)
		if	dur.Seconds() < g_user_timeout{
			break
		}
		
		DeleteUser(user.userId, user.groupId)
		e = gl.timeSort.Front()
	}
	
	makeSnapShot()
}

func updateUserTimestamp(user *UserNode){
	
	user.timestamp = time.Now()
	for e := gl.timeSort.Front();  e != nil; e = e.Next(){
		u := e.Value.(*UserNode)
		
		if u.userId == user.userId{
			gl.timeSort.Remove(e)
			break
		}
	}	
	user.timestamp = time.Now()	
	gl.timeSort.PushBack(user)		
}

func getUserById(userId string)(*UserNode){
	return gl.userIndex[userId]
}

func addUserToGroup(user *UserNode, group *GroupNode){
	group.users[user.userId] = user
	user.groupId = group.groupId
}

func makeUserIndex(user *UserNode){
	gl.userIndex[user.userId] = user
}

func removeFromTimeSort(user *UserNode){
	
	for e := gl.timeSort.Front(); e != nil; e = e.Next(){
		u := e.Value.(*UserNode)
		if u.userId == user.userId{
			gl.timeSort.Remove(e)
			break
		}
	}
}

func removeUserFromGroup(user *UserNode)(*GroupNode){
	group := getGroupById(user.groupId)
	delete(group.users, user.userId)
	return group
}

func removeUserFromIndex(user *UserNode){

	delete (gl.userIndex, user.userId)
}

func getGroupById(groupId string)*GroupNode{
	return gl.groupIndex[groupId]
}

func addGroupToSuper(group *GroupNode, super *GroupNode){	
	super.subgroups[group.groupId] = group
	group.superGroupId = super.groupId
}

func removeFromSuperGroup(group *GroupNode)(*GroupNode){
	super := getGroupById(group.superGroupId)
	delete(super.subgroups, group.groupId)
	return super
}

func makeGroupIndex(group *GroupNode){
	gl.groupIndex[group.groupId] = group
}

func removeFromGroupIndex(group *GroupNode){
	delete(gl.groupIndex, group.groupId)
}

func tryRemoveEmptyGroup(group *GroupNode){
	if group.groupId == ""{
		//root group
		return
	}
	
	if len(group.users) == 0 && len(group.subgroups) == 0{
		superGroup := getGroupById(group.superGroupId)
		delete(superGroup.subgroups, group.groupId)
		delete(gl.groupIndex, group.groupId)
		tryRemoveEmptyGroup(superGroup)
	}
}

func makeSnapShot(){
	snapShotLock.Lock()
	snapShot.Data = copyGroupToDTO(gl.rootGroup)
	snapShot.Version = gl.global_version
	snapShotLock.Unlock()
	
	fmt.Println("Printing snapshot:-------------------")
	fmt.Println("version is:", snapShot.Version)
	printDTOGroup(snapShot.Data)
	fmt.Println("End Printng--------------------------")
}

func printDTOGroup(dtg *DTOGroup){
	fmt.Println("Group Id is:", dtg.GroupId)
	fmt.Println("Group data is:", dtg.GroupData)
	for _, v := range dtg.Users{
		fmt.Println("printing users:")
		fmt.Printf("userid=%s, userdata=%s\n", v.UserId, v.UserData)
		fmt.Println("end printing users:")
	}
	
	for _, v := range dtg.SubGroups{
		fmt.Println("printing subgroups:")
	 	printDTOGroup(v)
		fmt.Println("end printing subgroups:")
	}
}

func RLockSnapShot()(*DTOSnapShot){
	snapShotLock.RLock()
	return snapShot
}

func RUnlockSnapShot(){
	snapShotLock.RUnlock()
}

func copyGroupToDTO(group *GroupNode)(*DTOGroup){
	
	var dtoGroup = new (DTOGroup)
	dtoGroup.GroupId = group.groupId
	dtoGroup.GroupData = group.groupData
	
	for _, v := range group.users{
		u := new(DTOUser)
		u.UserId = v.userId
		u.UserData = v.userData
		dtoGroup.Users = append(dtoGroup.Users, u)
	}

	for _, v := range group.subgroups{
		dtog := copyGroupToDTO(v)
		dtoGroup.SubGroups = append(dtoGroup.SubGroups, dtog)
	}

	return dtoGroup
}