module types

pub struct ThreadType {
	inner Type
}

pub fn new_thread_type(inner Type) &ThreadType {
	return &ThreadType{
		inner: inner
	}
}

pub fn (s &ThreadType) name() string {
	return 'thread ${s.inner.name()}'
}

pub fn (s &ThreadType) qualified_name() string {
	return 'thread ${s.inner.qualified_name()}'
}

pub fn (s &ThreadType) readable_name() string {
	return 'thread ${s.inner.readable_name()}'
}

pub fn (s &ThreadType) accept(mut visitor TypeVisitor) {
	if !visitor.enter(s) {
		return
	}

	s.inner.accept(mut visitor)
}
