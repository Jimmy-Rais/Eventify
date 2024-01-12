import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:restart_app/restart_app.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(QRCodeScannerApp());
}

class QRCodeScannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: QRScanScreen(),
    );
  }
}

class QRScanScreen extends StatefulWidget {
  @override
  _QRScanScreenState createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  DatabaseReference Ticket00 =
      FirebaseDatabase.instance.reference().child('TICKET 00');
  DatabaseReference Ticket01 =
      FirebaseDatabase.instance.reference().child('TICKET 01');
  DatabaseReference Ticket02 =
      FirebaseDatabase.instance.reference().child('TICKET 02');
  DatabaseReference Ticket03 =
      FirebaseDatabase.instance.reference().child('TICKET 03');
  DatabaseReference Ticket04 =
      FirebaseDatabase.instance.reference().child('TICKET 04');
  DatabaseReference Ticket05 =
      FirebaseDatabase.instance.reference().child('TICKET 05');

  int TICKET00 = 0;
  int TICKET01 = 0;
  int TICKET02 = 0;
  int TICKET03 = 0;
  int TICKET04 = 0;
  int TICKET05 = 0;
  Color ticketColor00 = Colors.white;
  Color ticketColor01 = Colors.white;
  Color ticketColor02 = Colors.white;
  Color ticketColor03 = Colors.white;
  Color ticketColor04 = Colors.white;
  Color ticketColor05 = Colors.white;
  late QRViewController _controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String qrText = '';
  int count = 1000;
  bool ticketScanned = false;
  AudioCache audioCache = AudioCache();
  StreamSubscription<DatabaseEvent>? _subscription;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void initState() {
    super.initState();
    _loadTICKET();
    // _onQRViewCreated(_controller);
  }

  Widget buildTicketListTile(String ticketName, int ticketValue, Color ticketColor) {
    return ListTile(
      title: Row(
        children: [
          Icon(
            Icons.lens,
            color: Colors.black,
            size: 12,
          ),
          SizedBox(width: 5),
          Text('$ticketName: '),
          Icon(
            Icons.check_circle,
            color: ticketColor,
            size: 18,
          ),
        ],
      ),
      onTap: () {
        // Navigate to the settings screen or perform an action
        // Closes the drawer
        _loadTICKET();
      },
    );
  }

  _loadTICKET() async {
    DatabaseEvent event0 = await Ticket00.once();
    DatabaseEvent event1 = await Ticket01.once();
    DatabaseEvent event2 = await Ticket02.once();
    DatabaseEvent event3 = await Ticket03.once();
    DatabaseEvent event4 = await Ticket04.once();
    DatabaseEvent event5 = await Ticket05.once();
    if (event0.snapshot.value != null &&
        event1.snapshot.value != null &&
        event2.snapshot.value != null &&
        event3.snapshot.value != null &&
        event4.snapshot.value != null &&
        event5.snapshot.value != null) {
      int? parsedValue00 = int.tryParse(event0.snapshot.value.toString());
      int? parsedValue01 = int.tryParse(event1.snapshot.value.toString());
      int? parsedValue02 = int.tryParse(event2.snapshot.value.toString());
      int? parsedValue03 = int.tryParse(event3.snapshot.value.toString());
      int? parsedValue04 = int.tryParse(event4.snapshot.value.toString());
      int? parsedValue05 = int.tryParse(event5.snapshot.value.toString());
      setState(() {
        TICKET00 = parsedValue00!;
        TICKET01 = parsedValue01!;
        TICKET02 = parsedValue02!;
        TICKET03 = parsedValue03!;
        TICKET04 = parsedValue04!;
        TICKET05 = parsedValue05!;
        ticketColor00 = parsedValue00 == 1 ? Colors.green : Colors.white;
        ticketColor01 = parsedValue01 == 1 ? Colors.green : Colors.white;
        ticketColor02 = parsedValue02 == 1 ? Colors.green : Colors.white;
        ticketColor03 = parsedValue03 == 1 ? Colors.green : Colors.white;
        ticketColor04 = parsedValue04 == 1 ? Colors.green : Colors.white;
        ticketColor05 = parsedValue05 == 1 ? Colors.green : Colors.white;
      });
    }
  }

  void _handleSubscription(DatabaseReference ref) {
    _subscription = ref.onValue.listen((event) {
      if (event.snapshot.value == 1) {
        // Ticket has already been scanned, handle this case
        print('This ticket has already been scanned');
        setState(() {
          ticketScanned = true;
          qrText = "This ticket has already been scanned";
        });
      } else {
        // Set the new value in the database
        ref.set(1).then((_) {
          // Or set the desired value
          _subscription?.cancel(); // Cancel the subscription to exit the loop
        });
      }
    });
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      ticketScanned = false;
      _controller = controller;
      _controller.scannedDataStream.listen((scanData) {
        qrText = scanData.code.toString();
        if (qrText != null && qrText.length >= 2) {
          String lastTwoDigits = qrText.substring(qrText.length - 2);
          if (RegExp(r'^\d{2}$').hasMatch(lastTwoDigits)) {
            count = int.parse(lastTwoDigits);
            print('Extracted count: $count');
            // 'count' contains the extracted two-digit integer
            /*DatabaseReference ref =
                FirebaseDatabase.instance.reference().child('TICKET $count');
            ref.onValue.listen((event) {
              if (event.snapshot.value == 1) {
                // Ticket has already been scanned, handle this case
                print('This ticket has already been scanned');
              } else {
                // Set the new value in the database
                //ref.set(1); // Or set the desired value
              }
            });*/
          }
        }
      });
    });
  }

  Future<void> _updateFirebaseDatabase(int count) async {
    final database = FirebaseDatabase.instance;
    final ref = database.reference().child('TICKET $count');
    await ref.set(1);
    // Replace with your desired update operation
  }
  /*void _playSound() async {
    final player = AudioPlayer();
    await player
        .play(AssetSource('assets/ring.m4a')); // Replace with your audio file
  }*/

  void _onPressed() {
    setState(() {
      _controller.resumeCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: AppBar(
            title: DefaultTextStyle(
              style: GoogleFonts.acme(
                color: Colors.white,
                fontSize: 16,
              ),
              child: AnimatedTextKit(
                animatedTexts: [
                  ScaleAnimatedText('K2A Revival',
                      textStyle: GoogleFonts.acme(
                        fontSize: 16,
                      )),
                  ScaleAnimatedText('K2A Revival'),
                  ScaleAnimatedText('K2A Revival'),
                ],
                onTap: () {
                  print("Tap Event");
                },
                repeatForever: true,
              ),
            ),
            backgroundColor: Color.fromARGB(0, 66, 66, 66),
          )),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            /* DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Drawer Header',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),*/
            Container(
              height: 50,
            ),
            ListTile(
              leading: Icon(Icons.refresh),
              title: Text('Refresh'),
              onTap: () {
                _loadTICKET();
              }),
            buildTicketListTile('TICKET 00', TICKET00, ticketColor00),
            buildTicketListTile('TICKET 01', TICKET01, ticketColor01),
            buildTicketListTile('TICKET 02', TICKET02, ticketColor02),
            buildTicketListTile('TICKET 03', TICKET03, ticketColor03),
            buildTicketListTile('TICKET 04', TICKET04, ticketColor04),
            buildTicketListTile('TICKET 05', TICKET05, ticketColor05),
            // Add more ListTiles for additional items in the drawer
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor:
            ticketScanned ? const Color.fromRGBO(244, 67, 54, 1) : Colors.blue,
        child: Icon(Icons.send),
        onPressed: () async {
          DatabaseReference ref =
              FirebaseDatabase.instance.reference().child('TICKET $count');
          _handleSubscription(ref);

          setState(() {
            qrText = '';
          });
          await _updateFirebaseDatabase(count);
          // Clear the scanned text after sending
        },
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _onPressed,
                  style: ElevatedButton.styleFrom(
                    primary:
                        Color.fromARGB(137, 172, 198, 210), // Background color
                    padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15), // Padding around the text
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                    ),
                  ),
                  child: Text('Scan QR Code',
                      style: GoogleFonts.acme(
                        fontSize: 16,
                      )),
                ),
                SizedBox(height: 20),
                Text('$qrText',
                    style: GoogleFonts.acme(fontSize: 14, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

