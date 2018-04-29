package stmt_test

import (
	"bytes"
	"testing"

	"github.com/z7zmey/php-parser/node/expr"

	"github.com/z7zmey/php-parser/node"
	"github.com/z7zmey/php-parser/node/stmt"
	"github.com/z7zmey/php-parser/php5"
	"github.com/z7zmey/php-parser/php7"
)

func TestForeach(t *testing.T) {
	t.Helper()
	src := `<? foreach ($a as $v) {}`

	expected := &stmt.StmtList{
		Stmts: []node.Node{
			&stmt.Foreach{
				Expr:     &expr.Variable{VarName: &node.Identifier{Value: "a"}},
				Variable: &expr.Variable{VarName: &node.Identifier{Value: "v"}},
				Stmt: &stmt.InnerStmtList{
					Stmts: &stmt.StmtList{Stmts: []node.Node{}},
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

func TestForeachExpr(t *testing.T) {
	t.Helper()
	src := `<? foreach ([] as $v) {}`

	expected := &stmt.StmtList{
		Stmts: []node.Node{
			&stmt.Foreach{
				Expr:     &expr.ShortArray{Items: []node.Node{}},
				Variable: &expr.Variable{VarName: &node.Identifier{Value: "v"}},
				Stmt: &stmt.InnerStmtList{
					Stmts: &stmt.StmtList{Stmts: []node.Node{}},
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

func TestAltForeach(t *testing.T) {
	t.Helper()
	src := `<? foreach ($a as $v) : endforeach;`

	expected := &stmt.StmtList{
		Stmts: []node.Node{
			&stmt.AltForeach{
				Expr:     &expr.Variable{VarName: &node.Identifier{Value: "a"}},
				Variable: &expr.Variable{VarName: &node.Identifier{Value: "v"}},
				Stmt:     &stmt.StmtList{Stmts: []node.Node{}},
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

func TestForeachWithKey(t *testing.T) {
	t.Helper()
	src := `<? foreach ($a as $k => $v) {}`

	expected := &stmt.StmtList{
		Stmts: []node.Node{
			&stmt.Foreach{
				Expr:     &expr.Variable{VarName: &node.Identifier{Value: "a"}},
				Key:      &expr.Variable{VarName: &node.Identifier{Value: "k"}},
				Variable: &expr.Variable{VarName: &node.Identifier{Value: "v"}},
				Stmt: &stmt.InnerStmtList{
					Stmts: &stmt.StmtList{Stmts: []node.Node{}},
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

func TestForeachExprWithKey(t *testing.T) {
	t.Helper()
	src := `<? foreach ([] as $k => $v) {}`

	expected := &stmt.StmtList{
		Stmts: []node.Node{
			&stmt.Foreach{
				Expr:     &expr.ShortArray{Items: []node.Node{}},
				Key:      &expr.Variable{VarName: &node.Identifier{Value: "k"}},
				Variable: &expr.Variable{VarName: &node.Identifier{Value: "v"}},
				Stmt: &stmt.InnerStmtList{
					Stmts: &stmt.StmtList{Stmts: []node.Node{}},
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

func TestForeachWithRef(t *testing.T) {
	t.Helper()
	src := `<? foreach ($a as $k => &$v) {}`

	expected := &stmt.StmtList{
		Stmts: []node.Node{
			&stmt.Foreach{
				ByRef:    true,
				Expr:     &expr.Variable{VarName: &node.Identifier{Value: "a"}},
				Key:      &expr.Variable{VarName: &node.Identifier{Value: "k"}},
				Variable: &expr.Variable{VarName: &node.Identifier{Value: "v"}},
				Stmt: &stmt.InnerStmtList{
					Stmts: &stmt.StmtList{Stmts: []node.Node{}},
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

func TestForeachWithList(t *testing.T) {
	t.Helper()
	src := `<? foreach ($a as $k => list($v)) {}`

	expected := &stmt.StmtList{
		Stmts: []node.Node{
			&stmt.Foreach{
				ByRef: false,
				Expr:  &expr.Variable{VarName: &node.Identifier{Value: "a"}},
				Key:   &expr.Variable{VarName: &node.Identifier{Value: "k"}},
				Variable: &expr.List{
					Items: []node.Node{
						&expr.ArrayItem{
							ByRef: false,
							Val:   &expr.Variable{VarName: &node.Identifier{Value: "v"}},
						},
					},
				},
				Stmt: &stmt.InnerStmtList{
					Stmts: &stmt.StmtList{Stmts: []node.Node{}},
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
