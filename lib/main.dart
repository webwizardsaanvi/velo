import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
void main() {
  runApp(const MyApp());
}
const String apiKey = '739f363ec2d1c6f66f0c78bd7c267476';
const String geminiKey = 'AIzaSyBtLm3F8kcTZbsD_qYDXeZxdJh4J7KEcAI';
const String geminiendpoint = 'https://generativelanguage.googleapis.com/v1alpha/projects/103820697394/locations/global/models/gemini-2.5:predict';

const _apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: 'AIzaSyBtLm3F8kcTZbsD_qYDXeZxdJh4J7KEcAI');

final _model = GenerativeModel(
  model: 'gemini-2.5-flash',
  apiKey: _apiKey,
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
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
    return const MyNavScaffold();
  }
}

Future<List<Map<String, dynamic>>> fetchShows(
  int provider, 
  String? genre, 
  String? country, {
  int maxPages = 3, 
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
    'provider': provider, // store int only
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

  Set<int> _selectedProviders = {8, 10, 15, 337, 384, 531};

  void _onProvidersChanged(Set<int> newSet) {
    setState(() {
      _selectedProviders = newSet;
    });
  }

  final List<IconData> _icons = [
    //Icons.source,
    //Icons.lightbulb,
    Icons.tv_rounded,
    Icons.my_library_books,
    Icons.cable_rounded
  ];

  final List<String> _labels = [
    'Channels',
    'Dewey',
    'Providers'
  ];

  List<Widget> get _pages => [
    Channels(title: 'Channels', selectedProviders: _selectedProviders),
    const DeweyPage(),
    ProviderPage(selectedProviders: _selectedProviders, onSelectionChanged: _onProvidersChanged),
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
  State<Channels> createState() => _ChannelsState();
}

class _ChannelsState extends State<Channels> {
  late Future<Map<String, List<Map<String, dynamic>>>> guideByChannel;

  late LinkedScrollControllerGroup _controllers;
  late ScrollController _timeController;
  late ScrollController _showsController;

  final Map<String, Color> providerColors = {
    'Netflix': Color.fromARGB(255, 109, 13, 10),
    'Amazon Prime Video': Color.fromARGB(255, 195, 169, 89),
    'Hulu': Color.fromARGB(255, 114, 157, 112),
    'Disney Plus': Color.fromARGB(255, 89, 137, 131),
    'Paramount Plus': Color.fromARGB(255, 73, 98, 154),
  };

  final Map<String, Color> providerText = {
    'Netflix': Colors.white,
    'Amazon Prime Video': Color.fromARGB(255, 100, 78, 13),
    'Hulu': Color.fromARGB(255, 38, 75, 61),
    'Disney Plus': Color.fromARGB(255, 45, 69, 66),
    'Paramount Plus': Colors.white,
  };

  final Map<String, String> channelRename = {
    "animation": "Animax",
    "comedy": "Stand Up",
    "sci-fi-fantasy": "Fantaverse",
    "kids": "Bopple",
    "documentary": "Lenscope",
    "drama": "Velvet",
    "mystery": "Ciphercast",
    "reality-tv": "Mosaic",
    "family": "FamilyTV",
    "soap": "LatherLive",
    "action-adventure": "Cliffhanger",
  };

  final Map<String, IconData> channelIcons = {
    "animation": Icons.catching_pokemon,
    "comedy": Icons.tag_faces,
    "sci-fi-fantasy": Icons.rocket_launch,
    "kids": Icons.child_care_sharp,
    "documentary": Icons.camera,
    "drama": Icons.theater_comedy,
    "mystery": Icons.fingerprint,
    "reality-tv": Icons.chair_rounded,
    "family": Icons.diversity_1,
    "soap": Icons.follow_the_signs_rounded,
    "action-adventure": Icons.directions_run,
  };

  @override
  void initState() {
    super.initState();
    _controllers = LinkedScrollControllerGroup();
    _timeController = _controllers.addAndGet();
    _showsController = _controllers.addAndGet();
    guideByChannel = getAllChannels(widget.selectedProviders);
  }

  @override
  void dispose() {
    _timeController.dispose();
    _showsController.dispose();
    super.dispose();
  }

  Widget buildTimeRow() {
    final times = [
      "12:00","12:30","1:00","1:30","2:00","2:30","3:00","3:30",
      "4:00","4:30","5:00","5:30","6:00","6:30","7:00","7:30",
      "8:00","8:30","9:00","9:30","10:00","10:30","11:00","11:30"
    ];

    return Container(
      color: Color.fromRGBO(79, 77, 74, 1),
      height: 40,
      child: SingleChildScrollView(
        controller: _timeController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: times.map((t) => Container(
            width: 120,
            alignment: Alignment.center,
            child: Text(t, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EDE9),
      body: Container( decoration: BoxDecoration( image: DecorationImage( image: AssetImage("assets/velobg.png") ), ),
        child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1100),
          child: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
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
              return Column(
                children: [
                  SizedBox(height: 120),
                  buildTimeRow(),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: channels.entries.map((entry) {
                        final rawChannelName = entry.key;
                        final channelName = channelRename[rawChannelName] ?? rawChannelName;
                        final shows = entry.value;
                        final channelIcon = channelIcons[rawChannelName];

                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                width: 120,
                                color: Color.fromARGB(255, 101, 99, 96),
                                padding: EdgeInsets.all(8),
                                child: Row(
                                  children: [
                                    Icon(channelIcon, size: 20, color: Colors.white),
                                    SizedBox(width: 6),
                                    Expanded(child: Text(channelName, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  controller: _showsController,
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: shows.map((show) {
                                      final runtime = show['runtime'] is int ? show['runtime'] as int : 30;
                                      final double width = runtime * 4.0;

                                      final providerNum = show['provider'] as int;
final providerName = providertostring(providerNum);
final Color blockColor = providerColors[providerName] ?? Colors.grey;
final Color textColor = providerText[providerName] ?? Colors.black;

                                      return Container(
                                        width: width,
                                        margin: EdgeInsets.all(2),
                                        padding: EdgeInsets.all(8),
                                        color: blockColor,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(show['title'], style: TextStyle(fontSize: 12, color: textColor), overflow: TextOverflow.ellipsis),
                                            Text(providerName, style: TextStyle(fontSize: 10, color: textColor)),
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
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ));
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
  }else if(providernum == 531) {
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
    531: 'Paramount Plus',
  };
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EDE9),
      
      body: Container(
      
      child: ListView(
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
    )
    );
  }
}


class DeweyPage extends StatefulWidget {
  const DeweyPage({super.key});
@override
  State<DeweyPage> createState() => _DeweyPageState();
}

class _Message {
  final String content;
  final bool isUser;

  _Message({required this.content, required this.isUser});
}

class _DeweyPageState extends State<DeweyPage> {
  final TextEditingController _controller = TextEditingController();
  final List<_Message> _messages = [];

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    if (_apiKey.isEmpty && _messages.isEmpty) {
      _messages.add(_Message(
          content: '⚠️ Error: GEMINI_API_KEY is not set or defaulted. Please check configuration.',
          isUser: false));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Dewey')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              key: ValueKey(_messages.length), 
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: message.isUser ? Colors.blue : Colors.grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      message.content,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ask Dewey...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _isLoading || _apiKey.isEmpty ? null : _sendMessage, 
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading || _apiKey.isEmpty ? null : () => _sendMessage(_controller.text),
                  child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                      : const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Future<void> _sendMessage(String message) async {
    if (message.isEmpty || _apiKey.isEmpty) return;

    setState(() {
      _isLoading = true;
      _messages.add(_Message(content: message, isUser: true));
      _controller.clear();
    });

    const systemInstruction = 
      "Your name is Dewey (short for Dewey Decimal). Basically, you are a helpful librarian/friend who helps people with book recommendations, finding books, and general book-related inquiries. You also have a great list of movies and TV shows to recommend, but you make sure you know what someone wants before spiraling off on a tangent. You are friendly, knowledgeable, and always eager to assist users in discovering new books and authors based on their interests. ";

    final fullPrompt = "$systemInstruction\n\nUser Question: $message";
    
    print('Sending prompt of ${fullPrompt.length} characters...');

    try {
      final response = await _model.generateContent(
        [Content.text(fullPrompt)], 
      );

      final geminiReply = response.text ?? 'Hmm… I couldn’t find an answer.';
      print('Received reply: ${geminiReply.substring(0, min(50, geminiReply.length))}...');

      setState(() {
        _messages.add(_Message(content: geminiReply, isUser: false));
      });

    } catch (e) {
      //print('GEMINI API Request Failed with Exception: $e');
      setState(() {
        _messages.add(_Message(content: 'Request failed: $e', isUser: false));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
//ITS OKAYYYY ദ്ദി(ᵔᗜᵔ) 
// YOU CAN DO ITTTT
// I BELIEVE IN YOUUUU
//use this to run: flutter run --dart-define="GEMINI_API_KEY=AIzaSyBtLm3F8kcTZbsD_qYDXeZxdJh4J7KEcAI"