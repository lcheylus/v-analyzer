module types

pub const unknown_type = new_unknown_type()

pub struct UnknownType {}

// new_unknown_type creates a new unknown type.
// Use `unknown_type` constant instead.
fn new_unknown_type() &UnknownType {
	return &UnknownType{}
}

fn (_ &UnknownType) name() string {
	return 'unknown'
}

fn (_ &UnknownType) qualified_name() string {
	return 'unknown'
}

fn (_ &UnknownType) readable_name() string {
	return 'unknown'
}

pub fn (s &UnknownType) accept(mut visitor TypeVisitor) {
	if !visitor.enter(s) {
		return
	}
}
