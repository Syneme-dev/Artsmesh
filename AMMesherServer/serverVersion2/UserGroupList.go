package main

import(
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

type GroupList struct{
	global_version 	int
	rootGroup 		*GroupNode
	timeSort		*list.List
	groupIndex		map[string]*GroupNode
	userIndex		map[string]*UserNode
}

var gl GroupList

var snapShotLock sync.RWMutex
var snapShot *GroupNode

func InitGroupList(){
	var rootGroup = new(GroupNode)
	rootGroup.groupId = ""
	rootGroup.superGroupId = ""
	rootGroup.groupData = ""
	rootGroup.users = nil
	rootGroup.subgroups = make(map[string]*GroupNode, 100)

	gl.global_version = 0
	gl.rootGroup = rootGroup
	gl.timeSort = list.New()
	gl.groupIndex = make(map[string]*GroupNode, 100)
	gl.userIndex = make(map[string]*UserNode, 1000)
	
	gl.groupIndex[""] = rootGroup
	
	makeSnapShot()
}

func AddNewGroup(groupId string, superGroupId string, groupData string)(bool){
	
	if groupId == superGroupId {
		return false
	}
	
	existGroup := getGroupById(groupId)
	if existGroup != nil{
		//already exist
		return false 
	}
	
	superGroup := getGroupById(superGroupId)
	if	superGroup == nil{
		//super group is not exist, add to the root group
		superGroup = gl.rootGroup
	}
	
	var newGroup  = new(GroupNode)
	newGroup.groupId = groupId
	newGroup.groupData = groupData
	newGroup.users = make(map[string]*UserNode, 100)
	newGroup.subgroups = make(map[string]*GroupNode, 10)
	
	addGroupToSuper(newGroup, superGroup)
	makeGroupIndex(newGroup)
	makeSnapShot()

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
	UpdateUserTimestamp(newUser)
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
	UpdateUserTimestamp(existUser)
	makeSnapShot()
	
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
		if	dur < 30.0{
			break
		}
		
		DeleteUser(user.userId, user.groupId)
		e = gl.timeSort.Front()
	}
	
	makeSnapShot()
}

func UpdateUserTimestamp(user *UserNode){
	
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
	
	if len(group.users) == 0 && len(group.subgroups) == 0{
		superGroup := getGroupById(group.superGroupId)
		delete(superGroup.subgroups, group.groupId)
		delete(gl.groupIndex, group.groupId)
		tryRemoveEmptyGroup(superGroup)
	}
}

func makeSnapShot(){
	snapShotLock.Lock()
	snapShot = copyGroup(gl.rootGroup)
	snapShotLock.Unlock()
}

func RLockSnapShot()(*GroupNode){
	snapShotLock.RLock()
	return snapShot
}

func RUnlockSnapShot(){
	snapShotLock.RUnlock()
}

func copyGroup(group *GroupNode)(*GroupNode){
	
	var cg = new(GroupNode)
	cg.groupId = group.groupId
	cg.groupData = group.groupData
	cg.superGroupId = group.superGroupId
	cg.users = make(map[string]*UserNode, 100)
	cg.subgroups = make(map[string]*GroupNode, 10)
	
	for k, v := range group.users{
		u := new(UserNode)
		u.userId = v.userId
		u.groupId = v.groupId
		u.userData = v.userData
		u.timestamp = v.timestamp
		cg.users[k] = u
	}

	for k, v := range group.subgroups{
		g := copyGroup(v)
		cg.subgroups[k] = g
	}

	return cg
}