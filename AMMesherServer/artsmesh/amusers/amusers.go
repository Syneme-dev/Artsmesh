package amusers

import (
	"time"
)

type AMPortMap struct{
	PortName 		string
	InternalPort 	string
	NATMapPort 		string
}

type AMUser struct{
	UserId			string
	NickName		string
	Domain 			string
	Location 		string
	GroupName 		string 
	PublicIp 		string
	PrivateIp 		string
	LocalLeader 	string
	Description 	string
	PortMaps 		[]AMPortMap
}

func(user *AMUser)Copy()(AMUser){
	var u AMUser
	u.UserId = user.UserId
	u.NickName = user.NickName
	u.Domain = user.Domain
	u.Location = user.Location
	u.GroupName = user.GroupName
	u.PublicIp = user.PublicIp
	u.PrivateIp = user.PrivateIp
	u.LocalLeader = user.LocalLeader
	u.Description = user.Description
	
	u.PortMaps = make([]AMPortMap, len(user.PortMaps))
	copy(u.PortMaps, user.PortMaps)
	
	return u
}

type AMUserUDPRequest struct{
	Action			string
	Version 		string
	UserId			string
	UserContent		AMUser
	UserContentMd5	string
}
	
type AMUserUDPResponse struct{
	Action 			string //unused
	Version			string
	UserContentMd5		string
	IsSucceeded		string//unused
}

type AMUserRESTResponse struct{
	Version 		string 
	UserListData	[]AMUser
}


type AMUserStorage struct{
	UserContent AMUser
	UserContentMd5 string
	LastHeartbeat time.Time 
}

