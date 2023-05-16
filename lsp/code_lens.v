module lsp

pub struct CodeLensOptions {
pub mut:
	resolve_provider bool [json: resolveProvider]
}

// method: ‘textDocument/codeLens’
// response: []CodeLens | none
pub struct CodeLensParams {
pub:
	text_document TextDocumentIdentifier [json: textDocument]
}

pub struct CodeLens {
pub:
	range   Range
	command Command
	data    string  [raw]
}

pub struct CodeLensRegistrationOptions {
	document_selector []DocumentFilter [json: documentSelector]
	resolve_provider  bool             [json: resolveProvider]
}

// method: ‘codeLens/resolve’
// response: CodeLens
// request: CodeLens
