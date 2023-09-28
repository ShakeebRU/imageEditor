// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:hand_signature/signature.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imageeditor/image_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ImageCollectionScreenProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Edit Image',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
            onPressed: () async {
              final ImagePicker picker = ImagePicker();
              final List<XFile>? image = await picker.pickMultiImage();
              if (image != null) {
                if (image.length != 0) {
                  final controller = Provider.of<ImageCollectionScreenProvider>(
                      context,
                      listen: false);
                  for (XFile element in image) {
                    List<int> fileBytes = await element.readAsBytes();
                    String base64String = base64Encode(fileBytes);
                    controller.addImage(base64String);

                    print("check 1 pass");
                  }
                  if (controller.images.length != 0) {
                    print("check 1 pass");
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const SelectionScreen();
                    }));
                  } else {
                    print(controller.images.length);
                  }
                }
              }
            },
            child: const Text("Add images")),
      ),
    );
  }
}

class SelectionScreen extends StatefulWidget {
  const SelectionScreen({super.key});

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Provider.of<ImageCollectionScreenProvider>(context, listen: false)
                .images = [];
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.black.withOpacity(0.9),
        title: const Text("Images"),
        actions: [
          IconButton(
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                // Pick an image.
                final List<XFile>? image = await picker.pickMultiImage();
                if (image != null) {
                  if (image.length != 0) {
                    final controller =
                        Provider.of<ImageCollectionScreenProvider>(context,
                            listen: false);
                    image.forEach((element) async {
                      List<int> fileBytes = await element.readAsBytes();
                      String base64String = base64Encode(fileBytes);
                      controller.images.add(base64String);
                      controller.setIndex(0);
                    });
                    setState(() {});
                  }
                }
              },
              icon: const Icon(Icons.add_a_photo)),
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const MyHomePage(
                    title: "Edit ",
                    openDraw: false,
                  );
                }));
              },
              icon: const Icon(Icons.crop_rotate)),
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const MyHomePage(
                    title: "Edit ",
                    openDraw: true,
                  );
                }));
              },
              icon: const Icon(Icons.edit)),
          IconButton(
              onPressed: () {
                final controller = Provider.of<ImageCollectionScreenProvider>(
                    context,
                    listen: false);
                if (controller.images
                    .contains(controller.images[controller.selectedIndex])) {
                  controller.images
                      .remove(controller.images[controller.selectedIndex]);
                  // print("'$itemToDelete' has been deleted.");
                  if (controller.images.length != 0) {
                    controller.setIndex(0);
                    // setState(() {});
                  } else {
                    Navigator.pop(context);
                  }
                }
              },
              icon: const Icon(Icons.delete))
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.send),
        ),
      ),
      body: Consumer<ImageCollectionScreenProvider>(
        builder: (context, controller, child) {
          return Container(
            height: height,
            width: width,
            color: Colors.black.withOpacity(0.9),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    height: height * 0.7,
                    width: width,
                    child: Image.memory(base64Decode(
                        controller.images[controller.selectedIndex])),
                  ),
                ),
                Container(
                  height: height * 0.1,
                  width: width,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const ScrollPhysics(),
                    itemCount: controller.images.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          controller.setIndex(index);
                        },
                        child: Container(
                          height: 70,
                          width: 70,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                                width: 3,
                                color: controller.selectedIndex == index
                                    ? Colors.blue
                                    : Colors.black),
                            color: Colors.black,
                          ),
                          child: Image.memory(
                              base64Decode(controller.images[index])),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final bool openDraw;
  const MyHomePage({Key? key, required this.title, required this.openDraw})
      : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  HandSignatureControl control = HandSignatureControl(
    threshold: 0.01,
    smoothRatio: 0.65,
    velocityRange: 2.0,
  );

  ValueNotifier<String?> svg = ValueNotifier<String?>(null);

  ValueNotifier<ByteData?> rawImage = ValueNotifier<ByteData?>(null);

  ValueNotifier<ByteData?> rawImageFit = ValueNotifier<ByteData?>(null);
  bool expandCrop = false;
  bool expandRotate = false;
  // bool openDraw = false;
  // bool colorOpen = false;
  Color drawColorSelected = Colors.black;
  final controller = CropController(
    aspectRatio: 1,
    defaultCrop: const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
  );
  Widget _buildImageView() => Center(
        child: ValueListenableBuilder<ByteData?>(
            valueListenable: rawImage,
            builder: (context, data, child) {
              final controller = Provider.of<ImageCollectionScreenProvider>(
                  context,
                  listen: false);

              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    child: Image.memory(base64Decode(
                        controller.images[controller.selectedIndex])),
                  ),
                  Container(
                    constraints: const BoxConstraints.expand(),
                    // color: Colors.white,
                    child: HandSignature(
                      control: control,
                      type: SignatureDrawType.shape,
                      color: drawColorSelected,
                    ),
                  ),
                ],
              );
            }
            // },
            ),
      );

  Future<String> rawImageToBase64(RawImage rawImage) async {
    // Obtain the raw image data
    final ui.Image image = rawImage.image!;
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('Failed to convert RawImage to ByteData');
    }

    // Convert ByteData to a Uint8List
    final Uint8List uint8List = byteData.buffer.asUint8List();

    // Encode the Uint8List to base64
    final String base64String = base64Encode(uint8List);

    return base64String;
  }

  @override
  Widget build(BuildContext context) {
    final controller1 =
        Provider.of<ImageCollectionScreenProvider>(context, listen: false);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white.withOpacity(0.7),
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.7),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                  widget.openDraw ? Icons.close : Icons.arrow_back_ios_new)),
          title: Text(widget.title),
          actions: [
            // TextButton(
            //   onPressed: ,
            //   child: const Text('Done'),
            // ),

            widget.openDraw
                ? IconButton(
                    icon: const Icon(Icons.undo),
                    onPressed: () {
                      control.clear();
                      svg.value = null;
                      rawImage.value = null;
                      rawImageFit.value = null;
                      setState(() {});
                    },
                  )
                : IconButton(
                    icon: const Icon(Icons.undo),
                    onPressed: () {
                      controller.rotation = CropRotation.up;
                      controller.crop = const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
                      controller.aspectRatio = 1.0;
                    },
                  ),
            IconButton(
                onPressed: () async {
                  if (widget.openDraw) {
                    // svg.value = control.toSvg(
                    //   color: Colors.blueGrey,
                    //   type: SignatureDrawType.shape,
                    //   fit: true,
                    // );

                    // rawImage.value = await control.toImage(
                    //   color: Colors.blueAccent,
                    //   background: Colors.greenAccent,
                    //   fit: false,
                    // );
                    // Uint8List uint8List = rawImage.value!.buffer.asUint8List();

                    // String base64String = base64Encode(uint8List);
                    // rawImageFit.value = await control.toImage(
                    //   color: Colors.black,
                    //   // background: Colors.greenAccent,
                    //   fit: true,
                    // );
                    // Uint8List uint8List =
                    //     rawImageFit.value!.buffer.asUint8List();
                    // String base64String = base64Encode(uint8List);
                    // Provider.of<ImageCollectionScreenProvider>(context,
                    //         listen: false)
                    //     .saveImage(base64String);
                    // print("result 1 : ${svg.value}");
                    // print("result 2 : ${rawImage.value}");
                    // print("result 3 : ${rawImageFit.value}");
                    control.clear();
                    svg.value = null;
                    rawImage.value = null;
                    rawImageFit.value = null;
                    // openDraw = false;
                    // colorOpen = false;
                    Navigator.pop(context);
                    setState(() {});
                  } else {
                    await _finished();
                  }
                },
                icon: const Icon(Icons.check)),
          ],
        ),
        body: Center(
          child: Stack(
            children: [
              widget.openDraw
                  ? _buildImageView()
                  : CropImage(
                      controller: controller,
                      image: Image.memory(base64Decode(
                          controller1.images[controller1.selectedIndex])),
                      paddingSize: 25.0,
                      alwaysMove: true,
                    ),
              widget.openDraw
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Center(
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: Stack(
                              children: <Widget>[
                                // CustomPaint(
                                //   painter: DebugSignaturePainterCP(
                                //       control: control,
                                //       cp: false,
                                //       cpStart: false,
                                //       cpEnd: false),
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
        bottomNavigationBar: _buildButtons(),
      ),
    );
  }

  Widget _buildButtons() => Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            border: Border.all(color: Colors.white.withOpacity(0.3))),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widget.openDraw == false
                  ? Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.crop,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (expandCrop == true) {
                              expandCrop = false;
                              expandRotate = false;
                            } else {
                              if (!widget.openDraw) {
                                expandCrop = true;
                                expandRotate = false;
                              }
                            }
                            setState(() {});
                          },
                        ),
                        expandCrop == true
                            ? const SizedBox(
                                height: 20,
                                child: VerticalDivider(
                                    color: Colors.white,
                                    width: 2,
                                    thickness: 2))
                            : const SizedBox.shrink(),
                        expandCrop == true
                            ? TextButton(
                                onPressed: () {
                                  controller.aspectRatio = null;
                                  controller.crop =
                                      const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
                                },
                                child: const Text(
                                  "Free",
                                  style: TextStyle(color: Colors.white),
                                ))
                            : const SizedBox.shrink(),
                        expandCrop == true
                            ? TextButton(
                                onPressed: () {
                                  controller.aspectRatio = 1.0;
                                  controller.crop =
                                      const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
                                },
                                child: const Text(
                                  "square",
                                  style: TextStyle(color: Colors.white),
                                ))
                            : const SizedBox.shrink(),
                        expandCrop == true
                            ? TextButton(
                                onPressed: () {
                                  controller.aspectRatio = 2.0;
                                  controller.crop =
                                      const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
                                },
                                child: const Text(
                                  "2:1",
                                  style: TextStyle(color: Colors.white),
                                ))
                            : const SizedBox.shrink(),
                        expandCrop == true
                            ? TextButton(
                                onPressed: () {
                                  controller.aspectRatio = 1 / 2;
                                  controller.crop =
                                      const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
                                },
                                child: const Text(
                                  "1:2",
                                  style: TextStyle(color: Colors.white),
                                ))
                            : const SizedBox.shrink(),
                        expandCrop == true
                            ? TextButton(
                                onPressed: () {
                                  controller.aspectRatio = 4.0 / 3.0;
                                  controller.crop =
                                      const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
                                },
                                child: const Text(
                                  "4:3",
                                  style: TextStyle(color: Colors.white),
                                ))
                            : const SizedBox.shrink(),
                        expandCrop == true
                            ? TextButton(
                                onPressed: () {
                                  controller.aspectRatio = 16.0 / 9.0;
                                  controller.crop =
                                      const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
                                },
                                child: const Text(
                                  "16:9",
                                  style: TextStyle(color: Colors.white),
                                ))
                            : const SizedBox.shrink(),
                        const SizedBox(
                            height: 30,
                            child: VerticalDivider(
                                color: Colors.white, width: 2, thickness: 2)),
                        IconButton(
                          icon: const Icon(
                            Icons.crop_rotate,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (expandRotate == true) {
                              expandCrop = false;
                              expandRotate = false;
                            } else {
                              if (!widget.openDraw) {
                                expandCrop = false;
                                expandRotate = true;
                              }
                            }
                            setState(() {});
                          },
                        ),
                        expandRotate == true
                            ? const SizedBox(
                                height: 20,
                                child: VerticalDivider(
                                    color: Colors.white,
                                    width: 2,
                                    thickness: 2))
                            : const SizedBox.shrink(),
                        expandRotate == true
                            ? IconButton(
                                icon: const Icon(
                                  Icons.rotate_90_degrees_ccw_outlined,
                                  color: Colors.white,
                                ),
                                onPressed: _rotateLeft,
                              )
                            : const SizedBox.shrink(),
                        expandRotate == true
                            ? IconButton(
                                icon: const Icon(
                                  Icons.rotate_90_degrees_cw_outlined,
                                  color: Colors.white,
                                ),
                                onPressed: _rotateRight,
                              )
                            : const SizedBox.shrink(),
                        const SizedBox(
                            height: 30,
                            child: VerticalDivider(
                                color: Colors.white, width: 2, thickness: 2)),
                      ],
                    )
                  : const SizedBox.shrink(),
              widget.openDraw == true
                  ? IconButton(
                      icon: const Icon(
                        Icons.draw,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // if (colorOpen == true) {
                        //   colorOpen = false;
                        // } else {
                        // colorOpen = true;
                        // }
                        // setState(() {});
                      })
                  : const SizedBox.shrink(),
              widget.openDraw == true
                  ? const SizedBox(
                      height: 20,
                      child: VerticalDivider(
                          color: Colors.white, width: 2, thickness: 2))
                  : const SizedBox.shrink(),
              widget.openDraw == true
                  ? Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            drawColorSelected = Colors.black;
                            setState(() {});
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: const CircleAvatar(
                              radius: 11,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            drawColorSelected = Colors.white;
                            setState(() {});
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: const CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            drawColorSelected = Colors.red;
                            setState(() {});
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: const CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            drawColorSelected = Colors.blue;
                            setState(() {});
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: const CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.blue,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            drawColorSelected = Colors.green;
                            setState(() {});
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: const CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
              widget.openDraw == true
                  ? const SizedBox(
                      height: 30,
                      child: VerticalDivider(
                          color: Colors.white, width: 2, thickness: 2))
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      );

  Future<void> _aspectRatios() async {
    final value = await showDialog<double>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select aspect ratio'),
          children: [
            // special case: no aspect ratio
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, -1.0),
              child: const Text('free'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 1.0),
              child: const Text('square'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 2.0),
              child: const Text('2:1'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 1 / 2),
              child: const Text('1:2'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 4.0 / 3.0),
              child: const Text('4:3'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 16.0 / 9.0),
              child: const Text('16:9'),
            ),
          ],
        );
      },
    );
    if (value != null) {
      controller.aspectRatio = value == -1 ? null : value;
      controller.crop = const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
    }
  }

  Future<void> _rotateLeft() async => controller.rotateLeft();

  Future<void> _rotateRight() async => controller.rotateRight();

  Future<ByteData> imageToByteData(Image image) async {
    Completer<ByteData> completer = Completer<ByteData>();
    // Load the image as a network image and decode it to bytes.
    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(info.image.toByteData(format: ImageByteFormat.png)
            as FutureOr<ByteData>?);
      }),
    );

    return completer.future;
  }

  Future<void> _finished() async {
    // Image image = await controller.croppedImage();
    ui.Image image = await controller.croppedBitmap();
    ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
    String base64String =
        base64Encode(Uint8List.sublistView(byteData!.buffer.asUint8List()));
    print(base64String);
    final control =
        Provider.of<ImageCollectionScreenProvider>(context, listen: false);
    // control.images[control.selectedIndex] = base64String;
    control.saveImage(base64String);
    Navigator.pop(context);
    // await showDialog<bool>(
    //   context: context,
    //   builder: (context) {
    //     return SimpleDialog(
    //       contentPadding: const EdgeInsets.all(6.0),
    //       titlePadding: const EdgeInsets.all(8.0),
    //       title: const Text('Cropped image'),
    //       children: [
    //         // Text('relative: ${controller.crop}'),
    //         // Text('pixels: ${controller.cropSize}'),
    //         const SizedBox(height: 5),
    //         Image.memory(base64Decode(base64String)),
    //         TextButton(
    //           onPressed: () => Navigator.pop(context, true),
    //           child: const Text('OK'),
    //         ),
    //       ],
    //     );
    //   },
    // );
  }
}
