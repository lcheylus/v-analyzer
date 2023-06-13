module psi

import analyzer.psi.types

pub struct EnumFieldDeclaration {
	PsiElementImpl
}

pub fn (_ &EnumFieldDeclaration) is_public() bool {
	return true
}

pub fn (f &EnumFieldDeclaration) doc_comment() string {
	if stub := f.get_stub() {
		return stub.comment
	}

	if comment := f.find_child_by_type(.comment) {
		return comment.get_text().trim_string_left('//').trim(' \t')
	}

	return extract_doc_comment(f)
}

pub fn (f &EnumFieldDeclaration) identifier() ?PsiElement {
	return f.find_child_by_type(.identifier)
}

pub fn (f EnumFieldDeclaration) identifier_text_range() TextRange {
	if stub := f.get_stub() {
		return stub.text_range
	}

	identifier := f.identifier() or { return TextRange{} }
	return identifier.text_range()
}

pub fn (f &EnumFieldDeclaration) name() string {
	if stub := f.get_stub() {
		return stub.name
	}

	identifier := f.identifier() or { return '' }
	return identifier.get_text()
}

pub fn (f &EnumFieldDeclaration) get_type() types.Type {
	owner := f.owner() or { return types.unknown_type }
	if owner is PsiTypedElement {
		return owner.get_type()
	}
	return types.unknown_type
}

pub fn (f &EnumFieldDeclaration) owner() ?PsiElement {
	if stub := f.get_stub() {
		if parent := stub.parent_of_type(.enum_declaration) {
			if is_valid_stub(parent) {
				return parent.get_psi()
			}
		}
		return none
	}

	return f.parent_of_type(.enum_declaration)
}

pub fn (_ EnumFieldDeclaration) stub() {}
