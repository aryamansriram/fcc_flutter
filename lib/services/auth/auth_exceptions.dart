//login exceptions
class UserNotFoundException implements Exception {}

class WrongPasswordAuthException implements Exception {}

//register exceptions
class WeakPasswordAuthException implements Exception {}

class EmailAlreadyInUseAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

//generic exceptions
class GenericAuthExceptions implements Exception {}

class UserNotLoggedInAuthException implements Exception {}
