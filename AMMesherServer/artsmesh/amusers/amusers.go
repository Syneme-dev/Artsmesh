package amusers

import (
	"time"
)

type PortMap struct{
	Oringin_port string
	Mapped_port string
}

type AMUser struct{
	Id string
	Name string
	Public_ip string
	Private_ip string
	Local_leader string 
	Groupname string
	Domain string
	Location string
	Description string
	//Ports_mapped map[string]*PortMap
}
	
type AMUserResonse struct{
	Version int
	Data []AMUser
}

type AMUserRequset struct{
	Action string
	UserContent AMUser
	UserContentMd5 string
}

type AMUserStorage struct{
	UserContent AMUser
	UserContentMd5 string
	LastHeartbeat time.Time 
}

func (user *AMUser)Copy()*AMUser{
	u := new(AMUser)
	u.Id= user.Id
	u.Name = user.Name
	u.Public_ip = user.Public_ip
	u.Private_ip = user.Private_ip
	u.Local_leader = user.Local_leader 
	u.Groupname = user.Groupname
	u.Domain = user.Domain
	u.Location = user.Location
	u.Description = u.Description
	
	return u
}
