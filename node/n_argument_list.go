package node

import (
	"github.com/z7zmey/php-parser/walker"
)

// ArgumentList node
type ArgumentList struct {
	InnerArgumentList *InnerArgumentList
}

// NewArgumentList node constructor
func NewArgumentList(InnerArgumentList *InnerArgumentList) *ArgumentList {
	return &ArgumentList{
		InnerArgumentList,
	}
}

// Attributes returns node attributes as map
func (n *ArgumentList) Attributes() map[string]interface{} {
	return nil
}

// Walk traverses nodes
// Walk is invoked recursively until v.EnterNode returns true
func (n *ArgumentList) Walk(v walker.Visitor) {
	if v.EnterNode(n) == false {
		return
	}

	if n.InnerArgumentList != nil {
		vv := v.GetChildrenVisitor("InnerArgumentList")
		n.InnerArgumentList.Walk(vv)
	}

	v.LeaveNode(n)
}
