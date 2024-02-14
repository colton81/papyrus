import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

struct DecoratorMacro: PeerMacro {
    static func expansion(of node: AttributeSyntax,
                          providingPeersOf declaration: some DeclSyntaxProtocol,
                          in context: some MacroExpansionContext) throws -> [DeclSyntax] {
//        let messageID = MessageID(domain: "test", id: "papyrus")
//        let message = MyDiagnostic(message: "Testing Peer!", diagnosticID: messageID, severity: .warning)
//        let diagnostic = Diagnostic(node: Syntax(node), message: message)
        let attributeName = node.arguments?._syntaxNode
        
            // Create a diagnostic message including the node's attribute name
//        let messageText = "Testing Peer with attribute: \(attributeName)"
//        
//        let messageID = MessageID(domain: "test", id: "papyrus")
//        let message = MyDiagnostic(message: messageText, diagnosticID: messageID, severity: .warning)
//        let diagnostic = Diagnostic(node: Syntax(node), message: message)
//        
//        context.diagnose(diagnostic)
        
        // TODO: Add some compiler safety to ensure certain attributes can't be on certain members.
        return []
    }
}

struct MyDiagnostic: DiagnosticMessage {
    let message: String
    let diagnosticID: MessageID
    let severity: DiagnosticSeverity
}
