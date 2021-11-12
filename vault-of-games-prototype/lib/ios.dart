import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// ignore: camel_case_types
class iOSApp extends StatelessWidget {
  const iOSApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const CupertinoApp(
        title: 'Vault of Games',
        debugShowCheckedModeBanner: false,
        home: _AuthenticationScreen(),
      );
}

class _AuthenticationScreen extends StatefulWidget {
  const _AuthenticationScreen({Key? key}) : super(key: key);

  @override
  State<_AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<_AuthenticationScreen> {
  bool isSigningIn = false;

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Authentication'),
        ),
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoFormSection(
                header: const Text('Authentication Credentials'),
                children: [
                  CupertinoTextFormFieldRow(
                    prefix: const Icon(CupertinoIcons.person),
                    placeholder: 'Username',
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                  ),
                  CupertinoTextFormFieldRow(
                    prefix: const Icon(CupertinoIcons.padlock),
                    placeholder: 'Password',
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                  ),
                ],
              ),
              isSigningIn
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: CupertinoActivityIndicator(),
                    )
                  : CupertinoButton(
                      child: const Text('Sign In'),
                      onPressed: () async {
                        setState(() => isSigningIn = true);

                        await Future.delayed(
                          const Duration(seconds: 2),
                          () {
                            setState(() => isSigningIn = true);

                            Navigator.of(context).pushAndRemoveUntil(
                              CupertinoPageRoute(
                                builder: (context) => const _HomeScreen(),
                              ),
                              (_) => false,
                            );
                          },
                        );
                      },
                    ),
            ],
          ),
        ),
      );
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Vault of Games'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => const _GameStoreScreen(),
              ),
            ),
            child: const Icon(CupertinoIcons.plus),
          ),
        ),
        child: Column(
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
              CupertinoPageRoute(
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
                                      color: Colors.black,
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
  Widget build(BuildContext context) => const CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Store Game'),
        ),
        child: _GameStoreForm(),
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
  int rating = 0;

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          CupertinoFormSection(
            header: const Text('Core Details'),
            children: [
              CupertinoTextFormFieldRow(
                prefix: const Icon(Icons.title),
                placeholder: 'Title',
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
              ),
            ],
          ),
          DefaultTextStyle(
            style: TextStyle(
              fontSize: 13.0,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
            child: const Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                20.0,
                16.0,
                20.0,
                10.0,
              ),
              child: Text(
                'Status',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CupertinoSlidingSegmentedControl(
              children: const {
                'untouched': Text('Untouched'),
                'played': Text('Played'),
                'completed': Text('Completed'),
              },
              onValueChanged: print,
            ),
          ),
          const SizedBox(height: 16),
          CupertinoFormSection(
            header: const Text('Optional Details'),
            children: [
              CupertinoTextFormFieldRow(
                prefix: const Icon(Icons.link),
                placeholder: 'Image URL',
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
              ),
              CupertinoTextFormFieldRow(
                prefix: const Icon(Icons.category),
                placeholder: 'Action; Adventure; RPG',
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
              ),
            ],
          ),
          DefaultTextStyle(
            style: TextStyle(
              fontSize: 13.0,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                20.0,
                16.0,
                20.0,
                10.0,
              ),
              child: Text(
                'Rating: $rating/10',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CupertinoSlider(
              value: rating.toDouble(),
              max: 10,
              divisions: 10,
              onChanged: (value) => setState(() => rating = value.toInt()),
            ),
          ),
          DefaultTextStyle(
            style: TextStyle(
              fontSize: 13.0,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
            child: const Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                20.0,
                16.0,
                20.0,
                10.0,
              ),
              child: Text(
                'Note',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          CupertinoTextFormFieldRow(
            placeholder: 'An unforgettable experience.',
            maxLines: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: CupertinoColors.extraLightBackgroundGray,
            ),
            keyboardType: TextInputType.multiline,
          ),
          CupertinoButton(
            child: const Text('Submit'),
            onPressed: () => showCupertinoDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                title: const Text('Store the game in the vault?'),
                actions: [
                  CupertinoButton(
                    child: const Text('No'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    child: const Text('Yes'),
                    onPressed: () => Navigator.of(context)
                      ..pop()
                      ..pop(),
                  ),
                ],
              ),
            ),
          ),
        ],
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
  Widget build(BuildContext context) => CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Game Details'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => showCupertinoModalPopup(
              context: context,
              builder: (context) => CupertinoActionSheet(
                title: const Text('Actions'),
                actions: [
                  CupertinoActionSheetAction(
                    child: const Text('Edit'),
                    onPressed: () => showCupertinoModalBottomSheet(
                      context: context,
                      builder: (context) => _GameEditScreen(
                        imageUrl: imageUrl,
                        title: title,
                        rating: rating,
                        status: status,
                      ),
                    ),
                  ),
                  CupertinoActionSheetAction(
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () => showCupertinoDialog(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: const Text('Delete game?'),
                        actions: [
                          CupertinoButton(
                            child: const Text('No'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          CupertinoButton(
                            child: const Text(
                              'Yes',
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () => Navigator.of(context)
                              ..pop()
                              ..pop()
                              ..pop(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            child: const Icon(CupertinoIcons.gear),
          ),
        ),
        child: ListView(
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
                  color: Colors.black,
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
  Widget build(BuildContext context) => CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Edit Game'),
        ),
        child: _GameEditForm(
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
  late int rating = 0;

  @override
  void initState() {
    if (widget.rating != null) {
      final starCount = '★'.allMatches(widget.rating!).length;

      rating = starCount;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          CupertinoFormSection(
            header: const Text('Core Details'),
            children: [
              CupertinoTextFormFieldRow(
                initialValue: widget.title,
                prefix: const Icon(Icons.title),
                placeholder: 'Title',
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
              ),
            ],
          ),
          DefaultTextStyle(
            style: TextStyle(
              fontSize: 13.0,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
            child: const Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                20.0,
                16.0,
                20.0,
                10.0,
              ),
              child: Text(
                'Status',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CupertinoSlidingSegmentedControl(
              groupValue: widget.status.toLowerCase(),
              children: const {
                'untouched': Text('Untouched'),
                'played': Text('Played'),
                'completed': Text('Completed'),
              },
              onValueChanged: print,
            ),
          ),
          const SizedBox(height: 16),
          CupertinoFormSection(
            header: const Text('Optional Details'),
            children: [
              CupertinoTextFormFieldRow(
                initialValue: widget.imageUrl,
                prefix: const Icon(Icons.link),
                placeholder: 'Image URL',
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
              ),
              CupertinoTextFormFieldRow(
                prefix: const Icon(Icons.category),
                placeholder: 'Action; Adventure; RPG',
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
              ),
            ],
          ),
          DefaultTextStyle(
            style: TextStyle(
              fontSize: 13.0,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                20.0,
                16.0,
                20.0,
                10.0,
              ),
              child: Text(
                'Rating: $rating/10',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CupertinoSlider(
              value: rating.toDouble(),
              max: 10,
              divisions: 10,
              onChanged: (value) => setState(() => rating = value.toInt()),
            ),
          ),
          DefaultTextStyle(
            style: TextStyle(
              fontSize: 13.0,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
            child: const Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                20.0,
                16.0,
                20.0,
                10.0,
              ),
              child: Text(
                'Note',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          CupertinoTextFormFieldRow(
            placeholder: 'An unforgettable experience.',
            maxLines: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: CupertinoColors.extraLightBackgroundGray,
            ),
            keyboardType: TextInputType.multiline,
          ),
          CupertinoButton(
            child: const Text('Submit'),
            onPressed: () => showCupertinoDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                title: const Text('Store the game in the vault?'),
                actions: [
                  CupertinoButton(
                    child: const Text('No'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    child: const Text('Yes'),
                    onPressed: () => Navigator.of(context)
                      ..pop()
                      ..pop()
                      ..pop(),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}
