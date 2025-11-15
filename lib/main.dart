import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
void main() {
  runApp(const MyApp());
}
const String apiKey = '739f363ec2d1c6f66f0c78bd7c267476';
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

Future<List<Map<String, dynamic>>> fetchShows(int provider, String? genre, String? country) async{
  final page = Random().nextInt(5) + 1;
  
  String url = 'https://api.themoviedb.org/3/discover/tv?api_key=$apiKey&with_watch_providers=$provider&watch_region=US&page=$page';
  
  if(genre != null){
    url += '&with_genres=$genre';
  }
  if(country != null){
    url += '&origin_country=$country';
  }
  final response = await http.get(Uri.parse(url));
  
  if(response.statusCode == 200){
    final data = jsonDecode(response.body);
    return data['results'].map<Map<String, dynamic>>((show) => {'title': show['name'] ?? show['title'], 'runtime': (show['episode_run_time'] != null && show['episode_run_time'].length > 0) ? show['episode_run_time'][0] : Random().nextInt(30) + 20, 'provider_number': provider, 'provider': providertostring(provider), 'genre': genre, 'country': country}).toList();

  }
  return [];
}

Future<Map<String, List<Map<String, dynamic>>>> getAllChannels() async{{
  Map<String, List<Map<String, dynamic>>> channels = {};
  for (var genre in selectedProviders){
    String? tmdbg;
    String? country;
    if (genre == 'kdrama') {
      country = 'KR';
      tmdbg = '18';
    }
    else if (genre == 'animation'){
       tmdbg = '16';
       }
    else if (genre == 'comedy'){tmdbg = '35';} //Stand Up
    else if (genre == 'sci-fi-fantasy'){tmdbg = '10765';} //Fantaverse
    else if (genre == 'kids'){tmdbg = '10762';} //Bopple
    else if (genre == 'documentary'){tmdbg = '99';} //lenscape
    else if (genre == 'drama'){tmdbg = '18';} //Velvet
    else if (genre == 'horror'){tmdbg = '27';} // Frightline
    else if (genre == 'mystery'){tmdbg = '9648';} //CipherCast
    else if (genre == 'reality-tv'){tmdbg = '10764';} //Mosaic
    else if (genre == 'romance'){tmdbg = '10749';} //Rose
    else if (genre == 'family'){tmdbg = '10751';} //FamilyTV
    else if (genre == 'soap'){tmdbg = '10766';} //LatherLive
    else if (genre == 'music-vids'){tmdbg = '10402';} //Wavenote
    else if (genre == 'action-adventure'){tmdbg = '10759';} //Cliffhanger
    List<Map<String, dynamic>> channelShows = [];
    for (var provider in selectedProviders){
      final shows = await fetchShows(provider, tmdbg, country);
      channelShows.addAll(shows);
    }
    channels[genre] = channelShows;
  }
  return channels;
}}

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
    Icons.cable_rounded
  ];

  final List<String> _labels = [
    'Channels',
    'Dewey',
    '~Ratings',
    'Providers'
  ];

  final List<Widget> _pages = [
    //Placeholder(), // Not used, dummy
    const Channels(title: 'Channels'),
    Placeholder(),
    Placeholder(),
    Placeholder()
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
      body: SingleChildScrollView(
        child: Column(
          children: guideByChannel.entries.map((channelEntry) {
            final channelName = channelEntry.key;
            final shows = channelEntry.value;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Container(
                width: 120,
                color: Colors.grey[300],
                padding: EdgeInsets.all(8),
                child: Text(
                  channelName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              
              Expanded(
                child:SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: shows.map((show) {
                      final runtime = show['runtime'] as int;
                      const double pixelsPerMinute = 4.0;
                      final double width = runtime * pixelsPerMinute;
                      
                      return Container(
                        width: width
                      )
                    })
              )
                
        ),
        ),

      ),
    );
  }
} 
String providertostring(int providernum) {
  if(providernum == 8) {
    return 'Netflix';
  } else if(providernum == 119) {
    return 'Amazon Prime Video';
  } else if(providernum == 15) {
    return 'Hulu';
  } else if(providernum == 9) {
    return 'Disney Plus';
  }else if(providernum == 384) {
    return 'HBO Max';
  } else if(providernum == 531) {
    return 'Paramount Plus';
  } else if(providernum == 192) {
    return 'Youtube';
  }
  // appletv is a faker so it doesn't make the list (ㆆ_ㆆ)
   else {
    return 'Other';
  }
  
}
//ITS OKAYYYY ദ്ദി(ᵔᗜᵔ) 