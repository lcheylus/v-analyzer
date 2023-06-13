module psi

import analyzer.psi.types

pub struct ConstantDefinition {
	PsiElementImpl
}

pub fn (c &ConstantDefinition) is_public() bool {
	modifiers := c.visibility_modifiers() or { return false }
	return modifiers.is_public()
}

pub fn (c &ConstantDefinition) get_type() types.Type {
	expr := c.expression() or { return types.unknown_type }

	if expr is PsiTypedElement {
		return expr.get_type()
	}

	return types.unknown_type
}

fn (c &ConstantDefinition) identifier() ?PsiElement {
	return c.find_child_by_type(.identifier)
}

pub fn (c ConstantDefinition) identifier_text_range() TextRange {
	if stub := c.get_stub() {
		return stub.text_range
	}

	identifier := c.identifier() or { return TextRange{} }
	return identifier.text_range()
}

pub fn (c ConstantDefinition) name() string {
	if stub := c.get_stub() {
		return stub.name
	}

	identifier := c.identifier() or { return '' }
	return identifier.get_text()
}

pub fn (c ConstantDefinition) doc_comment() string {
	if stub := c.get_stub() {
		return stub.comment
	}
	parent := c.parent() or { return '' }
	return extract_doc_comment(parent)
}

pub fn (c ConstantDefinition) visibility_modifiers() ?&VisibilityModifiers {
	decl := c.parent() or { return none }
	modifiers := decl.find_child_by_type_or_stub(.visibility_modifiers)?
	if modifiers is VisibilityModifiers {
		return modifiers
	}
	return none
}

pub fn (c &ConstantDefinition) expression() ?PsiElement {
	if c.stub_based() {
		return none // TODO: show constant value from stub
	}
	return c.last_child()
}

pub fn (_ ConstantDefinition) stub() {}
