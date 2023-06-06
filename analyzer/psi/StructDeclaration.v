module psi

import analyzer.psi.types

pub struct StructDeclaration {
	PsiElementImpl
}

pub fn (s &StructDeclaration) generic_parameters() ?&GenericParameters {
	generic_parameters := s.find_child_by_type_or_stub(.generic_parameters) or { return none }
	if generic_parameters is GenericParameters {
		return generic_parameters
	}
	return none
}

pub fn (s &StructDeclaration) is_public() bool {
	modifiers := s.visibility_modifiers() or { return false }
	return modifiers.is_public()
}

pub fn (s &StructDeclaration) module_name() string {
	return stubs_index.get_module_qualified_name(s.containing_file.path)
}

pub fn (s &StructDeclaration) get_type() types.Type {
	return types.new_struct_type(s.name(), s.module_name())
}

pub fn (s &StructDeclaration) attributes() []PsiElement {
	attributes := s.find_child_by_type(.attributes) or { return [] }
	if attributes is Attributes {
		return attributes.attributes()
	}

	return []
}

pub fn (s StructDeclaration) identifier() ?PsiElement {
	return s.find_child_by_type(.identifier)
}

pub fn (s StructDeclaration) identifier_text_range() TextRange {
	if s.stub_id != non_stubbed_element {
		if stub := s.stubs_list.get_stub(s.stub_id) {
			return stub.text_range
		}
	}

	identifier := s.identifier() or { return TextRange{} }
	return identifier.text_range()
}

pub fn (s StructDeclaration) name() string {
	if s.stub_id != non_stubbed_element {
		if stub := s.stubs_list.get_stub(s.stub_id) {
			return stub.name
		}
	}

	identifier := s.identifier() or { return '' }
	return identifier.get_text()
}

pub fn (s StructDeclaration) doc_comment() string {
	if s.stub_id != non_stubbed_element {
		if stub := s.stubs_list.get_stub(s.stub_id) {
			return stub.comment
		}
	}
	return extract_doc_comment(s)
}

pub fn (s StructDeclaration) visibility_modifiers() ?&VisibilityModifiers {
	modifiers := s.find_child_by_type_or_stub(.visibility_modifiers)?
	if modifiers is VisibilityModifiers {
		return modifiers
	}
	return none
}

pub fn (s StructDeclaration) fields() []PsiElement {
	field_declarations := s.find_children_by_type_or_stub(.struct_field_declaration)
	mut result := []PsiElement{cap: field_declarations.len}
	for field_declaration in field_declarations {
		if first_child := field_declaration.first_child_or_stub() {
			if first_child.element_type() != .embedded_definition {
				result << field_declaration
			}
		}
	}
	return result
}

pub fn (s StructDeclaration) embedded_definitions() []PsiElement {
	field_declarations := s.find_children_by_type_or_stub(.struct_field_declaration)
	mut result := []PsiElement{cap: field_declarations.len}
	for field_declaration in field_declarations {
		if first_child := field_declaration.first_child() {
			if first_child.element_type() == .embedded_definition {
				result << field_declaration
			}
		}
	}
	return result
}

pub fn (s &StructDeclaration) is_attribute() bool {
	attrs := s.attributes()
	if attrs.len == 0 {
		return false
	}
	attr := attrs.first()
	if attr is Attribute {
		keys := attr.keys()
		return 'attribute' in keys
	}

	return false
}

pub fn (_ StructDeclaration) stub() {}
