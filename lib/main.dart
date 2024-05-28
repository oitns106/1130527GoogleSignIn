import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';                       //請同學自行建立此檔案
import 'package:google_sign_in/google_sign_in.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:twitter_login/twitter_login.dart';

class AuthencationHelper {
  final FirebaseAuth auth=FirebaseAuth.instance;
  get user=>auth.currentUser;

  Future<String?> signUp({required String email, required String password}) async {
    try {
      await auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> signIn({required String email, required String password}) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  static Future<void> signOut() async {
    GoogleSignIn s=GoogleSignIn();
    await s.signOut();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth Demo',
      theme: ThemeData(primarySwatch: Colors.blue,),
      home: Login(),
    );
  }
}

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(8),
        children: [
          SizedBox(height: 80,),
          Column(
            children: [
              FlutterLogo(size: 55),
              SizedBox(height: 50,),
              Text('Have a nice day!', style: TextStyle(fontSize: 24),),
            ],
          ),
          SizedBox(height: 50,),
          Padding(
            padding: EdgeInsets.all(16),
            child: LoginForm(),
          ),
          SizedBox(height: 20,),
          Row(children: [
            SizedBox(width: 30,),
            Text('New here? ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Signup()));
              },
              child: Text('Get Registered Now!', style: TextStyle(fontSize: 20, color: Colors.blue),),
            ),
          ],),
          SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SquareTile(imagePath: 'assets/google.png',
                         onTap: () async {
                            final ok=await signInWithGoogle();
                            if (ok!) Navigator.push(context, MaterialPageRoute(builder: (context)=>Home()));
                         },),
            ],
          ),
        ],
      ),
    );
  }
}

class SquareTile extends StatelessWidget {
  final String imagePath;
  void Function() onTap;

  SquareTile({Key? key, required this.imagePath, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.purpleAccent),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Image.asset(imagePath, height: 40,),
      ),
    );
  }
}

//Social Authentication
//Google Sign-In
Future<bool> signInWithGoogle() async {
  final GoogleSignInAccount? googleUser=await GoogleSignIn().signIn();
  if (googleUser==null) return false;
  final GoogleSignInAuthentication? googleAuth=await googleUser?.authentication;
  final credential=GoogleAuthProvider.credential(accessToken: googleAuth?.accessToken,
                                                 idToken: googleAuth?.idToken);
  await FirebaseAuth.instance.signInWithCredential(credential);
  return true;
}

/*
//Facebook Sign-In
Future<UserCredential> signInWithFacebook() async {
  final loginResult=await FacebookAuth.instance.login();
  final OAuthCredential facebookAuthCredential=await FacebookAuthProvider.credential(loginResult.accessToken!.token);
  return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
}

//Twitter Sign-In
Future<UserCredential> signInWithTwitter() async {
  final twitterLogin=TwitterLogin(apiKey: '<your consumer key>',
                                  apiSecretKey: '<your consumer secret>',
                                  redirectURI: '<your_scheme>://');
  final authResult=await twitterLogin.login();
  final twitterAuthCredential=await TwitterAuthProvider.credential(accessToken: authResult.authToken!,
                                                                   secret: authResult.authTokenSecret!);
  return FirebaseAuth.instance.signInWithCredential(twitterAuthCredential);
}
*/

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {

  final formKey1=GlobalKey<FormState>();
  late String email;
  late String password;
  bool obscureText=true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextFormField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.email_outlined),
              labelText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(100)),
              ),
            ),
            validator: (value) {
              if (value!.isEmpty)
                return 'Please enter some text';
              else
                return null;
            },
            onSaved: (value)=>email=value!,
          ),
          SizedBox(height: 20,),
          TextFormField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.lock_outlined),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    obscureText=!obscureText;
                  });
                },
                child: Icon(obscureText? Icons.visibility_off:Icons.visibility,),
              ),
              labelText: 'Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(100)),
              ),
            ),
            obscureText: obscureText,
            validator: (value) {
              if (value!.isEmpty)
                return 'Please enter some text';
              else
                return null;
            },
            onSaved: (value)=>password=value!,
          ),
          Container(
            margin: EdgeInsets.only(top: 5,),
            alignment: Alignment.centerRight,
            child: GestureDetector(
              child: Text('Forgot password?', style: TextStyle(
                                                      decoration: TextDecoration.underline,
                                                      fontStyle: FontStyle.italic,
                                                      color: Colors.purple,
              ),),
              onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>forgetP())),
            ),
          ),
          SizedBox(height: 30,),
          SizedBox(
            height: 54,
            width: 184,
            child: ElevatedButton(
              child: Text('Login', style: TextStyle(fontSize: 24),),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
              ),
              onPressed: () {
                if (formKey1.currentState!.validate()) {
                  formKey1.currentState!.save();
                  AuthencationHelper().signIn(email: email!, password: password!)
                     .then((result) {
                       if (result==null)
                         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Home()));
                       else
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result!, style: TextStyle(fontSize: 16)),));
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Signup extends StatelessWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          SizedBox(height: 80,),
          Column(children: [
            FlutterLogo(size: 55),
          ],),
          SizedBox(height: 50,),
          Text('Welcome!', style: TextStyle(fontSize: 24),),
          Padding(
            padding: EdgeInsets.all(8),
            child: SignupForm(),
          ),
          Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text('Already here?', style: TextStyle(fontWeight: FontWeight.bold,
                                                             fontSize: 20,
                      ),),
                      GestureDetector(
                        child: Text('Get logged in now!', style: TextStyle(color: Colors.blue, fontSize: 20,),),
                      ),
                    ],
                  ),
                ],
              ),),
        ],
      ),
    );
  }
}

class SignupForm extends StatefulWidget {
  const SignupForm({Key? key}) : super(key: key);

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {

  final formKey2=GlobalKey<FormState>();
  late String email;
  late String password;
  late String name;
  bool obscureText=false;
  bool agree=false;
  final pass=TextEditingController();

  @override
  Widget build(BuildContext context) {

    var border=OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(100)),);
    var space=SizedBox(height: 10,);

    return Form(
      key: formKey2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextFormField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.email_outlined),
              labelText: 'Email',
              border: border
            ),
            validator: (value) {
              if (value!.isEmpty)
                return 'Please enter some text';
              else
                return null;
            },
            onSaved: (value)=>email=value!,
          ),
          space,
          TextFormField(
            controller: pass,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.lock_outlined),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    obscureText=!obscureText;
                  });
                },
                child: Icon(obscureText? Icons.visibility_off:Icons.visibility,),
              ),
              labelText: 'Password',
              border: border
            ),
            obscureText: !obscureText,
            validator: (value) {
              if (value!.isEmpty)
                return 'Please enter some text';
              else
                return null;
            },
            onSaved: (value)=>password=value!,
          ),
          space,
          TextFormField(
            controller: pass,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock_outlined),
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      obscureText=!obscureText;
                    });
                  },
                  child: Icon(obscureText? Icons.visibility_off:Icons.visibility,),
                ),
                labelText: 'Confirm Password',
                border: border
            ),
            obscureText: true,
            validator: (value) {
              if (value!=pass.text)
                return 'Password not match!';
              else
                return null;
            },
            onSaved: (value)=>password=value!,
          ),
          space,
          TextFormField(
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.account_circle),
                labelText: 'Full name',
                border: border
            ),
            validator: (value) {
              if (value!.isEmpty)
                return 'Please enter some text';
              else
                return null;
            },
            onSaved: (value)=>name=value!,
          ),
          Row(
            children: [
              Checkbox(value: agree,
                       onChanged: (value) {
                          setState(() {
                            agree=!agree;
                          });
                       }),
              Flexible(child: Text('By creating account, I agree to Terms & Conditions and Privacy Policy'),),
            ],
          ),
          space,
          SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
              child: Text('Sign up', style: TextStyle(fontSize: 24),),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
              ),
              onPressed: () {
                if (formKey2.currentState!.validate()) {
                  formKey2.currentState!.save();
                  AuthencationHelper().signUp(email: email!, password: password!)
                      .then((result) {
                    if (result==null)
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Home()));
                    else
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result!, style: TextStyle(fontSize: 16)),));
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class forgetP extends StatefulWidget {
  const forgetP({Key? key}) : super(key: key);

  @override
  State<forgetP> createState() => _forgetPState();
}

class _forgetPState extends State<forgetP> {

  final formKey3=GlobalKey<FormState>();
  final emailController=TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent,
                     elevation: 0,
                     title: Text('Reset password'),),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: formKey3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('接收信件以重置密碼', textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 20),),
              SizedBox(height: 20,),
              TextFormField(
                controller: emailController,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(labelText: 'Email'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (email) {
                  if (email!=null && !EmailValidator.validate(email))
                    return 'Enter a valid Email';
                  else
                    return null;
                },
              ),
              SizedBox(height: 10,),
              ElevatedButton.icon(
                  icon: Icon(Icons.email_outlined),
                  label: Text('Reset password', style: TextStyle(fontSize: 20,),),
                  onPressed: () async {
                    showDialog(context: context,
                               builder: (context)=>Center(child: CircularProgressIndicator(),),);
                    try {
                      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password reset mail sent', style: TextStyle(fontSize: 16)),));
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    } on FirebaseAuthException catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message!, style: TextStyle(fontSize: 16)),));
                      Navigator.of(context).pop();
                    }
                  },),
            ],
          ),
        ),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Welcome'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.logout),
        tooltip: 'Logout',
        onPressed: () {
          AuthencationHelper.signOut().then((_)=>Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Login())));
        },
      ),
    );
  }
}
