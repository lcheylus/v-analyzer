import * as vscode from 'vscode';
import * as path from "path";
import * as lc from "vscode-languageclient";
import * as ra from "./lsp_ext";
import {runVCommand, runVCommandCallback} from './exec';
import {ContextInit, Command} from "./ctx";
import {LanguageClient} from "vscode-languageclient/node";
import {spawnSync} from "child_process";
import {isVlangDocument, isVlangEditor, sleep} from "./utils";

/**
 * Run current directory.
 */
export function runWorkspace(
	_: ContextInit
): Command {
	return async () => {
		const document = vscode.window.activeTextEditor.document;
		await document.save();
		const dir = path.parse(document.fileName).dir

		runVCommand(['run', dir]);
	}
}

export function runFile(
	_: ContextInit
): Command {
	return async () => {
		const document = vscode.window.activeTextEditor.document;
		await document.save();
		const fileName = document.fileName

		runVCommand(['run', fileName]);
	}
}

/**
 * Show version info.
 */
export function version(
	_: ContextInit
): Command {
	return () => {
		runVCommandCallback(['-version'], (err, stdout) => {
			if (err) {
				void vscode.window.showErrorMessage(
					'Unable to get the version number. Is V installed correctly?'
				);
				return;
			}
			void vscode.window.showInformationMessage(stdout);
		});
	}
}

export function serverVersion(
	ctx: ContextInit
): Command {
	return async () => {
		if (!ctx.serverPath) {
			void vscode.window.showWarningMessage(`v-analyzer server is not running`);
			return;
		}
		const { stdout } = spawnSync(ctx.serverPath, ["--version"], { encoding: "utf8" });
		const versionString = stdout.slice(`v-analyzer version`.length).trim();

		void vscode.window.showInformationMessage(`v-analyzer version: ${versionString}`);
	}
}

export function showReferences(ctx: ContextInit): Command {
	return async (uri: string, positionData: string, locationData: string) => {
		const locations = JSON.parse(locationData);
		const position = JSON.parse(positionData);
		await showReferencesImpl(ctx.client, uri, position, locations);
	};
}

export async function showReferencesImpl(
	client: LanguageClient | undefined,
	uri: string,
	position: lc.Position,
	locations: lc.Location[]
) {
	if (!client) return;
	await vscode.commands.executeCommand(
		"editor.action.showReferences",
		vscode.Uri.parse(uri),
		client.protocol2CodeConverter.asPosition(position),
		locations.map(client.protocol2CodeConverter.asLocation)
	);
}

export function viewStubTree(ctx: ContextInit): Command {
	const tdcp = new (class implements vscode.TextDocumentContentProvider {
		readonly uri = vscode.Uri.parse("v-analyzer-file-stub-tree://viewStubTree/file.stree");
		readonly eventEmitter = new vscode.EventEmitter<vscode.Uri>();
		constructor() {
			vscode.workspace.onDidChangeTextDocument(
				this.onDidChangeTextDocument,
				this,
				ctx.subscriptions
			);
			vscode.window.onDidChangeActiveTextEditor(
				this.onDidChangeActiveTextEditor,
				this,
				ctx.subscriptions
			);
		}

		private onDidChangeTextDocument(event: vscode.TextDocumentChangeEvent) {
			if (isVlangDocument(event.document)) {
				// We need to order this after language server updates, but there's no API for that.
				// Hence, good old sleep().
				void sleep(10).then(() => this.eventEmitter.fire(this.uri));
			}
		}
		private onDidChangeActiveTextEditor(editor: vscode.TextEditor | undefined) {
			if (editor && isVlangEditor(editor)) {
				this.eventEmitter.fire(this.uri);
			}
		}

		async provideTextDocumentContent(
			_uri: vscode.Uri,
			ct: vscode.CancellationToken
		): Promise<string> {
			const rustEditor = ctx.activeVlangEditor;
			if (!rustEditor) return "";
			const client = ctx.client;

			const params = client.code2ProtocolConverter.asTextDocumentIdentifier(
				rustEditor.document
			);
			return client.sendRequest(ra.viewStubTree, params, ct);
		}

		get onDidChange(): vscode.Event<vscode.Uri> {
			return this.eventEmitter.event;
		}
	})();

	ctx.pushExtCleanup(
		vscode.workspace.registerTextDocumentContentProvider("v-analyzer-file-stub-tree", tdcp)
	);

	return async () => {
		const document = await vscode.workspace.openTextDocument(tdcp.uri);
		tdcp.eventEmitter.fire(tdcp.uri);
		void (await vscode.window.showTextDocument(document, {
			viewColumn: vscode.ViewColumn.Two,
			preserveFocus: true,
		}));
	};
}
