import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:overlay_support/overlay_support.dart';
import 'firebase_options.dart';
import 'Pages/Riverpod/RiverpodPage.dart';
import 'Pages/connectivity_plus/connectivityPage.dart';
import '/models/notificationModel.dart';
import 'components/notificationBadge.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          // fontFamily: 'Cubic',
          fontFamily: 'TaipeiSansTCBeta',
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final FirebaseMessaging _messaging;
  late int _notificationCount;
  NotificationModel? _notificationInfo;

  void getPermissioin() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging message = FirebaseMessaging.instance;
    NotificationSettings settings = await message.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data['name']}');

      if (message.notification != null) {
        print("got the message,");
        NotificationModel notificationModel = NotificationModel(
          title: message.notification?.title,
          body: message.notification?.body,
          name: message.data['name'],
        );
        setState(() {
          _notificationInfo = notificationModel;
          _notificationCount++;
        });
        showSimpleNotification(
          Text(_notificationInfo!.title!),
          leading: NotificationBadge(totalNotifications: _notificationCount),
          subtitle: Text(_notificationInfo!.body!),
          background: Colors.cyan.shade700,
          duration: const Duration(seconds: 2),
          autoDismiss: false,
          slideDismissDirection: DismissDirection.horizontal,
        );
      }
    });

    print('User granted permission: ${settings.authorizationStatus}');
    final fcmToken = await FirebaseMessaging.instance.getToken();
    print("fcm token: $fcmToken");
  }

  void checkForInitialMessage() async {
    await Firebase.initializeApp();
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      NotificationModel notificationModel = NotificationModel(
        title: initialMessage.notification?.title,
        body: initialMessage.notification?.body,
        name: initialMessage.data['name'],
      );
      setState(() {
        _notificationInfo = notificationModel;
        _notificationCount++;
      });
    }
  }

  @override
  void initState() {
    _notificationCount = 0;
    super.initState();
    getPermissioin();
    checkForInitialMessage();
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      NotificationModel notificationModel = NotificationModel(
        title: message.notification?.title,
        body: message.notification?.body,
        name: message.data['name'],
      );
      setState(() {
        _notificationInfo = notificationModel;
        _notificationCount++;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                "App Capture，這是繁體中文",
                style: TextStyle(
                  // fontFamily: 'TaipeiSansTCBeta',
                  // fontFamily: 'Cubic',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "capture counts:",
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  NotificationBadge(totalNotifications: _notificationCount),
                ],
              ),
              const SizedBox(height: 16),
              _notificationInfo != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "TITLE: ${_notificationInfo!.title}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text("BODY: ${_notificationInfo!.body}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                        const SizedBox(height: 8),
                        Text(
                          "Name: ${_notificationInfo!.name ?? "No name"}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    )
                  : Container(),
              const SizedBox(height: 40),
              ElevatedButton(
                  child: const Text(
                    "Riverpod Demo",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RiverpodPage()),
                    );
                  }),
              ElevatedButton(
                  child: const Text(
                    "Connectivity_plus Demo",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ConnectivityPage()),
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}
