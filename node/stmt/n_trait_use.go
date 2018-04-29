package stmt

import (
	"github.com/z7zmey/php-parser/node"
	"github.com/z7zmey/php-parser/walker"
)

// TraitUse node
type TraitUse struct {
	Traits                   []node.Node
	InnerTraitAdaptationList *InnerTraitAdaptationList
}

// NewTraitUse node constructor
func NewTraitUse(Traits []node.Node, InnerAdaptationList *InnerTraitAdaptationList) *TraitUse {
	return &TraitUse{
		Traits,
		InnerAdaptationList,
	}
}

// Attributes returns node attributes as map
func (n *TraitUse) Attributes() map[string]interface{} {
	return nil
}

// Walk traverses nodes
// Walk is invoked recursively until v.EnterNode returns true
func (n *TraitUse) Walk(v walker.Visitor) {
	if v.EnterNode(n) == false {
		return
	}

	if n.Traits != nil {
		vv := v.GetChildrenVisitor("Traits")
		for _, nn := range n.Traits {
			if nn != nil {
				nn.Walk(vv)
			}
		}
	}

	if n.InnerTraitAdaptationList != nil {
		vv := v.GetChildrenVisitor("InnerTraitAdaptationList")
		n.InnerTraitAdaptationList.Walk(vv)
	}

	v.LeaveNode(n)
}
