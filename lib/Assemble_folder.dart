
import 'dart:io';
import 'dart:async';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'Shared.dart' show Shared;

class AssembleFolder extends StatefulWidget {
  const AssembleFolder({Key? key}) : super(key: key);

  @override
  State<AssembleFolder> createState() => _AssembleFolderState();
}

class _AssembleFolderState extends State<AssembleFolder> {
  String pickedFolderPath = "null";
  String editedPath = "null";
  bool assembled = false;
  final TextEditingController _fileNameController = TextEditingController();

  String selectedPlace = "App saved files";
  List<String> places = ["App saved files", "Internal storage"];

  List<String> getPathList() {
    List<String> dirs = editedPath.split("/");
    dirs.removeWhere((element) => element == "");
    return dirs;
  }

  Future<void> editPath() async {
    String appDocPath = (await getApplicationDocumentsDirectory()).path;
    String rootPath = (await ExternalPath.getExternalStorageDirectories())[0];

    if (pickedFolderPath.startsWith(appDocPath)) {
      editedPath = "Private storage"
          + pickedFolderPath.substring(appDocPath.length, pickedFolderPath.length);
    } else if (pickedFolderPath.startsWith(rootPath)) {
      editedPath = "External storage"
          + pickedFolderPath.substring(rootPath.length, pickedFolderPath.length);
    } else {
      editedPath = pickedFolderPath;
    }
  }

  Future<void> assembleToAppFiles() async {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Saving new file", style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _fileNameController,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[700]),

          inputFormatters: [LengthLimitingTextInputFormatter(120)],

          decoration: const InputDecoration(
            fillColor: Colors.white,
            filled: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12),
            hintText: "New file",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
        ),

        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              String name = Shared.nameValidator(_fileNameController.text);
              if (name == "/") {
                Shared.showToast("Invalid name");
                return;
              }
              name += ".${Shared.extension}";

              List<Map> response = await Shared.filesPath.readData("name = '$name'");
              if (response.isNotEmpty) {
                Shared.showToast("File name exists!!");
                return;
              }

              await Shared.filesPath.insertData(name);
              String assembledFilePath = (await getApplicationDocumentsDirectory()).path + "/$name";

              Assemble a = Assemble(pickedFolderPath, assembledFilePath);
              await a.writeFile();
              setState(() {
                assembled = true;
              });
            },
            child: const Text("Save", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> assembleToStorage() async {
    String assembledFilePath = await Shared.saveFile();

    if (assembledFilePath == "null") return;

    Assemble a = Assemble(pickedFolderPath, assembledFilePath);
    await a.writeFile();
    setState(() {
      assembled = true;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Shared.isDark ? Colors.black : Colors.white,
      resizeToAvoidBottomInset: false,

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
                              "Folder to ${Shared.extension}",
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

                    child: Card(
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
                          child: const Center(
                            child: Text(
                              "Pick Folder",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple
                              )
                            )
                          )
                        ),
                        onTap: () async {
                          String pickedPath = await Shared.pickFolder();

                          if (pickedPath != "null") {
                            pickedFolderPath = pickedPath;
                            await editPath();
                          }

                          setState(() {});
                        }
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Visibility(
              visible: pickedFolderPath == "null",
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
                        "No folder picked yet",
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
              visible: pickedFolderPath != "null",
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
                        "Picked Folder",
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

                  Container(
                    margin: const EdgeInsets.only(top: 20, bottom: 30, left: 10, right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(25)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Save to",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                          ),
                        ),

                        DropdownButton(
                          style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold ,color: Colors.black),
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
                              child: Icon(Icons.save_alt, size: 30, color: Colors.purple)
                            ),

                            SizedBox(
                              width: Shared.width - 170,
                              child: const Center(
                                child: Text(
                                  "Assemble & Save",
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
                        if (selectedPlace == places[0]) {
                          await assembleToAppFiles();
                        } else {
                          await assembleToStorage();
                        }
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


class Dir {
  String path;
  int id;
  int parentId;

  Dir(this.path, this.id, this.parentId);
}

class Assemble {
  String folderPath;
  String assembledFilePath;

  Assemble(this.folderPath, this.assembledFilePath);


  late List<String> filesPath;

  late String dirsParent;
  late String dirsName;

  late String filesParent;
  late String filesSize;
  late String filesName;

  late int id;

  Future<int> getKeys(Dir dir) async {
    dirsParent += "${dir.parentId}/";
    dirsName += "${dir.path.split("/").last}/";

    Directory _dir = Directory(dir.path);

    List<FileSystemEntity> entities = _dir.listSync()
      ..sort((l, r) => l.path.toLowerCase().compareTo(r.path.toLowerCase()));

    Iterable<File> files = entities.whereType<File>();
    Iterable<Directory> folders = entities.whereType<Directory>();

    for (File file in files) {
      filesPath.add(file.path);
      filesParent += "${dir.id}/";
      filesSize += "${file.lengthSync()}/";
      filesName += "${file.path.split("/").last}/";
    }

    for (FileSystemEntity folder in folders) {
      Dir newDir = Dir(folder.path, id++, dir.id);
      await getKeys(newDir);
    }
    return 0;
  }

  Future<int> callGetKeys() async {
    Dir dir = Dir(folderPath, 1, 0);
    filesPath = [];
    dirsParent = "";
    dirsName = "";

    filesParent = "";
    filesSize = "";
    filesName = "";
    id = 2;

    await getKeys(dir);
    return 0;
  }

  Future<int> writeFile() async {
    await callGetKeys();

    String key = dirsParent.substring(0, dirsParent.length - 1) + ":"
        + dirsName.substring(0, dirsName.length -1) + "\n";

    if (filesPath.isEmpty) {
      key += "none\n";
    } else {
      key += filesParent.substring(0, filesParent.length -1) + ":"
      + filesSize.substring(0, filesSize.length -1) + ":"
      + filesName.substring(0, filesName.length -1) + "\n";
    }

    File compressedFile = File(assembledFilePath);
    await compressedFile.writeAsString(key, mode: FileMode.write);
    for (String path in filesPath) {
      File file = File(path);
      List<int> bytes = await file.readAsBytes();
      await compressedFile.writeAsBytes(bytes, mode: FileMode.append);
    }

    return 0;
  }
}
