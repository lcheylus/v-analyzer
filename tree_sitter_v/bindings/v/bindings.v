module v

import x.json2
import os
import tree_sitter

#flag -I @VMODROOT/src
#flag @VMODROOT/src/parser.o

#include "@VMODROOT/bindings/v/bindings.h"

fn C.tree_sitter_v() &tree_sitter.TSLanguage

pub const language = unsafe { C.tree_sitter_v() }

// load_node_types reads the node-types.json file for static analysis.
pub fn load_node_types() ![]json2.Any {
	contents := os.read_file(os.join_path(@VMODROOT, 'src', 'node-types.json'))!
	list := json2.raw_decode(contents)!
	return list.arr()
}
