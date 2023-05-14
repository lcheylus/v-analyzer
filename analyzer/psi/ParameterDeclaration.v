module psi

import analyzer.psi.types

pub struct ParameterDeclaration {
	PsiElementImpl
}

pub fn (p &ParameterDeclaration) get_type() types.Type {
	if builtin_typ := p.find_child_by_type(.builtin_type) {
		return types.new_primitive_type(builtin_typ.get_text())
	}
	if ref := p.find_child_by_type(.type_reference_expression) {
		return types.new_struct_type(ref.get_text())
	}

	return types.unknown_type
}

pub fn (p &ParameterDeclaration) identifier() ?PsiElement {
	return p.find_child_by_type(.identifier)
}

pub fn (p &ParameterDeclaration) identifier_text_range() TextRange {
	identifier := p.identifier() or { return TextRange{} }
	return identifier.text_range()
}

pub fn (p &ParameterDeclaration) name() string {
	if id := p.identifier() {
		return id.get_text()
	}

	return ''
}

pub fn (p &ParameterDeclaration) mutability_modifiers() ?&MutabilityModifiers {
	modifiers := p.find_child_by_type(.mutability_modifiers)?
	if modifiers is MutabilityModifiers {
		return modifiers
	}
	return none
}
