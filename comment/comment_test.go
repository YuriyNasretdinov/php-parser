package comment_test

import (
	"testing"

	"github.com/z7zmey/php-parser/position"

	"github.com/z7zmey/php-parser/comment"
)

func TestCommentGetPosition(t *testing.T) {
	expected := position.NewPosition(0, 0, 0, 0)

	comment := comment.NewComment("/** hello world */", expected, "")

	actual := comment.Position()

	if expected != actual {
		t.Errorf("expected and actual are not equal\n")
	}
}

func TestCommentPrint(t *testing.T) {
	expected := `"/** hello world */" before token "T_VARIABLE"`

	comment := comment.NewComment("/** hello world */", nil, "T_VARIABLE")

	actual := comment.String()

	if expected != actual {
		t.Errorf("expected and actual are not equal\nexpected: %q\nactual: %q", expected, actual)
	}
}
