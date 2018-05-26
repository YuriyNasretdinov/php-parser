package comment

import (
	"fmt"

	"github.com/z7zmey/php-parser/position"
)

// Comment aggrigates information about comment /**
type Comment struct {
	value     string
	position  *position.Position
	tokenName string
}

// NewComment - Comment constructor
func NewComment(value string, pos *position.Position, tokenName string) *Comment {
	return &Comment{
		value,
		pos,
		tokenName,
	}
}

func (c *Comment) String() string {
	return fmt.Sprintf("%q before token %q", c.value, c.tokenName)
}

// Position returns comment position
func (c *Comment) Position() *position.Position {
	return c.position
}

// SetTokenName returns token name
func (c *Comment) SetTokenName(tokenName string) {
	c.tokenName = tokenName
}

// TokenName returns token name
func (c *Comment) TokenName() string {
	return c.tokenName
}
