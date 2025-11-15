import 'package:flutter/material.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  @override
  Widget build(BuildContext context) {
    return const MyNavScaffold();
  }
}

class MyNavScaffold extends StatefulWidget {
  const MyNavScaffold({super.key});

  @override
  State<MyNavScaffold> createState() => _MyNavScaffoldState();
}
//hi
class _MyNavScaffoldState extends State<MyNavScaffold> {
  int _selectedIndex = 1;

  final List<IconData> _icons = [
    //Icons.source,
    //Icons.lightbulb,
    Icons.tv_rounded,
    Icons.my_library_books,
    Icons.star_border_purple500,
  ];

  final List<String> _labels = [
    'Channels',
    'Dewey',
    '~Ratings',
  ];

  final List<Widget> _pages = [
    //Placeholder(), // Not used, dummy
    const Channels(title: 'Channels'),
    Placeholder(),
    Placeholder(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }//ji

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: List.generate(_icons.length, (i) {
          return BottomNavigationBarItem(
            icon: Icon(_icons[i]),
            label: _labels[i],
          );
        }),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class Channels extends StatefulWidget {
  const Channels({super.key, required this.title});
  final String title;

  @override
  State<Channels> createState() => ChannelsState();
}

class ChannelsState extends State<Channels> {
  @override

  Widget build(BuildContext context) {
    //return const MyNavScaffold();
      return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ), 
      );
  }
}