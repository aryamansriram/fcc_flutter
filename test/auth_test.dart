import 'package:fcc_app/services/auth/auth_exceptions.dart';
import 'package:fcc_app/services/auth/auth_provider.dart';
import 'package:fcc_app/services/auth/auth_user.dart';
import 'package:test/test.dart';


void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test(
      'Should not be initialized to begin with', () {
        expect(provider.isInitialized, false);
      }
    );
     
    test('Cannot logout before initialize', (){
      expect(provider.logOut(), 
      throwsA(const TypeMatcher<NotInitializedException>()));

      
      
    });

    test('Should be initialized', () async{
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('User should be null after init', (){
      expect(provider.currentUser, null);
    });

    test('should be able to init under 2 seconds', () async{
      await provider.initialize();
      expect(provider.isInitialized, true);
    },timeout: const Timeout(const Duration(seconds: 2))
    );


    test('create user should delegate to login function', () async{
      final badEmailUser = provider.createUser(email: 'foo@bar.com', password: 'anypassword');
      expect(badEmailUser, throwsA(const TypeMatcher<UserNotFoundException>()));

      final badPasswordUser= provider.createUser(email: 'someone@bar.com', password: 'foobar');

      expect(badPasswordUser, throwsA(const TypeMatcher<WrongPasswordAuthException>()));

      final user = await provider.createUser(email: 'foo', password: 'bar');

      expect(provider.currentUser, user);
      expect(user.isEmailVerified,false);

    });

    test('Logged in user should be able to get verified', () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);

    });

    test('Should be able to logout and login again', () async{
      await provider.logOut();
      await provider.logIn(email: 'user', password: 'password');
      final user = provider.currentUser;
      expect(user, isNotNull);

    });




  });

}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {

  var _isInitialized = false;
  AuthUser? _user;
  bool get isInitialized => _isInitialized;
  

  @override
  Future<AuthUser> createUser({required String email, required String password}) async{
    if(!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);

  }

  @override
  // TODO: implement currentUser
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
   await Future.delayed(const Duration(seconds: 1));
   _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if (!isInitialized) throw NotInitializedException();
    if (email=='foo@bar.com') throw UserNotFoundException();
    if (password=='foobar') throw WrongPasswordAuthException();
    const user = AuthUser(id: 'my_id',isEmailVerified: false,email:'foo@bar');
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async{
    if (!isInitialized) throw NotInitializedException();
    if(_user==null) throw UserNotFoundException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
    
  }

  @override
  Future<void> sendEmailVerification() async{
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user==null) throw UserNotFoundException();
    const newUser = AuthUser(id: "my_id",isEmailVerified: true, email: 'foo@bar.com');
    _user = newUser;
  }

}