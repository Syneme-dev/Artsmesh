package main

import(
	"fmt"
	"time"
	"sync"
	"container/list"
)

type UserNode struct{
	userData 	*AMRequestUser
	groupId		string
	timestamp   time.Time
}

type GroupNode struct{
	version		int
	groupData   	*AMRequestGroup
	password	 	string
	superGroupId string 
	userData 	map[string]*UserNode	
	subGroups	map[string]*GroupNode
}


type DTOGroup struct{
	GroupData 	*AMRequestGroup
	Users 		[]*AMRequestUser
	SubGroups    []*DTOGroup
}

type DTOSnapShot struct{
	Data			*DTOGroup
	Version		int
}

type GroupList struct{
	global_version 	int
	rootGroup 		*GroupNode
	timeSort			*list.List
	groupIndex		map[string]*GroupNode
	userIndex		map[string]*UserNode
}

var gl GroupList

var snapShotLock sync.RWMutex
var snapShot *DTOSnapShot

func InitGroupList(){
	var rootGroup = new(GroupNode)
	rootGroup.groupData = new(AMRequestGroup)
	rootGroup.groupData.GroupId = ""
	rootGroup.groupData.GroupName = "RootGroup"
	rootGroup.groupData.Description = "RootGroup";
	rootGroup.groupData.LeaderId = "";
	rootGroup.userData = nil;
	rootGroup.subGroups = make(map[string]*GroupNode, 100)

	gl.global_version = 0
	gl.rootGroup = rootGroup
	gl.timeSort = list.New()
	gl.groupIndex = make(map[string]*GroupNode, 100)
	gl.userIndex = make(map[string]*UserNode, 1000)
	
	gl.groupIndex[""] = rootGroup
	
	snapShot = new(DTOSnapShot)
	makeSnapShot()
}

func AddNewGroup(group *AMRequestGroup, superGroupId string)(string){
	
	fmt.Println("AddNewGroup------------BEGIN");
	defer fmt.Println("AddNewGroup------------END");
	
	if group.GroupId == superGroupId {
		return "can not add group to self"
	}
	
	existGroup := getGroupById(group.GroupId)
	if existGroup != nil{
		return "group alread exist"
	}
	
	superGroup := getGroupById(superGroupId)
	if	superGroup == nil{
		fmt.Println("super group is not exist, add to the root group")
		superGroup = gl.rootGroup
	}else{
		fmt.Println("super group is: ", superGroup.groupData.GroupName)
	}
	
	var newGroup  = new(GroupNode)
	newGroup.groupData = new(AMRequestGroup)
	newGroup.groupData.GroupId = group.GroupId
	newGroup.groupData.GroupName = group.GroupName
	newGroup.groupData.Description = group.Description
	newGroup.groupData.LeaderId = group.LeaderId
	newGroup.userData = make(map[string]*UserNode, 100)
	newGroup.subGroups = make(map[string]*GroupNode, 10)
	
	addGroupToSuper(newGroup, superGroup)
	makeGroupIndex(newGroup)
	makeSnapShot()
	
	return "ok"
}

func MoveGroup(groupId string, toGroupId string)(string){
	
	fmt.Println("MoveGroup------------BEGIN");
	defer fmt.Println("MoveGroup------------END");
	
	if groupId == toGroupId{
		return "can not move to self"
	}
	
	group := getGroupById(groupId)
	toGroup := getGroupById(toGroupId)
	
	if group == nil || toGroup == nil{
		return "group not found"
	}
	
	oldSuperGroupId := group.groupData.GroupId
	if oldSuperGroupId == toGroupId{
		//alread in
		return "ok"
	}
	
	oldSuper := removeFromSuperGroup(group)
	addGroupToSuper(group, toGroup)
	tryRemoveEmptyGroup(oldSuper)
	
	makeSnapShot()
	
	return "ok"
}

func DeleteGroup(groupId string)(string){
	
	fmt.Println("DeleteGroup------------BEGIN");
	defer fmt.Println("DeleteGroup------------END");
	
	group := getGroupById(groupId)
	if group == nil{
		return "group not found"
	}
	
	oldSuper := removeFromSuperGroup(group)
	tryRemoveEmptyGroup(oldSuper)	
	removeFromGroupIndex(group)
	makeSnapShot()
	
	return "ok"
}

func UpdataGroup(ug *AMRequestGroup)(string){
	
	fmt.Println("DeleteGroup------------BEGIN");
	defer fmt.Println("DeleteGroup------------END");

	group := getGroupById(ug.GroupId)
	if group == nil{
		return "group not found"
	}
	
	group.groupData.GroupName = ug.GroupName;
	group.groupData.Description = ug.Description;
	group.groupData.LeaderId = ug.LeaderId;
	
	makeSnapShot()
	return "ok"
}

func AddNewUser(user *AMRequestUser, groupId string)(string){
	fmt.Println("AddNewUser------------BEGIN");
	defer fmt.Println("AddNewUser------------END");
	
	existUser := getUserById(user.UserId)
	if existUser != nil{
		return "user already exist"
	}
	
	group := getGroupById(groupId)
	if group == nil{
		return "group not found"	
	}
	
	newUser := new(UserNode)
	newUser.userData = new(AMRequestUser)
	newUser.userData.UserId = user.UserId
	newUser.userData.NickName = user.NickName
	newUser.userData.Domain = user.Domain
	newUser.userData.Location = user.Location
	newUser.userData.Description = user.Description
	newUser.userData.PublicIp = user.PublicIp
	newUser.userData.PrivateIp = user.PrivateIp
	newUser.userData.ChatPort = user.ChatPort
	newUser.userData.PublicChatPort = user.PublicChatPort
	newUser.userData.IsLeader = user.IsLeader
	newUser.userData.IsOnline = user.IsOnline
	
	addUserToGroup(newUser, group)
	makeUserIndex(newUser)
	updateUserTimestamp(newUser)
	makeSnapShot()
	
	return "ok"
}

func UpdataUser(user *AMRequestUser, groupId string)(string){
	
	fmt.Println("UpdataUser------------BEGIN");
	defer fmt.Println("UpdataUser------------END");
	
	existUser := getUserById(user.UserId)
	if existUser == nil{
		return "user not found"
	}
	
	group := getGroupById(groupId)
	if group == nil{
		return "group not found"
	}
	
	existUser.userData.NickName = user.NickName
	existUser.userData.Location = user.Location
	existUser.userData.Domain = user.Domain
	existUser.userData.Description = user.Description
	existUser.userData.PublicChatPort = user.PublicChatPort
	existUser.userData.PublicIp = user.PublicIp
	existUser.userData.PrivateIp = user.PrivateIp
	existUser.userData.ChatPort = user.ChatPort
	existUser.userData.IsLeader = user.IsLeader
	existUser.userData.IsOnline = user.IsOnline
	
	updateUserTimestamp(existUser)
	makeSnapShot()
	
	return "ok"
}

func UserHeartbeat(userId string, groupId string)(string){
	
	fmt.Println("UserHeartbeat------------BEGIN");
	defer fmt.Println("UserHeartbeat------------END");
	
	tryRemoveTimeoutUser()
	
	group := getGroupById(groupId)
	user := getUserById(userId)
	
	if group ==nil || user == nil{
		return "user not found"
	}
	
	updateUserTimestamp(user)
	return "ok"
}

func DeleteUser(userId string, groupId string)(string){
	
	fmt.Println("UserHeartbeat------------BEGIN");
	defer fmt.Println("UserHeartbeat------------END");
	
	existUser := getUserById(userId)
	if existUser == nil{
		return "user not found"
	}
	
	group := getGroupById(groupId)
	if group == nil {
		return "group not found"
	}
	
	removeUserFromGroup(existUser)
	tryRemoveEmptyGroup(group)
	
	removeUserFromIndex(existUser)
	removeFromTimeSort(existUser)
	makeSnapShot()
	
	return "ok"
}

func tryRemoveTimeoutUser(){
	var isUserDel bool
	for e := gl.timeSort.Front(); e != nil;{
		user := e.Value.(*UserNode)
		dur := time.Now().Sub(user.timestamp)
		if	dur.Seconds() < g_user_timeout{
			break
		}
		
		DeleteUser(user.userData.UserId, user.groupId)
		isUserDel = true
		e = gl.timeSort.Front()
	}
	
	if isUserDel{
		makeSnapShot()
	}
}

func updateUserTimestamp(user *UserNode){
	
	user.timestamp = time.Now()
	for e := gl.timeSort.Front();  e != nil; e = e.Next(){
		u := e.Value.(*UserNode)
		
		if u.userData.UserId == user.userData.UserId{
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
	group.userData[user.userData.UserId] = user
	user.groupId = group.groupData.GroupId
}

func makeUserIndex(user *UserNode){
	gl.userIndex[user.userData.UserId] = user
}

func removeFromTimeSort(user *UserNode){
	
	for e := gl.timeSort.Front(); e != nil; e = e.Next(){
		u := e.Value.(*UserNode)
		if u.userData.UserId == user.userData.UserId{
			gl.timeSort.Remove(e)
			break
		}
	}
}

func removeUserFromGroup(user *UserNode)(*GroupNode){
	group := getGroupById(user.groupId)
	delete(group.userData, user.userData.UserId)
	return group
}

func removeUserFromIndex(user *UserNode){

	delete (gl.userIndex, user.userData.UserId)
}

func getGroupById(groupId string)*GroupNode{
	return gl.groupIndex[groupId]
}

func addGroupToSuper(group *GroupNode, super *GroupNode){	
	super.subGroups[group.groupData.GroupId] = group
	group.superGroupId = super.groupData.GroupId
}

func removeFromSuperGroup(group *GroupNode)(*GroupNode){
	super := getGroupById(group.superGroupId)
	delete(super.subGroups, group.groupData.GroupId)
	return super
}

func makeGroupIndex(group *GroupNode){
	gl.groupIndex[group.groupData.GroupId] = group
}

func removeFromGroupIndex(group *GroupNode){
	delete(gl.groupIndex, group.groupData.GroupId)
}

func tryRemoveEmptyGroup(group *GroupNode){
	if group.groupData.GroupId == ""{
		//root group
		return
	}
	
	fmt.Println("group user len is:", len(group.userData))
	fmt.Println("group subgroup len is:", len(group.subGroups))
	
	if len(group.userData) == 0 && len(group.subGroups) == 0{
		superGroup := getGroupById(group.superGroupId)
		delete(superGroup.subGroups, group.groupData.GroupId)
		delete(gl.groupIndex, group.groupData.GroupId)
		tryRemoveEmptyGroup(superGroup)
	}
}

func makeSnapShot(){
	gl.global_version++
	
	newSnapShot := new(DTOSnapShot)
	newSnapShot.Data = copyGroupToDTO(gl.rootGroup)
	newSnapShot.Version = gl.global_version
	
	snapShotLock.Lock()
	snapShot = newSnapShot
	snapShotLock.Unlock()
	
	fmt.Println("Printing snapshot:-------------------")
	fmt.Println("version is:", snapShot.Version)
	printDTOGroup(snapShot.Data)
	fmt.Println("End Printng--------------------------")
}

func printDTOGroup(dtg *DTOGroup){
	fmt.Println("Group Id is:", dtg.GroupData.GroupId)
	fmt.Println("Group naem is:", dtg.GroupData.GroupName)
	for _, v := range dtg.Users{
		fmt.Println("printing users:")
		fmt.Printf("userid=%s, nickName=%s\n", v.UserId, v.NickName)
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
	
	dtoGroup := new(DTOGroup)
	dtoGroup.GroupData = new(AMRequestGroup)
	dtoGroup.GroupData.GroupId = group.groupData.GroupId
	dtoGroup.GroupData.GroupName = group.groupData.GroupName
	dtoGroup.GroupData.Description = group.groupData.Description
	dtoGroup.GroupData.LeaderId = group.groupData.LeaderId
	
	for _, v := range group.userData{
		u := new(AMRequestUser)
		u.UserId = v.userData.UserId
		u.NickName = v.userData.NickName
		u.Location = v.userData.Location
		u.Description = v.userData.Description
		u.Domain = v.userData.Domain
		u.PublicIp = v.userData.PublicIp
		u.PrivateIp = v.userData.PrivateIp
		u.PublicChatPort = v.userData.PublicChatPort
		u.ChatPort = v.userData.ChatPort
		u.IsLeader = v.userData.IsLeader
		u.IsOnline = v.userData.IsOnline

		dtoGroup.Users = append(dtoGroup.Users, u)
	}

	for _, v := range group.subGroups{
		dtog := copyGroupToDTO(v)
		dtoGroup.SubGroups = append(dtoGroup.SubGroups, dtog)
	}

	return dtoGroup
}