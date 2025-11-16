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
class MyHomePage extends StatefulWidget { const MyHomePage({super.key, required this.title}); final String title; @override State<MyHomePage> createState() => _MyHomePageState(); }
class _MyHomePageState extends State<MyHomePage> {
  int index = 0;
  Set<int> selectedProviders = {};  

  @override
  Widget build(BuildContext context) {
    final pages = [
      Channels(
        title: "Channels",
        selectedProviders: selectedProviders,
      ),
      ProviderPage(
        selectedProviders: selectedProviders,
        onSelectionChanged: (newSet) {
          setState(() {
            selectedProviders = newSet;
          });
        },
      ),
    ];

    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: "Guide"),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: "Guide"),
          BottomNavigationBarItem(icon: Icon(Icons.cable_rounded), label: "Providers"),
        ],
      ),
    );
  }
}

Future<List<Map<String, dynamic>>> fetchShows(
  int provider, 
  String? genre, 
  String? country, {
  int maxPages = 3, // number of pages to fetch per provider
}) async {
  List<Map<String, dynamic>> allShows = [];

  for (int page = 1; page <= maxPages; page++) {
    String url =
        'https://api.themoviedb.org/3/discover/tv?api_key=$apiKey&with_watch_providers=$provider&watch_region=US&page=$page';

    if (genre != null) url += '&with_genres=$genre';
    if (country != null) url += '&origin_country=$country';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List<dynamic>;
      final shows = results.map<Map<String, dynamic>>((show) {
        return {
          'title': show['name'] ?? show['title'],
          'runtime': (show['episode_run_time'] != null && show['episode_run_time'].length > 0)
              ? show['episode_run_time'][0]
              : Random().nextInt(30) + 20,
          'provider_number': provider,
          'provider': providertostring(provider),
          'genre': genre,
          'country': country,
        };
      }).toList();
      allShows.addAll(shows);
    }
  }

  allShows.shuffle(); // randomize order
  return allShows;
}

Future<Map<String, List<Map<String, dynamic>>>> getAllChannels(
  Set<int> selectedProviders,
) async {
  // 1. Genre definitions
  final Map<String, Map<String, String?>> genreMap = {
    //'kdrama':            { 'genre': '18',    'country': 'KR' }, //projectrose
    //'anime':             { 'genre': '16',    'country':  'JP' },
    'animation':         { 'genre': '16',    'country':  'US' },
    'comedy':            { 'genre': '35',    'country': 'US' }, //stnad up
    'sci-fi-fantasy':    { 'genre': '10765', 'country': 'US' }, // fantaverse
    'kids':              { 'genre': '10762', 'country': 'US' }, //bopple
    'documentary':       { 'genre': '99',    'country': 'US' }, //lenscape
    'drama':             { 'genre': '18',    'country': 'US' }, //velvet
    'mystery':           { 'genre': '9648',  'country': 'US' }, //ciphercast
    'reality-tv':        { 'genre': '10764', 'country': 'US' }, //mosaic
    'family':            { 'genre': '10751', 'country': 'US' }, //FamilyTV
    'soap':              { 'genre': '10766', 'country': 'US' }, //LatherLive
    //'music-vids':        { 'genre': '10402', 'country': 'US' }, //Wavenote
    'action-adventure':  { 'genre': '10759', 'country': 'US' }, //Cliffhanger
  };
  
  final Map<String, List<Map<String, dynamic>>> channels = {};

  for (var genreKey in genreMap.keys) {
    final genreData = genreMap[genreKey]!;
    final String? tmdbGenre = genreData['genre'];
    final String? country = genreData['country'];

    List<Map<String, dynamic>> channelShows = [];

    for (var provider in selectedProviders) {
      try {
        final shows = await fetchShows(provider, tmdbGenre, country);

        final filteredShows = shows.where((show) {
        if (genreKey == 'kids') return show['genre'] == tmdbGenre;
        if (genreKey == 'animation' || genreKey == 'anime') {
          return show['genre'] != '10762';
        }
        return true;
      }).toList();

        channelShows.addAll(filteredShows);
      } catch (e) {
        //print("Error fetching shows for $genreKey on provider $provider: $e");
      }
    }

    channelShows.shuffle(); 
    channels[genreKey] = channelShows;
  }

  return channels;
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
    const Channels(title: 'Channels', selectedProviders: {8, 10, 15, 337, 384, 531}), // Example with Netflix and Amazon Prime Video
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
  const Channels({super.key, required this.title, required this.selectedProviders});
  final String title;
  final Set<int> selectedProviders;

  @override
  State<Channels> createState() => ChannelsState();
}
class ChannelsState extends State<Channels> {
  late Future<Map<String, List<Map<String, dynamic>>>> guideByChannel;

  final Map<String, Color> providerColors = {
    'Netflix': Color.fromARGB(255, 109, 13, 10),
    'Amazon Prime Video': Color.fromARGB(255, 195, 169, 89),
    'Hulu': Color.fromARGB(255, 114, 157, 112),
    'Disney Plus': Color.fromARGB(255, 89, 137, 131),
    'HBO Max': Color.fromARGB(255, 82, 75, 112),
    'Paramount Plus': Color.fromARGB(255, 73, 98, 154),
    // Apple TV is excluded as it doesn't provide data
  };

  final Map<String, Color> providerText = {
    'Netflix': Color.fromARGB(255, 255, 255, 255),
    'Amazon Prime Video': Color.fromARGB(255, 100, 78, 13),
    'Hulu': Color.fromARGB(255, 38, 75, 61),
    'Disney Plus': Color.fromARGB(255, 45, 69, 66),
    'HBO Max': Color.fromARGB(255, 255, 255, 255),
    'Paramount Plus': Color.fromARGB(255, 255, 255, 255),
    // Apple TV is excluded as it doesn't provide data
  };

  @override
  void initState() {
    super.initState();
    guideByChannel = getAllChannels(widget.selectedProviders);

  }

  @override
  Widget build(BuildContext context) {
    // Access selectedProviders via widget.selectedProviders
    //return const MyNavScaffold();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: guideByChannel,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No channels available'));
          }
          final channels = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: channels.entries.map((channelEntry) {
            final channelName = channelEntry.key;
            final shows = channelEntry.value;

            return IntrinsicHeight(   // <-- makes children match tallest height
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.stretch, // <-- stretch children vertically
    children: [
      Container(
        width: 120,
        color: Colors.grey[300],
        padding: EdgeInsets.all(8),
        child: Text(
          channelName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      Expanded(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch, // <-- make blocks fill height
            children: shows.map((show) {
              final runtime = show['runtime'] as int;
              const double pixelsPerMinute = 4.0;
              final double width = runtime * pixelsPerMinute;

              final provider = show['provider'];  
              final Color blockColor = providerColors[provider] ?? Colors.grey;
              final Color myColor = providerText[provider] ?? Colors.black;
              
              return Container(
                width: width,
                margin: EdgeInsets.all(2),
                padding: EdgeInsets.all(8),
                color: blockColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      show['title'],
                      style: TextStyle(fontSize: 12, color: myColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${show['provider']}",
                      style: TextStyle(fontSize: 10, color: myColor),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    ],
  ),
);
          }).toList(),
        ),
      );
      },
    ),
    );
}
}


String providertostring(int providernum) {
  if(providernum == 8) {
    return 'Netflix';
  } else if(providernum == 10) {
    return 'Amazon Prime Video';
  } else if(providernum == 15) {
    return 'Hulu';
  } else if(providernum == 337) {
    return 'Disney Plus';
  }else if(providernum == 384) {
    return 'HBO Max';
  } else if(providernum == 531) {
    return 'Paramount Plus';
  }
  // appletv is a faker so it doesn't make the list (ㆆ_ㆆ)
   else {
    return 'Other';
  }
}


class ProviderPage extends StatelessWidget {
  final Set<int> selectedProviders;
  final ValueChanged<Set<int>> onSelectionChanged;
  
  ProviderPage({
    super.key,
    required this.selectedProviders,
    required this.onSelectionChanged,
  });

  final Map<int, String> providerMap = {
    8: 'Netflix',
    10: 'Amazon Prime Video',
    15: 'Hulu',
    337: 'Disney Plus',
    384: 'HBO Max',
    531: 'Paramount Plus',
    // Apple TV is excluded as it doesn't provide data
  };
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Providers")),
      body: ListView(
        children: providerMap.entries.map((entry) {
          final id = entry.key;
          final name = entry.value;

          return CheckboxListTile(
            title: Text(name),
            value: selectedProviders.contains(id),
            onChanged: (bool? check) {
              final newSet = Set<int>.from(selectedProviders);
              check == true ? newSet.add(id) : newSet.remove(id);
              onSelectionChanged(newSet);
            },
          );
        }).toList(),
      ),
    );
  }
}



//ITS OKAYYYY ദ്ദി(ᵔᗜᵔ) 