module types

pub struct MultiReturnType {
pub:
	types []Type
}

pub fn new_multi_return_type(types []Type) &MultiReturnType {
	return &MultiReturnType{
		types: types
	}
}

pub fn (s &MultiReturnType) name() string {
	return '(${s.types.map(it.name()).join(', ')})'
}

pub fn (s &MultiReturnType) qualified_name() string {
	return '(${s.types.map(it.qualified_name()).join(', ')})'
}

pub fn (s &MultiReturnType) readable_name() string {
	return '(${s.types.map(it.readable_name()).join(', ')})'
}

pub fn (s &MultiReturnType) accept(mut visitor TypeVisitor) {
	if !visitor.enter(s) {
		return
	}

	for type_ in s.types {
		type_.accept(mut visitor)
	}
}
