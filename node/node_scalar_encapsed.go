package node

import (
	"fmt"
	"github.com/z7zmey/php-parser/token"
	"io"
)


type NodeScalarEncapsed struct {
	*simpleNode
	startToken token.Token
	endToken token.Token
	parts []Node
}


func NewNodeScalarEncapsed(startToken token.Token, parts []Node, endToken token.Token) Node {
	return NodeScalarEncapsed{
		&simpleNode{name: "NodeScalarEncapsed", attributes: make(map[string]string)},
		startToken,
		endToken,
		parts,
	}
}

func (n NodeScalarEncapsed) Print(out io.Writer, indent string) {
	fmt.Fprintf(out, "\n%v%v [%d %d]", indent, n.name, n.startToken.StartLine, n.endToken.EndLine)
	fmt.Fprintf(out, "\n%vparts:", indent+"  ",)
	for _, nn := range n.parts {
		nn.Print(out, indent+"    ")
	}
}