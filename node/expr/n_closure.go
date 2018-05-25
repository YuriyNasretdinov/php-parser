package expr

import (
	"github.com/z7zmey/php-parser/node"
	"github.com/z7zmey/php-parser/node/stmt"
	"github.com/z7zmey/php-parser/walker"
)

// Closure node
type Closure struct {
	ReturnsRef    bool
	Static        bool
	PhpDocComment string
	ParameterList *node.ParameterList
	ClosureUse    *ClosureUse
	ReturnType    node.Node
	StmtList      *stmt.StmtList
}

// NewClosure node constructor
func NewClosure(ParameterList *node.ParameterList, ClosureUse *ClosureUse, ReturnType node.Node, StmtList *stmt.StmtList, Static bool, ReturnsRef bool, PhpDocComment string) *Closure {
	return &Closure{
		ReturnsRef,
		Static,
		PhpDocComment,
		ParameterList,
		ClosureUse,
		ReturnType,
		StmtList,
	}
}

// Attributes returns node attributes as map
func (n *Closure) Attributes() map[string]interface{} {
	return map[string]interface{}{
		"ReturnsRef":    n.ReturnsRef,
		"Static":        n.Static,
		"PhpDocComment": n.PhpDocComment,
	}
}

// Walk traverses nodes
// Walk is invoked recursively until v.EnterNode returns true
func (n *Closure) Walk(v walker.Visitor) {
	if v.EnterNode(n) == false {
		return
	}

	if n.ParameterList != nil {
		vv := v.GetChildrenVisitor("ParameterList")
		n.ParameterList.Walk(vv)
	}

	if n.ClosureUse != nil {
		vv := v.GetChildrenVisitor("ClosureUse")
		n.ClosureUse.Walk(vv)
	}

	if n.ReturnType != nil {
		vv := v.GetChildrenVisitor("ReturnType")
		n.ReturnType.Walk(vv)
	}

	if n.StmtList != nil {
		vv := v.GetChildrenVisitor("StmtList")
		n.StmtList.Walk(vv)
	}

	v.LeaveNode(n)
}
