
// import 'dart:io';

import 'dart:io';

import 'package:file_assembling/Shared.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Assemble_folder.dart';
import 'View.dart';
import 'package:google_fonts/google_fonts.dart';

// import 'package:flutter_launcher_icons/android.dart';
// import 'package:flutter_launcher_icons/constants.dart';
// import 'package:flutter_launcher_icons/custom_exceptions.dart';
// import 'package:flutter_launcher_icons/ios.dart';
// import 'package:flutter_launcher_icons/main.dart';
// import 'package:flutter_launcher_icons/utils.dart';
// import 'package:flutter_launcher_icons/xml_templates.dart';


// final Widget logo = SvgPicture.asset("assets/app_logo.svg",semanticsLabel: 'Acme Logo');


void main() => runApp(
  const MaterialApp(
    home: Splash(),
    debugShowCheckedModeBanner: false,
    title: "File Assembler"
  )
);


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Future<Widget> favFiles() async {
    String rootPath = (await getApplicationDocumentsDirectory()).path;
    List<Map> fav = await Shared.filesPath.readData("favorite = 1");
    List<Widget> favBody = [];

    if (fav.isEmpty) {
      return Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            width: Shared.width,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(25),
                topLeft: Radius.circular(25)
              )
            ),

            child: Center(
              child: Text(
                "No favorite files yet",
                style: GoogleFonts.tangerine(
                  fontWeight: FontWeight.bold,
                  fontSize: 45,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: ClipRRect(
              child: Image.asset("assets/no_data.png"),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(25),
                bottomLeft: Radius.circular(25)
              )
            ),
          ),
        ],
      );
    }

    for (Map file in fav) {
      String filePath = rootPath + "/${file["name"]}";
      int size = File(filePath).lengthSync();

      favBody.add(
        InkWell(
          child: Container(
            width: 170,
            height: 230,
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 7,
                  offset: Offset(0, 5)
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 70,
                  child: Image.asset("assets/splash_icon.png")
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: 145,
                  child: Center(
                    child: Text(
                      file["name"],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[400],
                        overflow: TextOverflow.ellipsis
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  Shared.covertFileSize(size),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700]
                  ),
                ),
              ],
            ),
          ),

          onTap: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => FolderViewer(filePath))
            // );

            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewFile(filePath))
            );
          },
        )
      );
    }

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: Shared.width,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(25),
              topLeft: Radius.circular(25)
            )
          ),

          child: Center(
            child: Text(
              "Favorite",
              style: GoogleFonts.tangerine(
                fontWeight: FontWeight.bold,
                fontSize: 45,
                color: Colors.white,
              ),
            ),
          ),
        ),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          width: Shared.width,
          decoration: BoxDecoration(
            color: Colors.grey[500],
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(25),
              bottomLeft: Radius.circular(25)
            )
          ),

          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: favBody,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Shared.context = context;
    return WillPopScope(
      onWillPop: () async {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Shared.isDark ? Colors.grey[900] : Colors.white,
            title: Text(
              "Exit app",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[400]
                )
            ),

            content: const Text(
              "Do you want to exit app?",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red
                )
            ),

            actions: [
              TextButton(
                onPressed: () {
                  exit(0);
                },
                child: const Text(
                  "Exit",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red
                    )
                )
              ),

              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700]
                  )
                )
              )
            ],
          )
        );
        return false;
      },

      child: Scaffold(
        backgroundColor: Shared.isDark ? Colors.black : Colors.white,

        body: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 240,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(50),
                          bottomRight: Radius.circular(50),
                        ),

                        gradient: LinearGradient(
                          colors: [Colors.green, Colors.pinkAccent],
                          begin: FractionalOffset(0.0, 0.0),
                          end: FractionalOffset(0.5, 0.0),
                          stops: [0.0, 1.0],
                          tileMode: TileMode.clamp
                        ),
                      ),

                      child: SafeArea(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            SizedBox(
                              width: 70,
                              height: 70,
                              child: Center(
                                child: Builder(
                                  builder: (BuildContext context) => IconButton(
                                    onPressed: () {
                                      Scaffold.of(context).openDrawer();
                                    },

                                    icon: const Icon(Icons.menu, size: 30, color: Colors.white),
                                    tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                                  ),
                                ),
                              ),
                            ),

                            Container(
                              width: Shared.width - 140,
                              height: 70,
                              // height: double.minPositive,
                              margin: const EdgeInsets.only(top: 20),
                              child: Center(
                                child: Text(
                                  "File Assembler",
                                  style: GoogleFonts.tangerine(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 50,
                                  )
                                ),
                              ),
                            ),

                            // const SizedBox(width: 70),
                          ],
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: const EdgeInsets.only(top: 150, bottom: 30),
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.purple,
                                blurRadius: 7,
                                offset: Offset(0, 5)
                            )
                          ],
                        ),

                        child: Column(
                          children: [
                            Card(
                              margin: const EdgeInsets.symmetric(vertical: 0),
                              color: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(50),
                                  topRight: Radius.circular(50)
                                )
                              ),

                              child: InkWell(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(50),
                                  topRight: Radius.circular(50)
                                ),
                                child: SizedBox(
                                  width: Shared.width - 120,
                                  height: 50,
                                  child: Center(
                                    child: Text(
                                      // "Assemble folder",
                                      "Folder to ${Shared.extension} file",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple
                                      )
                                    )
                                  )
                                ),
                                onTap: () async {
                                  PermissionStatus status = await Permission.storage.status;
                                  if (status.isGranted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const AssembleFolder()),
                                    );
                                  } else {
                                    PermissionStatus status2 = await Permission.storage.request();
                                    if (status2.isDenied) {
                                      return;
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const AssembleFolder()),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),

                            Card(
                              margin: const EdgeInsets.symmetric(vertical: 0),
                              color: Colors.grey[300],
                              // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(50),
                                      bottomRight: Radius.circular(50)
                                  )
                              ),

                              child: InkWell(
                                borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(50),
                                    bottomRight: Radius.circular(50)
                                ),

                                child: SizedBox(
                                    width: Shared.width - 120,
                                    height: 50,
                                    child: Center(
                                      child: Text(
                                        "View ${Shared.extension} file",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green[700]
                                          )
                                      )
                                    )
                                ),
                                onTap: () async {
                                  PermissionStatus status = await Permission.storage.status;
                                  if (status.isGranted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ViewFile("null")),
                                    );
                                  } else {
                                    PermissionStatus status2 = await Permission.storage.request();
                                    if (status2.isDenied) {
                                      return;
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ViewFile("null")),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                FutureBuilder<Widget>(
                  future: favFiles(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    }
                    return snapshot.data!;
                  }
                ),

                const SizedBox(height: 20)
              ],
            ),
          ),
        ),

        drawer: Drawer(
          backgroundColor: Shared.isDark ? Colors.black : Colors.white,

          child: ListView(
            padding: EdgeInsets.zero,

            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.pinkAccent,
                ),
                child: Row(
                  children: [
                    const CircleAvatar(backgroundImage: AssetImage("assets/Me.png"), radius: 55),

                    const SizedBox(width: 10),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Munir M. Atef",
                          style: GoogleFonts.bebasNeue(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                            color: Colors.white
                          ),
                        ),

                        const Text(
                          "Mobile Developer",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Row(
                        //   children: [
                        //     InkWell(
                        //       borderRadius: BorderRadius.circular(5),
                        //       child: ClipRRect(
                        //         child: Image.asset("assets/linkedin.png", width: 35, height: 35),
                        //         borderRadius: const BorderRadius.all(Radius.circular(5)),
                        //       ),
                        //       onTap: () {},
                        //     ),
                        //
                        //     const SizedBox(width: 10),
                        //
                        //     InkWell(
                        //       borderRadius: BorderRadius.circular(5),
                        //       child: ClipRRect(
                        //         child: Image.asset("assets/twitter.png", width: 35, height: 35),
                        //         borderRadius: const BorderRadius.all(Radius.circular(5)),
                        //       ),
                        //       onTap: () {},
                        //     ),
                        //
                        //     const SizedBox(width: 10),
                        //
                        //     InkWell(
                        //       borderRadius: BorderRadius.circular(5),
                        //       child: ClipRRect(
                        //         child: Image.asset("assets/whatsapp.png", width: 35, height: 35),
                        //         borderRadius: const BorderRadius.all(Radius.circular(5)),
                        //       ),
                        //       onTap: () {},
                        //     ),
                        //   ],
                        // )

                        Row(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(5),
                              child: const Icon(
                                MdiIcons.linkedin,
                                color: Colors.white,
                                size: 40,
                              ),
                              onTap: () {},
                            ),

                            const SizedBox(width: 10),

                            InkWell(
                              borderRadius: BorderRadius.circular(5),
                              child: const Icon(
                                MdiIcons.twitter,
                                color: Colors.white,
                                size: 40,
                              ),
                              onTap: () {},
                            ),

                            const SizedBox(width: 10),

                            InkWell(
                              borderRadius: BorderRadius.circular(5),
                              child: const Icon(
                                MdiIcons.whatsapp,
                                color: Colors.white,
                                size: 40,
                              ),
                              onTap: () {},
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),

              ListTile(
                leading: Icon(
                  Icons.favorite,
                  color: Shared.isDark ? Colors.white : Colors.black
                ),

                title: Text(
                  "Favorite",
                  style: TextStyle(
                    color: Shared.isDark ? Colors.white : Colors.black,
                    fontSize: 20,
                  ),
                ),

                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SavedFiles(true)),
                  );
                  setState(() {});
                },
              ),

              ListTile(
                leading: Icon(
                    Icons.save_rounded,
                    color: Shared.isDark ? Colors.white : Colors.black
                ),

                title: Text(
                  "Saved",
                  style: TextStyle(
                    color: Shared.isDark ? Colors.white : Colors.black,
                    fontSize: 20,
                  ),
                ),

                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SavedFiles(false)),
                  );
                  setState(() {});
                },
              ),

              ListTile(
                leading: Shared.isDark ?
                  const Icon(Icons.light_mode, color: Colors.white) :
                  const Icon(Icons.dark_mode, color: Colors.black),

                title: Shared.isDark ? const Text(
                  "Light mode",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ) : const Text(
                  "Dark mode",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                onTap: () async {
                  final SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isDarkMode', !Shared.isDark);

                  setState(() {
                    Shared.isDark = !Shared.isDark;
                  });
                },
              ),

              ListTile(
                leading: Icon(
                    Icons.lock,
                    color: Shared.isDark ? Colors.white : Colors.black
                ),

                title: Text(
                  "Security",
                  style: TextStyle(
                    color: Shared.isDark ? Colors.white : Colors.black,
                    fontSize: 20,
                  ),
                ),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Security()
                    )
                  );
                },
              ),

              ListTile(
                leading: Icon(
                    Icons.share,
                    color: Shared.isDark ? Colors.white : Colors.black
                ),

                title: Text(
                  "Share",
                  style: TextStyle(
                    color: Shared.isDark ? Colors.white : Colors.black,
                    fontSize: 20,
                  ),
                ),

                onTap: () {
                  setState(() {

                  });
                },
              ),

              const Divider(color: Colors.grey),

              ListTile(
                leading: Icon(
                    Icons.info,
                    color: Shared.isDark ? Colors.white : Colors.black
                ),

                title: Text(
                  "About developer",
                  style: TextStyle(
                    color: Shared.isDark ? Colors.white : Colors.black,
                    fontSize: 20,
                  ),
                ),

                onTap: () {},
              ),
            ],
          ),
        )
      ),
    );
  }
}



// ignore: must_be_immutable
class SavedFiles extends StatefulWidget {
  bool isFavorite;
  SavedFiles(this.isFavorite, {Key? key}) : super(key: key);


  @override
  // ignore: no_logic_in_create_state
  State<SavedFiles> createState() => _SavedFilesState(isFavorite);
}

class _SavedFilesState extends State<SavedFiles> {
  bool isFavorite;
  _SavedFilesState(this.isFavorite);

  Future<Widget> fileWidget(int id, String name, int isFav) async {
    String filePath = (await getApplicationDocumentsDirectory()).path + "/$name";
    int size = File(filePath).lengthSync();

    return Card(
      color: Shared.isDark ? Colors.grey[900] : Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.fromLTRB(2,2,2,0),

      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: Center(
            child: Row(
              children: [
                const SizedBox(width: 10),

                Icon(Icons.description, color: Colors.purple[400], size: 40),

                const SizedBox(width: 10),

                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: Shared.width - 140,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[400],
                          ),
                        ),
                      ),
                    ),

                    Text(
                      "  ${Shared.covertFileSize(size)}",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    )
                  ],
                ),

                IconButton(
                    onPressed: () async {
                      await Shared.filesPath.updateData("id = $id", "favorite = ${1 - isFav}");
                      setState(() {
                        isFav = 1 - isFav;
                      });
                    },
                    icon: Icon(Icons.favorite, color: isFav == 1 ? Colors.red : Colors.grey)
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FolderViewer(filePath))
          );
        },

        onLongPress: () {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => SimpleDialog(
              backgroundColor: Shared.isDark ? Colors.grey[900] : Colors.white,

              title: Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[400]
                )
              ),

              children: [
                ListTile(
                  leading: Icon(Icons.save_as, color: Colors.green[700]),
                  title: Text(
                    "Save to",
                    style: TextStyle(fontWeight: FontWeight.bold,
                      color: Colors.green[700]
                    )
                  ),

                  onTap: () async {
                    String savedFilePath = await Shared.saveExistFile(name);
                    File(filePath).copySync(savedFilePath);
                  },
                ),

                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red[700]),
                  title: Text(
                    "Delete",
                    style: TextStyle(fontWeight: FontWeight.bold,
                        color: Colors.red[700]
                    )
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        backgroundColor: Shared.isDark ? Colors.grey[900] : Colors.white,

                        title: Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[400]
                          )
                        ),

                        content: const Text(
                          "Do you want to delete this file?",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red
                          ),
                        ),

                        actions: [
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              File(filePath).deleteSync();
                              await Shared.filesPath.deleteData("id = $id");
                              setState(() {});
                            },
                            child: const Text(
                              "Confirm",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red
                              ),
                            )
                          ),

                          TextButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700]
                                ),
                              )
                          ),
                        ],
                      )
                    );
                  },
                )
              ],
            )
          );
        },
      ),
    );
  }

  Future<Widget> getSavedFiles() async {
    List<Map> files = [];
    if (isFavorite) {
      files = await Shared.filesPath.readData("favorite = 1");
    } else {
      files = await Shared.filesPath.readData("id > 0");
    }

    if (files.isEmpty) {
      return Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 70),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            width: Shared.width,
            height: 70,
            decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(25),
                    topLeft: Radius.circular(25)
                )
            ),

            child: Center(
              child: Text(
                isFavorite ? "No favorite files yet" : "No saved files yet",
                style: GoogleFonts.tangerine(
                  fontWeight: FontWeight.bold,
                  fontSize: 45,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: ClipRRect(
                child: Image.asset("assets/no_data.png"),
                borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(25),
                    bottomLeft: Radius.circular(25)
                )
            ),
          ),
        ],
      );
    }

    List<Widget> body = [];

    for (Map file in files) {
      body.add(await fileWidget(file["id"], file["name"], file["favorite"]));
    }

    return SingleChildScrollView(
      child: Column(
        children: body,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Shared.isDark ? Colors.black : Colors.white,

      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 140,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),

              gradient: LinearGradient(
                  colors: [Colors.green, Colors.pinkAccent],
                  begin: FractionalOffset(0.0, 0.0),
                  end: FractionalOffset(0.5, 0.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp
              ),
            ),

            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  SizedBox(
                    width: 70,
                    height: 70,
                    child: Center(
                      child: Builder(
                        builder: (BuildContext context) => IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },

                          icon: const Icon(Icons.arrow_back_ios, size: 30, color: Colors.white),
                          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                        ),
                      ),
                    ),
                  ),

                  Container(
                    width: Shared.width - 140,
                    height: 70,
                    // height: double.minPositive,
                    margin: const EdgeInsets.only(top: 20),
                    child: Center(
                      child: Text(
                        isFavorite ? "Favorite" : "Saved files",
                        style: GoogleFonts.tangerine(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 50,
                        )
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(
            height: Shared.height - 140,
            child: FutureBuilder<Widget>(
              future: getSavedFiles(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: Column(
                        children: [
                          SizedBox(height: Shared.height / 3),
                          const CircularProgressIndicator(color: Colors.blue),
                        ],
                      )
                  );
                }

                return snapshot.data!;
              },
            ),
          ),
        ],
      ),
    );
  }
}


class Security extends StatefulWidget {
  const Security({Key? key}) : super(key: key);

  @override
  State<Security> createState() => _SecurityState();
}

class _SecurityState extends State<Security> {
  bool isPassDown = false;
  bool isPassVisible = false;
  bool isConfirmPassVisible = false;

  TextEditingController passController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Shared.isDark ? Colors.black : Colors.white,

      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "Security Settings",
          style: GoogleFonts.tangerine(
            fontWeight: FontWeight.bold,
            fontSize: 50
          ),
        ),
      ),

      body: Column(
        children: [
          Card(
            color: Colors.grey[200],
            margin: EdgeInsets.zero,
            child: InkWell(
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Set PIN for app",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),
                      ),

                      Icon(
                        isPassDown? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        size: 35,
                        color: Colors.pinkAccent,
                      ),
                    ],
                  ),
                ),
              ),

              onTap: () {
                setState(() {
                  isPassDown = !isPassDown;
                });
              },
            ),
          ),

          Visibility(
            visible: isPassDown,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25)
                )
              ),

              child: Column(
                children: [
                  TextField(
                    controller: passController,
                    keyboardType: TextInputType.number,
                    style: Theme.of(context).textTheme.headline6,
                    obscureText: !isPassVisible,
                    decoration: InputDecoration(
                      hintText: "Enter PIN",
                      suffixIcon: IconButton(
                        icon: isPassVisible ? const Icon(
                          Icons.visibility_off,
                          color: Colors.green
                        ) :
                        const Icon(
                              Icons.visibility,
                              color: Colors.red
                        ),

                        onPressed: () {
                          setState(() {
                            isPassVisible = !isPassVisible;
                          });
                        },
                      ),

                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      fillColor: Colors.grey[300],
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  TextField(
                    controller: confirmPassController,
                    keyboardType: TextInputType.number,
                    style: Theme.of(context).textTheme.headline6,
                    obscureText: !isConfirmPassVisible,
                    decoration: InputDecoration(
                      hintText: "Confirm PIN",
                      suffixIcon: IconButton(
                        icon: isConfirmPassVisible ? const Icon(
                            Icons.visibility_off,
                            color: Colors.green
                        ) :
                        const Icon(
                            Icons.visibility,
                            color: Colors.red
                        ),
                        onPressed: () {
                          setState(() {
                            isConfirmPassVisible = !isConfirmPassVisible;
                          });
                        },
                      ),

                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      fillColor: Colors.grey[300],
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  Card(
                    margin: const EdgeInsets.only(top: 30),
                    color: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: InkWell(
                      child: const SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: Center(
                          child: Text(
                            "Confirm",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                            ),
                          )
                        ),
                      ),

                      onTap: () async {
                        String pass = passController.text;
                        if (pass.isEmpty) {
                          Shared.showToast("PIN field is empty");
                          return;
                        }

                        for (int i = 0; i < pass.length; i++) {
                          if (pass.codeUnitAt(i) < 48 || pass.codeUnitAt(i) > 57) {
                            Shared.showToast("Invalid PIN entered");
                            return;
                          }
                        }

                        if (confirmPassController.text.isEmpty) {
                          Shared.showToast("PIN confirmation field is empty");
                          return;
                        }

                        if (pass != confirmPassController.text) {
                          Shared.showToast("Not matching!!");
                          return;
                        }

                        final SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.setString('password', pass);
                        Navigator.of(context).pop();
                        Shared.showToast("Password enabled successfully");
                      },
                    ),
                  )
                ],
              ),
            )
          ),

          Card(
            color: Colors.grey[200],
            margin: const EdgeInsets.only(top: 2),
            child: InkWell(
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Disable PIN",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),
                      ),

                      Icon(
                        Icons.lock_open,
                        size: 35,
                        color: Colors.pinkAccent,
                      )
                    ],
                  ),
                ),
              ),

              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    backgroundColor: Shared.isDark ? Colors.grey[900] : Colors.white,
                    title: const Text(
                      "Remove PIN",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple
                      ),
                    ),

                    content: const Text(
                      "Do you want to remove PIN?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red
                      ),
                    ),

                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green
                          ),
                        )
                      ),

                      TextButton(
                        onPressed: () async {
                          final SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setString('password', "null");

                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          Shared.showToast("Password disabled successfully");
                        },
                        child: const Text(
                          "Disable",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red
                          ),
                        )
                      )
                    ],
                  )
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}



class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  String name = "Munir M. Atef";

  Future<Widget> showLetter(String letter, int delay) async {
    await  Future.delayed(Duration(milliseconds: delay));
    return Text(letter, style: GoogleFonts.tangerine(fontSize: 35, fontWeight: FontWeight.w900, color: Colors.red));
  }

  @override
  void initState() {
    // TODO: implement initState
    Shared.getMode();

    Future.delayed(const Duration(seconds: 5), () async {
      String pass = await Shared.getPass();
      if (pass == "null") {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Home()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EnterPassword(pass)));
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Shared.width = MediaQuery.of(context).size.width;
    Shared.height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(120),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 20,
                    offset: Offset(0,15)
                  )
                ],
              ),
              child: CircleAvatar(
                radius: 120,
                backgroundColor: Colors.white,
                child: Image.asset("assets/splash_icon.png"),
              ),
            ),


            const SizedBox(height: 90),

            Text("Developed by", style: GoogleFonts.bebasNeue(fontSize: 35, fontWeight: FontWeight.w500, color: Colors.green[700])),

            Container(
              height: 60,
              width: 260,

              decoration: BoxDecoration(
                  color: Colors.yellow[600],
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.grey,
                        blurRadius: 15,
                        offset: Offset(0, 5)
                    )
                  ]
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < name.length; i++)
                    FutureBuilder<Widget>(
                      future: showLetter(name[i], 500 + i*200),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          if (i == name.length - 1) {
                            return const Text("|", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold));
                          }
                          return Container();
                        }

                        return snapshot.data!;
                      }
                    ),

                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}



// ignore: must_be_immutable
class EnterPassword extends StatefulWidget {
  String pass;
  EnterPassword(this.pass, {Key? key}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<EnterPassword> createState() => _EnterPasswordState(pass);
}

class _EnterPasswordState extends State<EnterPassword> {
  String pass;
  _EnterPasswordState(this.pass);

  TextEditingController passController = TextEditingController();
  bool isPassVisible = false;
  int numCharEntered = 0;
  String enteredPass = "";

  Widget button(String num) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.green,
      child: InkWell(
        child: SizedBox(
          width: Shared.width / 3 - 30,
          height: 60,
          child: Center(
            child: Text(
              num,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ),

        onTap: () {
          setState(() {
            enteredPass += num;
          });

          if (enteredPass.length == pass.length) {
            if (enteredPass == pass) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Home()));
            } else {
              Shared.showToast("Wrong PIN entered");
              setState(() {
                enteredPass = "";
              });
            }
            return;
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(120),
              boxShadow: const [
                BoxShadow(
                    color: Colors.grey,
                    blurRadius: 20,
                    offset: Offset(0,15)
                )
              ],
            ),
            child: CircleAvatar(
              radius: 120,
              backgroundColor: Colors.white,
              child: Image.asset("assets/splash_icon.png"),
            ),
          ),

          Text(
            "Enter PIN",
            style: GoogleFonts.tangerine(
              fontWeight: FontWeight.w900,
              fontSize: 50,
            ),
          ),

          Container(
            padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(25)
              )
            ),

            child: Column(
              children: [
                Container(
                  // padding: EdgeInsets.symmetric(vertical: 10),
                  margin: const EdgeInsets.fromLTRB(10, 20, 10, 20),

                  // width: 250,
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.pinkAccent,
                      borderRadius: BorderRadius.circular(25)
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < pass.length; i++)
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: CircleAvatar(
                            child: Icon(
                              Icons.circle,
                              color: i < enteredPass.length ? Colors.black : Colors.white,
                              size: 12
                            ),

                            radius: 8,
                            backgroundColor: Colors.cyan,
                          ),
                        )
                    ],
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    button("1"),
                    button("2"),
                    button("3"),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    button("4"),
                    button("5"),
                    button("6"),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    button("7"),
                    button("8"),
                    button("9"),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Card(
                      margin: EdgeInsets.zero,
                      color: Colors.green,
                      child: InkWell(
                        child: SizedBox(
                          width: Shared.width * 2 / 3 - 45,
                          height: 60,
                          child: const Center(
                            child: Text(
                              "0",
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),

                        onTap: () {
                          setState(() {
                            enteredPass += "0";
                          });

                          if (enteredPass.length == pass.length) {
                            if (enteredPass == pass) {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Home()));
                            } else {
                              Shared.showToast("Wrong PIN entered");
                              setState(() {
                                enteredPass = "";
                              });
                            }
                            return;
                          }
                        },
                      ),
                    ),

                    Card(
                      margin: EdgeInsets.zero,
                      color: Colors.red,
                      child: InkWell(
                        child: SizedBox(
                          width: Shared.width / 3 - 30,
                          height: 60,
                          child: const Center(
                            child: Icon(Icons.close, size: 30)
                          ),
                        ),

                        onTap: () {
                          if (enteredPass.isEmpty) return;

                          setState(() {
                            enteredPass = enteredPass.substring(0, enteredPass.length - 1);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
