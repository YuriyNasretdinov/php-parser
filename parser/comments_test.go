package parser_test

import (
	"testing"

	"github.com/z7zmey/php-parser/comment"
	"github.com/z7zmey/php-parser/node"
	"github.com/z7zmey/php-parser/parser"
)

func TestComments(t *testing.T) {
	n := node.NewIdentifier("test")

	commentGroup := []*comment.Comment{
		comment.NewComment("/** hello world */", nil, ";"),
		comment.NewComment("// hello world", nil, "T_VARIABLE"),
	}

	comments := parser.Comments{}
	comments.AddComments(n, commentGroup)

	expected := `"/** hello world */" before token ";"`
	actual := comments[n][0].String()

	if expected != actual {
		t.Errorf("expected: %q\nactual: %q", expected, actual)
	}

	expected = `"// hello world" before token "T_VARIABLE"`
	actual = comments[n][1].String()

	if expected != actual {
		t.Errorf("expected: %q\nactual: %q", expected, actual)
	}
}
