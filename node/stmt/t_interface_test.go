package stmt_test

import (
	"bytes"
	"testing"

	"github.com/z7zmey/php-parser/node/name"

	"github.com/z7zmey/php-parser/node"
	"github.com/z7zmey/php-parser/node/stmt"
	"github.com/z7zmey/php-parser/php5"
	"github.com/z7zmey/php-parser/php7"
)

func TestInterface(t *testing.T) {
	t.Helper()
	src := `<? interface Foo {}`

	expected := &stmt.StmtList{
		Stmts: []node.Node{
			&stmt.Interface{
				PhpDocComment: "",
				InterfaceName: &node.Identifier{Value: "Foo"},
				InnerStmtList: &stmt.InnerStmtList{
					Stmts: &stmt.StmtList{
						Stmts: []node.Node{},
					},
				},
			},
		},
	}

	php7parser := php7.NewParser(bytes.NewBufferString(src), "test.php")
	php7parser.Parse()
	actual := php7parser.GetRootNode()
	assertEqual(t, expected, actual)

	php5parser := php5.NewParser(bytes.NewBufferString(src), "test.php")
	php5parser.Parse()
	actual = php5parser.GetRootNode()
	assertEqual(t, expected, actual)
}

func TestInterfaceExtend(t *testing.T) {
	t.Helper()
	src := `<? interface Foo extends Bar {}`

	expected := &stmt.StmtList{
		Stmts: []node.Node{
			&stmt.Interface{
				PhpDocComment: "",
				InterfaceName: &node.Identifier{Value: "Foo"},
				Extends: []node.Node{
					&name.Name{
						Parts: []node.Node{
							&name.NamePart{Value: "Bar"},
						},
					},
				},
				InnerStmtList: &stmt.InnerStmtList{
					Stmts: &stmt.StmtList{
						Stmts: []node.Node{},
					},
				},
			},
		},
	}

	php7parser := php7.NewParser(bytes.NewBufferString(src), "test.php")
	php7parser.Parse()
	actual := php7parser.GetRootNode()
	assertEqual(t, expected, actual)

	php5parser := php5.NewParser(bytes.NewBufferString(src), "test.php")
	php5parser.Parse()
	actual = php5parser.GetRootNode()
	assertEqual(t, expected, actual)
}

func TestInterfaceExtends(t *testing.T) {
	t.Helper()
	src := `<? interface Foo extends Bar, Baz {}`

	expected := &stmt.StmtList{
		Stmts: []node.Node{
			&stmt.Interface{
				PhpDocComment: "",
				InterfaceName: &node.Identifier{Value: "Foo"},
				Extends: []node.Node{
					&name.Name{
						Parts: []node.Node{
							&name.NamePart{Value: "Bar"},
						},
					},
					&name.Name{
						Parts: []node.Node{
							&name.NamePart{Value: "Baz"},
						},
					},
				},
				InnerStmtList: &stmt.InnerStmtList{
					Stmts: &stmt.StmtList{
						Stmts: []node.Node{},
					},
				},
			},
		},
	}

	php7parser := php7.NewParser(bytes.NewBufferString(src), "test.php")
	php7parser.Parse()
	actual := php7parser.GetRootNode()
	assertEqual(t, expected, actual)

	php5parser := php5.NewParser(bytes.NewBufferString(src), "test.php")
	php5parser.Parse()
	actual = php5parser.GetRootNode()
	assertEqual(t, expected, actual)
}
