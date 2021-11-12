import 'package:flutter/material.dart';

class AndroidApp extends StatelessWidget {
  const AndroidApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Vault of Games',
        theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: const _AuthenticationScreen(),
      );
}

class _AuthenticationScreen extends StatefulWidget {
  const _AuthenticationScreen({Key? key}) : super(key: key);

  @override
  State<_AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<_AuthenticationScreen> {
  final formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isSigningIn = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Authentication'),
        ),
        body: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    keyboardType: TextInputType.name,
                    controller: usernameController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      labelText: 'Username',
                      hintText: 'Enter the username',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please provide a valid user ID'
                        : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    controller: passwordController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.password),
                      labelText: 'Password',
                      hintText: 'Enter the password',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please provide a valid password'
                        : null,
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                isSigningIn
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      )
                    : SizedBox(
                        width: MediaQuery.of(context).size.width / 3,
                        child: ElevatedButton(
                          onPressed: () async {
                            setState(() => isSigningIn = true);

                            await Future.delayed(
                              const Duration(seconds: 2),
                              () {
                                if (formKey.currentState!.validate()) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) => const _HomeScreen(),
                                    ),
                                    (_) => false,
                                  );
                                } else {
                                  setState(() => isSigningIn = false);
                                }
                              },
                            );
                          },
                          child: const Text('Sign In'),
                        ),
                      ),
              ],
            ),
          ),
        ),
      );
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Vault of Games'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const _GameStoreScreen(),
            ),
          ),
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 10,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: const [
                    _GameTile(
                      imageUrl:
                          'https://i0.wp.com/images.wikia.com/dragonage/images/archive/3/3f/20101025011318!Portal_dragon_age.png',
                      title: 'Dragon Age: Origins',
                      rating: '★★★★★★★★★★',
                      status: 'Completed',
                    ),
                    Divider(),
                    _GameTile(
                      imageUrl:
                          'https://www.mobygames.com/images/covers/l/686749-genshin-impact-playstation-4-front-cover.jpg',
                      title: 'Genshin Impact',
                      status: 'Untouched',
                    ),
                    Divider(),
                    _GameTile(
                      imageUrl:
                          'https://tinfoil.media/i/010076D00E4BA000/0/0/f552bd1b46e33fd50e56ed473e6fddf627514320616d01b888d91e26a3f264c5',
                      title: 'Risk of Rain',
                      rating: '★★★★★★★★☆☆',
                      status: 'Played',
                    ),
                    Divider(),
                    _GameTile(
                      imageUrl:
                          'https://game-ost.com/static/covers_soundtracks/7/9/7925_691082.jpg',
                      title: 'Mass Effect',
                      rating: '★★★★★★★★★☆',
                      status: 'Completed',
                    ),
                    Divider(),
                    _GameTile(
                      imageUrl:
                          'https://espadaserver.ru/uploads/posts/2018-10/1539418245_csgo.jpg',
                      title: 'Counter-Strike: Global Offensive',
                      rating: '★★★★★★★☆☆☆',
                      status: 'Played',
                    ),
                    Divider(),
                    _GameTile(
                      imageUrl:
                          'https://assets-prd.ignimgs.com/2020/12/15/among-us-button-fin-1608054673652.jpg',
                      title: 'Among Us',
                      status: 'Played',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

class _GameTile extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String? rating;
  final String status;

  const _GameTile({
    Key? key,
    required this.imageUrl,
    required this.title,
    this.rating,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 100,
        width: double.infinity,
        child: Material(
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => _GameDetailsScreen(
                  imageUrl: imageUrl,
                  title: title,
                  rating: rating,
                  status: status,
                ),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: ColorFiltered(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.fill,
                    ),
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.dstATop,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                rating ?? 'Unrated',
                                style: TextStyle(
                                  fontStyle: rating != null
                                      ? FontStyle.normal
                                      : FontStyle.italic,
                                  fontSize: 20,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.bold,
                                  color: rating != null
                                      ? Colors.yellow[800]
                                      : Colors.grey,
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: 'Status: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(text: status),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _GameStoreScreen extends StatelessWidget {
  const _GameStoreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Store Game'),
        ),
        body: const _GameStoreForm(),
      );
}

class _GameStoreForm extends StatefulWidget {
  const _GameStoreForm({
    Key? key,
  }) : super(key: key);

  @override
  State<_GameStoreForm> createState() => _GameStoreFormState();
}

class _GameStoreFormState extends State<_GameStoreForm> {
  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final imageUrlController = TextEditingController();
  final categoryController = TextEditingController();
  final noteController = TextEditingController();

  String? status;

  int rating = 0;

  @override
  void dispose() {
    titleController.dispose();
    imageUrlController.dispose();
    categoryController.dispose();
    noteController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    keyboardType: TextInputType.name,
                    controller: titleController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.title),
                      labelText: 'Title',
                      hintText: 'Enter the title',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please provide a valid title'
                        : null,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Status'),
                    const SizedBox(width: 24),
                    DropdownButton<String>(
                      hint: const Text('Status'),
                      value: status,
                      items: const <DropdownMenuItem<String>>[
                        DropdownMenuItem(
                          value: 'untouched',
                          child: Text('Untouched'),
                        ),
                        DropdownMenuItem(
                          value: 'played',
                          child: Text('Played'),
                        ),
                        DropdownMenuItem(
                          value: 'completed',
                          child: Text('Completed'),
                        ),
                      ],
                      onChanged: (value) => setState(() => status = value!),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    keyboardType: TextInputType.url,
                    controller: imageUrlController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.link),
                      labelText: 'Image URL',
                      hintText: 'Image URL',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) => value == null
                        ? 'Please provide a valid image URL'
                        : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: categoryController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.category),
                      labelText: 'Category',
                      hintText: 'Action; Adventure; RPG',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) => value == null
                        ? 'Please provide a valid category'
                        : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Rating: $rating/10',
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Slider(
                    label: rating.toString(),
                    value: rating.toDouble(),
                    max: 10,
                    divisions: 10,
                    onChanged: (value) =>
                        setState(() => rating = value.toInt()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    controller: noteController,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      labelText: 'Note',
                      alignLabelWithHint: true,
                      hintText: 'An unforgettable experience.',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        value == null ? 'Please provide a note' : null,
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: ElevatedButton(
                    child: const Text('Submit'),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Store the game in the vault?'),
                        actions: [
                          TextButton(
                            child: const Text('No'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          TextButton(
                            child: const Text('Yes'),
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                Navigator.of(context)
                                  ..pop()
                                  ..pop();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _GameDetailsScreen extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String? rating;
  final String status;

  const _GameDetailsScreen({
    Key? key,
    required this.imageUrl,
    required this.title,
    this.rating,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Game Details'),
          actions: [
            IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => _GameEditScreen(
                    imageUrl: imageUrl,
                    title: title,
                    rating: rating,
                    status: status,
                  ),
                ),
              ),
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              onPressed: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete game?'),
                  actions: [
                    TextButton(
                      child: const Text('No'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: const Text(
                        'Yes',
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () => Navigator.of(context)
                        ..pop()
                        ..pop(),
                    ),
                  ],
                ),
              ),
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
            ),
          ],
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: SizedBox.square(
                child: Image.network(imageUrl),
                dimension: 300,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                rating ?? 'Unrated',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontStyle:
                      rating != null ? FontStyle.normal : FontStyle.italic,
                  fontSize: 28,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                  color: rating != null ? Colors.yellow[800] : Colors.grey,
                ),
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
                children: [
                  const TextSpan(
                    text: 'Status: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: status),
                ],
              ),
            ),
          ],
        ),
      );
}

class _GameEditScreen extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String? rating;
  final String status;

  const _GameEditScreen({
    Key? key,
    required this.imageUrl,
    required this.title,
    this.rating,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Edit Game'),
        ),
        body: _GameEditForm(
          imageUrl: imageUrl,
          title: title,
          rating: rating,
          status: status,
        ),
      );
}

class _GameEditForm extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String? rating;
  final String status;

  const _GameEditForm({
    Key? key,
    required this.imageUrl,
    required this.title,
    this.rating,
    required this.status,
  }) : super(key: key);

  @override
  State<_GameEditForm> createState() => _GameEditFormState();
}

class _GameEditFormState extends State<_GameEditForm> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController titleController;
  late final TextEditingController imageUrlController;
  late final TextEditingController categoryController;
  late final TextEditingController noteController;

  String? status;

  int rating = 0;

  @override
  void initState() {
    if (widget.rating != null) {
      final starCount = '★'.allMatches(widget.rating!).length;

      rating = starCount;
    }

    titleController = TextEditingController(text: widget.title);
    imageUrlController = TextEditingController(text: widget.imageUrl);
    categoryController = TextEditingController();
    noteController = TextEditingController();

    status = widget.status.toLowerCase();

    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    imageUrlController.dispose();
    categoryController.dispose();
    noteController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    keyboardType: TextInputType.name,
                    controller: titleController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.title),
                      labelText: 'Title',
                      hintText: 'Enter the title',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please provide a valid title'
                        : null,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Status'),
                    const SizedBox(width: 24),
                    DropdownButton<String>(
                      hint: const Text('Status'),
                      value: status,
                      items: const <DropdownMenuItem<String>>[
                        DropdownMenuItem(
                          value: 'untouched',
                          child: Text('Untouched'),
                        ),
                        DropdownMenuItem(
                          value: 'played',
                          child: Text('Played'),
                        ),
                        DropdownMenuItem(
                          value: 'completed',
                          child: Text('Completed'),
                        ),
                      ],
                      onChanged: (value) => setState(() => status = value!),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    keyboardType: TextInputType.url,
                    controller: imageUrlController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.link),
                      labelText: 'Image URL',
                      hintText: 'Image URL',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) => value == null
                        ? 'Please provide a valid image URL'
                        : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: categoryController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.category),
                      labelText: 'Category',
                      hintText: 'Action; Adventure; RPG',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) => value == null
                        ? 'Please provide a valid category'
                        : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Rating: $rating/10',
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Slider(
                    label: rating.toString(),
                    value: rating.toDouble(),
                    max: 10,
                    divisions: 10,
                    onChanged: (value) =>
                        setState(() => rating = value.toInt()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    controller: noteController,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      labelText: 'Note',
                      alignLabelWithHint: true,
                      hintText: 'An unforgettable experience.',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        value == null ? 'Please provide a note' : null,
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: ElevatedButton(
                    child: const Text('Submit'),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Store the game in the vault?'),
                        actions: [
                          TextButton(
                            child: const Text('No'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          TextButton(
                            child: const Text('Yes'),
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                Navigator.of(context)
                                  ..pop()
                                  ..pop()
                                  ..pop();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
