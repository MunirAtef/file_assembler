
// ignore: file_names
import 'dart:convert';
import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'Shared.dart' show Shared;
import 'package:file_icon/file_icon.dart';
import 'package:share_plus/share_plus.dart';

import 'package:open_file/open_file.dart' show OpenFile;
// import 'package:android_intent_plus/android_intent.dart';
// import 'package:android_intent_plus/flag.dart';



class ViewFile extends StatefulWidget {
  String defaultFile;
  ViewFile(this.defaultFile);

  @override
  State<ViewFile> createState() => _ViewFileState(defaultFile);
}

class _ViewFileState extends State<ViewFile> {
  // String defaultFile;s
  _ViewFileState(String defaultFile) {
    pickedFilePath = defaultFile;
  }

  late String pickedFilePath;
  String editedPath = "null";
  List<String> places = ["App saved files", "Favorite files", "Internal storage"];
  String selectedPlace = "App saved files";

  List<String> getPathList() {
    List<String> dirs = editedPath.split("/");
    dirs.removeWhere((element) => element == "");
    return dirs;
  }

  Future<void> editPath() async {
    String appDocPath = (await getApplicationDocumentsDirectory()).path;
    String rootPath = (await ExternalPath.getExternalStorageDirectories())[0];

    if (pickedFilePath.startsWith(appDocPath)) {
      editedPath = "Private storage"
          + pickedFilePath.substring(appDocPath.length, pickedFilePath.length);
    } else if (pickedFilePath.startsWith(rootPath)) {
      editedPath = "External storage"
          + pickedFilePath.substring(rootPath.length, pickedFilePath.length);
    } else {
      editedPath = pickedFilePath;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Shared.isDark ? Colors.black : Colors.white,

      body: SizedBox(
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
                        const SizedBox(width: 70),

                        Container(
                          width: Shared.width - 140,
                          height: 70,
                          margin: const EdgeInsets.only(top: 20),
                          child: Center(
                            child: Text(
                              "View ${Shared.extension} file",
                              style: GoogleFonts.tangerine(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 50,
                              )
                            ),
                          ),
                        ),

                        SizedBox(
                          width: 70,
                          height: 70,
                          child: Center(
                            child: Builder(
                              builder: (BuildContext context) => IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },

                                icon: const Icon(Icons.close, size: 30, color: Colors.white),
                                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                              ),
                            ),
                          ),
                        ),
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
                        Container(
                          width: Shared.width - 120,
                          height: 50,
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(25)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Pick from",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                                ),
                              ),

                              DropdownButton(
                                style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold ,color: Colors.black),
                                iconSize: 30,
                                value: selectedPlace,

                                items: places.map((String items) {
                                  return DropdownMenuItem(
                                    value: items,
                                    child: Text(
                                      items,
                                      style: TextStyle(
                                          color: Colors.purple[400]
                                      ),
                                    ),
                                  );
                                }).toList(),

                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedPlace = newValue!;
                                  });
                                },
                              ),

                            ],
                          ),
                        ),

                        Card(
                          margin: const EdgeInsets.symmetric(vertical: 0),
                          color: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(25))
                          ),

                          child: InkWell(
                            borderRadius: const BorderRadius.all(Radius.circular(25)),
                            child: SizedBox(
                              width: Shared.width - 120,
                              height: 50,
                              child: Center(
                                child: Text(
                                  "Pick ${Shared.extension} file",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple
                                  )
                                )
                              )
                            ),
                            onTap: () async {
                              String pickedPath;

                              if (selectedPlace == places[0]) {
                                pickedPath = await Shared.pickFileFromSaved(false);
                              } else if (selectedPlace == places[1]) {
                                pickedPath = await Shared.pickFileFromSaved(true);
                              } else {
                                pickedPath = await Shared.pickFile();
                              }

                              if (pickedPath != "null") {
                                pickedFilePath = pickedPath;
                                await editPath();
                                setState(() {});
                              }
                            }
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Visibility(
                visible: pickedFilePath == "null",
                child: Column(
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
                          "No file picked yet",
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
                )
            ),

            Visibility(
              visible: pickedFilePath != "null",
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: Shared.width,
                    height: 80,
                    decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(25),
                            topLeft: Radius.circular(25)
                        )
                    ),

                    child: Center(
                      child: Text(
                        "Picked File",
                        style: GoogleFonts.tangerine(
                          fontWeight: FontWeight.bold,
                          fontSize: 55,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    width: Shared.width,
                    decoration: BoxDecoration(
                        color: Colors.grey[500],
                        borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(25),
                            bottomLeft: Radius.circular(25)
                        )
                    ),

                    child: Center(
                      child: SingleChildScrollView(
                        reverse: true,
                        scrollDirection: Axis.horizontal,

                        child: Row(
                          children: [
                            for (String dir in getPathList())
                              Row(
                                children: [
                                  const Icon(Icons.chevron_right),

                                  Text(
                                    dir,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple
                                    ),
                                  )
                                ],
                              )
                          ],
                        ),
                      ),
                    ),
                  ),

                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    color: Colors.grey[300],
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25))
                    ),
                    child: InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(25)),

                      child: SizedBox(
                        width: Shared.width - 20,
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(
                                width: 80,
                                child: Icon(
                                  MdiIcons.folderOpen,
                                  color: Colors.pinkAccent,
                                  size: 35,
                                )
                            ),

                            SizedBox(
                              width: Shared.width - 170,
                              child: const Center(
                                child: Text(
                                  "View content",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple
                                  )
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FolderViewer(pickedFilePath)
                          )
                        );
                      },
                    ),
                  ),

                  Card(
                    margin: EdgeInsets.zero,
                    color: Colors.grey[300],
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25))
                    ),
                    child: InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(25)),

                      child: SizedBox(
                        width: Shared.width - 20,
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 80,
                              child: Icon(
                                MdiIcons.folderDownload,
                                color: Colors.pinkAccent,
                                size: 35,
                              )
                            ),

                            SizedBox(
                              width: Shared.width - 170,
                              child: const Center(
                                child: Text(
                                  "Convert to folder",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple
                                  )
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      onTap: () async {
                        // String rootPath = await Shared.pickFolder();
                        await Shared.saveFolder("New folder");
                        print("hi");
                        // Shared.loading("Saving folder");
                        // await Future.delayed(const Duration(seconds: 5));
                        // Navigator.of(context).pop();
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ignore: must_be_immutable
class FolderViewer extends StatefulWidget {
  String filePath;
  FolderViewer(this.filePath, {Key? key}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<FolderViewer> createState() => _FolderViewerState(filePath);
}

class _FolderViewerState extends State<FolderViewer> {
  String filePath;
  _FolderViewerState(this.filePath);

  List<int> dirsParent = [];
  List<String> dirsName = [];
  int headerSize = 0;

  List<int> filesParent = [];
  List<String> filesName = [];
  List<int> filesSize = [];
  late int response = -1;
  List<int> path = [1];

  Future<int> decodeFileKey() async {
    dirsParent = [];
    dirsName = [];

    filesParent = [];
    filesName = [];
    filesSize = [];

    try {
      File file = File(filePath);

      List<int> bytes = await file.readAsBytes();

      int size = bytes.length;
      int firstLineEnd = bytes.indexOf(10);
      int secondLineEnd = bytes.indexOf(10, firstLineEnd + 1);
      headerSize = secondLineEnd + 1;

      String foldersKey = utf8.decode(bytes.sublist(0, firstLineEnd));
      String filesKey = utf8.decode(bytes.sublist(firstLineEnd + 1, secondLineEnd));

      List<String> dirsKeyParts = foldersKey.split(":");

      dirsParent = [for (String i in dirsKeyParts[0].split("/")) int.parse(i)];
      dirsName = dirsKeyParts[1].split("/");

      if (filesKey == "none") return 0;

      List<String> filesKeyParts = filesKey.split(":");
      int totalBytes = 0;

      filesParent = [for (String i in filesKeyParts[0].split("/")) int.parse(i)];
      filesName = filesKeyParts[2].split("/");
      for (String i in filesKeyParts[1].split("/")) {
        filesSize.add(int.parse(i));
        totalBytes += int.parse(i);
      }

      if (totalBytes + secondLineEnd + 1 != size) {
        return 1;
      }

      return 0;
    }
    catch (e){
      return 1;
    }
  }

  Future<List<int>> getFileBytes(int index) async {
    File file = File(filePath);
    List<int> bytes = await file.readAsBytes();

    int preBytes = headerSize;
    for (int i = 0; i < index; i++) {
      preBytes += filesSize[i];
    }

    return bytes.sublist(preBytes, preBytes + filesSize[index]);
  }

  List<int> folderInfo(int folderId, List<int> info) {
    for (int i = 0; i < filesParent.length; i++) {
      if (filesParent[i] == folderId) {
        info[1]++;
        info[0] += filesSize[i];
      }
    }

    for (int i = 0; i < dirsParent.length; i++) {
      if (dirsParent[i] == folderId) {
        info[2]++;
        List<int> newInfo = folderInfo(i + 1, [0, 0, 0]);
        info[0] += newInfo[0];
        info[1] += newInfo[1];
        info[2] += newInfo[2];
      }
    }

    return info;
  }

  Widget folderWidget(int id, String folderName) {
    return Card(
      color: Shared.isDark ? Colors.grey[900] : Colors.grey[200],
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

                const Icon(Icons.folder, size: 45, color: Colors.amber),

                const SizedBox(width: 10),

                SizedBox(
                  width: Shared.width - 100,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      folderName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.purple[400],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        onTap: () {
          setState(() {
            if (path.last != id) {
              path.add(id);
            }
          });
        },

        onLongPress: () {
          List<int> info = folderInfo(id, [0, 0, 0]);

          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text(
                "File info",
                style: TextStyle(fontWeight: FontWeight.bold)
              ),

              content: Text(
                "Name:  $folderName\n\n"
                    "Size:  ${Shared.covertFileSize(info[0])}\n\n"
                    "Total files: ${info[1]}\n\n"
                    "Total folder:  ${info[2]}",
                style: const TextStyle(fontWeight: FontWeight.bold)
              ),
            )
          );
        },
      ),
    );
  }


  Widget fileWidget(int index, String fileName, int fileSize) {
    return Card(
      color: Shared.isDark ? Colors.grey[900] : Colors.grey[200],
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

                FileIcon(fileName, size: 45),
                // Stack(
                //   children: [
                //     SizedBox(
                //       width: 60,
                //       height: 60,
                //       child: Align(
                //         alignment: Alignment.center,
                //         child: Icon(Icons.feed, size: 60, color: Colors.white,)
                //       ),
                //     ),
                //
                //     SizedBox(
                //       width: 60,
                //       height: 60,
                //       child: Align(
                //         alignment: Alignment.bottomCenter,
                //         child: Container(
                //           width: 40,
                //           height: 20,
                //           child: Center(
                //             child: Text(
                //               "PDF",
                //               style: TextStyle(
                //                 fontWeight: FontWeight.bold,
                //                 color: Colors.white
                //               ),
                //             ),
                //           ),
                //           decoration: BoxDecoration(
                //             color: Colors.purple[400],
                //             borderRadius: BorderRadius.circular(5),
                //           ),
                //         ),
                //       ),
                //     ),
                //
                //     // Positioned(
                //     //   bottom: 0,
                //     //   left: 0,
                //     //   child: Container(
                //     //     child: SizedBox(
                //     //       width: 55,
                //     //       child: Center(
                //     //         child: Text(
                //     //           "TXT",
                //     //           style: TextStyle(
                //     //             fontWeight: FontWeight.bold
                //     //           ),
                //     //         ),
                //     //       ),
                //     //     ),
                //     //     decoration: BoxDecoration(
                //     //       color: Colors.green,
                //     //       borderRadius: BorderRadius.circular(10),
                //     //     ),
                //     //   ),
                //     // )
                //   ],
                // ),

                const SizedBox(width: 10),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: Shared.width - 100,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          fileName,
                          style: TextStyle(
                            color: Colors.purple[400],
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      "  ${Shared.covertFileSize(fileSize)}",
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => SimpleDialog(
              backgroundColor: Colors.grey[900],
              children: [
                ListTile(
                  leading: Icon(Icons.open_with, color: Colors.purple[400]),
                  title: Text("Open", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700])),
                  onTap: () async {
                    Navigator.of(context).pop();
                    List<int> fileBytes = await getFileBytes(index);
                    Directory tempDir = await getTemporaryDirectory();
                    String tempPath = "${tempDir.path}/$fileName";
                    File(tempPath).writeAsBytesSync(fileBytes);

                    await OpenFile.open(tempPath);
                  }
                ),

                ListTile(
                  leading: Icon(Icons.save_alt, color: Colors.purple[400]),
                  title: Text("Save", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700])),
                  onTap: () async {
                    Navigator.of(context).pop();
                    List<int> fileBytes = await getFileBytes(index);
                    String path = await Shared.saveExistFile(fileName);
                    if (path == "null") return;
                    try {
                      File file = File(path);
                      file.writeAsBytesSync(fileBytes);
                      Shared.showToast("File saved successfully");
                    } catch(e) {
                      Shared.showToast("Exception: $e");
                    }
                  }
                ),

                ListTile(
                  leading: Icon(Icons.share, color: Colors.purple[400]),
                  title: Text("Share", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700])),
                  onTap: () async {
                    Navigator.of(context).pop();
                    List<int> fileBytes = await getFileBytes(index);
                    Directory tempDir = await getTemporaryDirectory();
                    String tempPath = "${tempDir.path}/$fileName";
                    File(tempPath).writeAsBytesSync(fileBytes);
                    await Share.shareFiles([tempPath], text: "Share $filePath");
                    // File(tempPath).deleteSync();
                  }
                ),

                // ListTile(
                //   leading: Icon(Icons.info, color: Colors.purple[400]),
                //   title: Text("Info", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700])),
                //   onTap: () {
                //     Navigator.of(context).pop();
                //
                //     showDialog(
                //       context: context,
                //       builder: (BuildContext context) => AlertDialog(
                //         title: Text(
                //           "File info",
                //           style: const TextStyle(fontWeight: FontWeight.bold)
                //         ),
                //
                //         content: Text(
                //           "Name:  $fileName\n\n"
                //               "Type:  ${fileName.contains(".") ? fileName.split(".").last : "Unknown"} file\n\n"
                //               "Size:  $fileSize Byte\n",
                //           style: const TextStyle(fontWeight: FontWeight.bold)
                //         ),
                //       )
                //     );
                //   }
                // ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<Widget> fullPathKey() async {
    List<Widget> headerNav = [const SizedBox(width: 10)];

    for (int i = 0; i < path.length - 1; i++) {
      headerNav.add(
          TextButton(
              onPressed: () {
                setState(() {
                  path = path.sublist(0, i + 1);
                });
              },
              child: Text(dirsName[path[i] - 1], style: TextStyle(fontSize: 18, color: Colors.grey[300]))
          )
      );

      headerNav.add(Icon(Icons.arrow_right, size: 30, color: Colors.grey[300]));
    }
    headerNav.add(Text(dirsName[path.last - 1], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)));
    headerNav.add(const SizedBox(width: 10));

    return SingleChildScrollView(
      child: Row(children: headerNav),
      scrollDirection: Axis.horizontal,
      reverse: true,
    );
  }

  Future<Widget> pageBody() async {
    response = await decodeFileKey();

    if (response != 0) {
      return Column(
        children: [
          SizedBox(height: Shared.height / 3),
          const Text(
              "Cannot decode this file",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)
          )
        ],
      );
    }

    List<Widget> body = [];

    // body.add(await fullPathKey());

    for (int i = 0; i < dirsParent.length; i++) {
      if (dirsParent[i] == path.last) {
        body.add(folderWidget(i + 1, dirsName[i]));
      }
    }

    for (int i = 0; i < filesParent.length; i++) {
      if (filesParent[i] == path.last) {
        body.add(fileWidget(i, filesName[i], filesSize[i]));
      }
    }


    if (body.isEmpty) {
      body.add(SizedBox(height: Shared.height / 3));
      body.add(const Center(child: Text("Empty folder", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))));
    }

    return Scaffold(
      backgroundColor: Shared.isDark ? Colors.black : Colors.white,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 35,
        backgroundColor: Colors.purple[400],
        title: SizedBox(child: await fullPathKey(), height: 40),
      ),

      body: SingleChildScrollView(child: Column(children: body)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (path.length == 1) {
          return true;
        } else {
          setState(() {
            path.removeLast();
          });
          return false;
        }
      },
      child: Scaffold(

        appBar: AppBar(
          backgroundColor: Colors.green[700],
          automaticallyImplyLeading: false,
          toolbarHeight: 60,

          title: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 60),

              Container(
                child: const Text("Current folder"),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.purple[400],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)
                  )
                ),
              ),
            ],
          ),

          actions: [
            // Padding(
            //   padding: const EdgeInsets.only(left: 0),
            //   child: PopupMenuButton(
            //     // icon: const Icon(Icons.info, size: 30),
            //       itemBuilder: (BuildContext context) {
            //         return [
            //           PopupMenuItem(
            //             child: const Text("Info"),
            //             textStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
            //             onTap: () {
            //
            //             },
            //           ),
            //
            //           PopupMenuItem(
            //             child: const Text("Save"),
            //             textStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
            //             onTap: () {
            //
            //             },
            //           ),
            //         ];
            //       }
            //   ),
            // ),

            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: IconButton(
                icon: const Icon(Icons.close, size: 30),

                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),

        body: SizedBox(
          width: double.infinity,
          child: FutureBuilder<Widget>(
              future: pageBody(),
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
              }
          ),
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () {

          },
          backgroundColor: const Color.fromRGBO(0, 255, 0, 0.2),
          child: const Icon(MdiIcons.folderCog,color: Colors.purple, size: 40),
          tooltip: "More",
        ),
      ),
    );
  }
}


class RootFolderSaver {
  String filePath;
  int rootFolderId;
  RootFolderSaver(this.filePath, this.rootFolderId);

  List<int> dirsParent = [];
  List<String> dirsName = [];
  int headerSize = 0;

  List<int> filesParent = [];
  List<String> filesName = [];
  List<int> filesSize = [];

  Future<int> decodeFileKey() async {
    dirsParent = [];
    dirsName = [];

    filesParent = [];
    filesName = [];
    filesSize = [];

    try {
      File file = File(filePath);

      List<int> bytes = await file.readAsBytes();

      int size = bytes.length;
      int firstLineEnd = bytes.indexOf(10);
      int secondLineEnd = bytes.indexOf(10, firstLineEnd + 1);
      headerSize = secondLineEnd + 1;

      String foldersKey = utf8.decode(bytes.sublist(0, firstLineEnd));
      String filesKey = utf8.decode(bytes.sublist(firstLineEnd + 1, secondLineEnd));

      List<String> dirsKeyParts = foldersKey.split(":");

      dirsParent = [for (String i in dirsKeyParts[0].split("/")) int.parse(i)];
      dirsName = dirsKeyParts[1].split("/");

      if (filesKey == "none") return 0;

      List<String> filesKeyParts = filesKey.split(":");
      int totalBytes = 0;

      filesParent = [for (String i in filesKeyParts[0].split("/")) int.parse(i)];
      filesName = filesKeyParts[2].split("/");
      for (String i in filesKeyParts[1].split("/")) {
        filesSize.add(int.parse(i));
        totalBytes += int.parse(i);
      }

      if (totalBytes + secondLineEnd + 1 != size) {
        return 1;
      }

      return 0;
    }
    catch (e){
      return 1;
    }
  }

  Future<List<int>> getFileBytes(int index) async {
    File file = File(filePath);
    List<int> bytes = await file.readAsBytes();

    int preBytes = headerSize;
    for (int i = 0; i < index; i++) {
      preBytes += filesSize[i];
    }

    return bytes.sublist(preBytes, preBytes + filesSize[index]);
  }
}









/*
await File(filePath)
        .openRead()
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .forEach((line) {
          if (i == 0) {
            foldersKey = line;
            i++;
          } else if (i == 1) {
            filesKey = line;
            i++;
          }
        });

Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: pageBody(), //[
            //pageBody(),
            // folderWidget(2, "My Folder"),
            //
            // folderWidget(3, "new Folder"),
            //
            // fileWidget(0, "Munir.png", 14710),
            //
            // fileWidget(1, "textFile.txt", 580),
          //],
        ),
*/

