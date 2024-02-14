import Foundation
import SwiftSyntax

extension FunctionDeclSyntax {
    enum ReturnType: Equatable {
        struct TupleParameter: Equatable {
            let label: String?
            let type: String
        }

        case tuple([TupleParameter])
        case type(String)
        case typeResponse(String)
    }

    enum AsyncStyle {
        case concurrency
        case completionHandler
    }

    // MARK: Async Style

    var style: AsyncStyle {
        hasEscapingCompletion ? .completionHandler : .concurrency
    }

    func validateSignature() throws {
        let hasAsyncAwait = effects.contains("async") && effects.contains("throws")
        guard hasEscapingCompletion || hasAsyncAwait else {
            throw PapyrusPluginError("Function must either have `async throws` effects or an `@escaping` completion handler as the final argument.")
        }
    }

    private var hasEscapingCompletion: Bool {
        guard let parameter = parameters.last, returnType == nil else {
            return false
        }

        let type = parameter.type.trimmedDescription
        let isResult = type.hasPrefix("@escaping (Result<") && type.hasSuffix("Error>) -> Void")
        let isResponse = type == "@escaping (Response) -> Void"
        return isResult || isResponse
    }

    // MARK: Function effects & attributes

    var functionName: String {
        name.text
    }

    var effects: [String] {
        [signature.effectSpecifiers?.asyncSpecifier, signature.effectSpecifiers?.throwsSpecifier]
            .compactMap { $0 }
            .map { $0.text }
    }

    var parameters: [FunctionParameterSyntax] {
        signature
            .parameterClause
            .parameters
            .compactMap { $0.as(FunctionParameterSyntax.self) }
    }

    // MARK: Parameter Information

    var callbackName: String? {
        guard let parameter = parameters.last, style == .completionHandler else {
            return nil
        }

        return parameter.variableName
    }

    private var callbackType: String? {
        guard let parameter = parameters.last, returnType == nil else {
            return nil
        }

        let type = parameter.type.trimmedDescription
        if type == "@escaping (Response) -> Void" {
            return "Response"
        } else {
            return type
                .replacingOccurrences(of: "@escaping (Result<", with: "")
                .replacingOccurrences(of: ", Error>) -> Void", with: "")
        }
    }

    // MARK: Return Data

    var returnResponseOnly: Bool {
        responseType == .type("Response")
    }

    var responseType: ReturnType? {
        if style == .completionHandler, let callbackType {
            return .type(callbackType)
        }

        return returnType
    }
    
    var ResponseTypes:(object: String?, key: String?){
        var responseObject: String?
        var keyObject: String?
        for attribute in apiAttributes{
            switch attribute{
                case let .response(expectedResponseType, key):
                    responseObject = expectedResponseType
                    keyObject = key
                default:
                    continue
            }
        }
        return (responseObject,keyObject)
    }

    private var returnType: ReturnType? {
        guard let type = signature.returnClause?.type else {
            return nil
        }
        var responseObject = ResponseTypes.object
        if let type = type.as(TupleTypeSyntax.self) {
            return .tuple(type.elements.map { .init(label: $0.firstName?.text, type: $0.type.trimmedDescription) })
        } else {
            if let responseObject{
                return .typeResponse(responseObject)
            }
            return .type(type.trimmedDescription)
        }
    }
}
