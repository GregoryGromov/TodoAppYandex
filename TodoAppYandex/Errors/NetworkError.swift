enum NetworkError: Error {
    case URLCreationFailed

    case incorrectRequestFormat // 400
    case incorrectAuthorization // 401
    case elementNotFound // 404
    case serverError // 500

    case unknownError
}
