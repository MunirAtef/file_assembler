
import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:file_icon/file_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart/';
import 'Database.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:filesystem_picker/filesystem_picker.dart';
// import 'package:flutter_file_manager/flutter_file_manager.dart';


class Shared {
  static FilesPath filesPath = FilesPath();
  static bool isLoading = false;
  static bool isDark = true;

  static Color? fileWidgetColor = Colors.grey[900];
  static Color folderColor = Colors.green;

  static String extension = "pcf";
  static double width = 0;
  static double height = 0;
  static late BuildContext context;

  static String pickedFileSystem = "null";
  static String savedFilePath = "null";


  static Future<void> getMode() async {
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? isDark = prefs.getBool('isDarkMode');
    if (isDark != null) {
      Shared.isDark = isDark;
    }
  }

  static Future<String> getPass() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? pass = prefs.getString('password');
    if (pass == null) {
      await prefs.setString("password", "null");
      return "null";
    }

    return pass;
  }

  static void showToast(String msg) {
    Fluttertoast.showToast(msg: msg);
  }

  static Future<String> tempPath() async {
    Directory _path = await getApplicationDocumentsDirectory();
    final String filePath = _path.path + "/asmFile.$extension";

    return filePath;
  }

  static Future<String> pickFolder() async {
    pickedFileSystem = "null";
    await showDialog(
        context: context,
        builder: (context) =>
            StatefulBuilder(
              builder: (context, setState) {
                return const AlertDialog(
                  content: FolderPicker(),
                  contentPadding: EdgeInsets.zero,
                  insetPadding: EdgeInsets.symmetric(vertical: 70),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                );
              }
            )
    );

    return pickedFileSystem;
  }

  static Future<String> pickFile() async {
    pickedFileSystem = "null";
    await showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            double _width = MediaQuery.of(context).size.width;

            return AlertDialog(
              content: FilePicker(_width),
              contentPadding: EdgeInsets.zero,
              insetPadding: const EdgeInsets.symmetric(vertical: 70),
              clipBehavior: Clip.antiAliasWithSaveLayer,
            );
          }
        )
    );

    return pickedFileSystem;
  }

  static Future<String> pickFileFromSaved(bool isFavorite) async {
    pickedFileSystem = "null";
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {

          return AlertDialog(
            content: PickFromSaved(isFavorite),
            contentPadding: EdgeInsets.zero,
            insetPadding: const EdgeInsets.symmetric(vertical: 70),
            clipBehavior: Clip.antiAliasWithSaveLayer,
          );
        }
      )
    );
    return pickedFileSystem;
  }

  static Future<String> saveFile() async {
    savedFilePath = "null";

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FileSaver(true, true, "null")),
    );

    return savedFilePath;
  }

  static Future<String> saveExistFile(String name) async {
    savedFilePath = "null";

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FileSaver(false, true, name)),
    );

    return savedFilePath;
  }

  static Future<String> saveFolder(String name) async {
    savedFilePath = "null";

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FileSaver(false, false, name)),
    );

    return savedFilePath;
  }

  static String covertFileSize(int fileSize) {
    if (fileSize >= 1073741824) {
      return (fileSize / 1073741824).toStringAsFixed(1) + " GB";
    } else if (fileSize >= 1048576) {
      return (fileSize / 1048576).toStringAsFixed(1) + " MB";
    } else if (fileSize >= 1024) {
      return (fileSize / 1024).toStringAsFixed(1) + " KB";
    } else {
      return fileSize.toString() + " B";
    }
  }

  static void clearTempDir() async {
    Directory dir = await getTemporaryDirectory();
    dir.deleteSync(recursive: true);
    dir.createSync();
  }

  static String nameValidator(String name) {
    List<String> notAllowed = [":", "/", "\\", "\"", ">", "<", "|", "*", "?", "\n"];

    for (int i = 0; i < name.length; i++) {
      if (notAllowed.contains(name[i])) {
        return "/";
      }
    }

    if (name.trim().isEmpty) {
      return "/";
    }

    return name.trim();
  }

  static void loading(String title) {
    showDialog(
      context: context,
      builder: (context) => WillPopScope(
        onWillPop: () async {
          return false;
        },

        child: AlertDialog(
          backgroundColor: const Color.fromRGBO(255, 255, 255, 0.6),
          title: Center(child: Text(title)),
          content: const LinearProgressIndicator(color: Colors.pinkAccent),
        ),
      )
    );
  }
}


// ignore: must_be_immutable
class FileSaver extends StatefulWidget {
  bool isNew;
  bool isFile;
  String defaultName;

  FileSaver(this.isNew, this.isFile, this.defaultName, {Key? key}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<FileSaver> createState() => _FileSaverState(isNew, isFile, defaultName);
}

class _FileSaverState extends State<FileSaver> {
  bool isNew;
  bool isFile;
  String defaultName;
  _FileSaverState(this.isNew, this.isFile, this.defaultName);

  String currentPath = "null";
  String rootPath = "null";
  bool inHome = true;
  bool sortByName = true;

  final TextEditingController fileNameController = TextEditingController();
  final TextEditingController folderNameController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    if (!isNew) {
      fileNameController.text = defaultName;
    }

    super.initState();
  }



  Widget folderWidget(String folderName) {
    return Card(
      color: Shared.isDark ? Colors.grey[900] : Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.fromLTRB(2, 2, 2, 0),

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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Shared.isDark ? Colors.grey[200] : Colors.grey[900],
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
            currentPath += "/$folderName";
            inHome = false;
          });
        },
      ),
    );
  }

  Widget fileWidget(String fileName) {
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

                FileIcon(fileName, size: 45),

                const SizedBox(width: 10),

                SizedBox(
                  width: Shared.width - 100,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      fileName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Shared.isDark ? Colors.grey[200] : Colors.grey[900],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Widget> listFolder() async {
    if (currentPath == "null") {
      List<String> _rootPath = await ExternalPath.getExternalStorageDirectories();
      currentPath = _rootPath[0];
      rootPath = _rootPath[0];
    }
    Directory _dir = Directory(currentPath);

    List<FileSystemEntity> entities;

    if (sortByName) {
      entities = _dir.listSync()
        ..sort((l, r) => l.path.toLowerCase().compareTo(r.path.toLowerCase()));
    } else {
      entities = _dir.listSync()
        ..sort((l, r) => r.statSync().modified.compareTo(l.statSync().modified));
    }

    Iterable<Directory> folders = entities.whereType<Directory>();
    Iterable<File> files = entities.whereType<File>();

    List<Widget> body = [];

    for (Directory folder in folders) {
      body.add(folderWidget(folder.path.split("/").last));
    }

    if (isFile) {
      if (isNew) {
        for (File file in files) {
          if (file.path.split(".").last == Shared.extension) {
            body.add(fileWidget(file.path.split("/").last));
          }
        }
      } else {
        for (File file in files) {
          body.add(fileWidget(file.path.split("/").last));
        }
      }
    }

    List<String> selectedPath = currentPath != rootPath ?
    currentPath.substring(rootPath.length + 1, currentPath.length).split("/") : [];

    selectedPath.insert(0, "Internal storage");

    return Scaffold(
      backgroundColor: Shared.isDark ? Colors.black : Colors.white,

      body: SingleChildScrollView(
        child: Column(
          children: body,
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[400],

        child: isNew ?
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 45,
              width: Shared.width - 140,

              child: TextField(
                controller: fileNameController,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[700]),

                inputFormatters: [LengthLimitingTextInputFormatter(120)],

                decoration: const InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  hintText: "Untitled",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                ),
              ),
            ),

            Container(
              height: 45,
              padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
              margin: const EdgeInsets.fromLTRB(0, 8, 8, 8),
              decoration: BoxDecoration(
                color: Colors.purple[400],
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Text(
                  ".${Shared.extension}",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                  )
                )
              ),
            ),

            ElevatedButton(
              onPressed: () {
                if (fileNameController.text.isEmpty) {
                  Shared.showToast("No name entered");
                  return;
                }
                String name = Shared.nameValidator(fileNameController.text + ".${Shared.extension}");
                if (name == "/") {
                  Shared.showToast("Invalid name");
                  return;
                }

                String savedFilePath = currentPath + "/" + name;

                File file = File(savedFilePath);
                if (file.existsSync()) {
                  showDialog<String>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text(
                        "Warning!!",
                        style: TextStyle(fontWeight: FontWeight.bold)
                      ),

                      content: const Text(
                        "file already exists\nDo you want to replace it?",
                        style: TextStyle(fontWeight: FontWeight.bold)
                      ),

                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(fontWeight: FontWeight.bold)
                          )
                        ),

                        TextButton(
                          onPressed: () {
                            file.deleteSync();

                            Shared.savedFilePath = savedFilePath;
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            "Replace",
                            style: TextStyle(fontWeight: FontWeight.bold)
                          )
                        )
                      ],
                    ),
                  );
                } else {
                  Shared.savedFilePath = savedFilePath;
                  Navigator.of(context).pop();
                }
              },

              child: const Text("Save"),
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.purple[400])),
            )
          ],
        )

        : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 61,
              width: Shared.width - 100,

              child: Center(
                child: TextField(
                  controller: fileNameController,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[700]),

                  inputFormatters: [LengthLimitingTextInputFormatter(120)],

                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            ElevatedButton(
              onPressed: () {
                if (fileNameController.text.isEmpty) {
                  Shared.showToast("No name entered");
                  return;
                }
                String name = Shared.nameValidator(fileNameController.text);
                if (name == "/") {
                  Shared.showToast("Invalid name");
                  return;
                }

                String savedFilePath = currentPath + "/" + name;

                bool isExists = false;

                if (isFile) {
                  isExists = File(savedFilePath).existsSync();
                } else {
                  isExists = Directory(savedFilePath).existsSync();
                }


                if (isExists) {
                  showDialog<String>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text(
                        "Warning!!",
                        style: TextStyle(
                            fontWeight: FontWeight.bold
                        )
                      ),

                      content: Text(
                        (isFile ? "File" : "Folder") +
                          " already exists\nDo you want to replace it?",

                        style: const TextStyle(fontWeight: FontWeight.bold)
                      ),

                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(fontWeight: FontWeight.bold)
                          )
                        ),

                        TextButton(
                          onPressed: () {
                            if (isFile) {
                              File(savedFilePath).deleteSync();
                            } else {
                              Directory(savedFilePath).deleteSync(recursive: true);
                            }

                            Shared.savedFilePath = savedFilePath;
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            "Replace",
                            style: TextStyle(fontWeight: FontWeight.bold)
                          )
                        )
                      ],
                    ),
                  );
                } else {
                  Shared.savedFilePath = savedFilePath;
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Save"),
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.purple[400])),
            )
          ],
        )
      ),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.purple[400],
        toolbarHeight: 35,

        title: SizedBox(
          height: 40,

          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(
              children: [
                const SizedBox(width: 10),

                for (int i = 0; i < selectedPath.length - 1; i++)
                  Row(
                    children: [
                      TextButton(
                          onPressed: () {
                            if (i == 0) {
                              setState(() {
                                currentPath = rootPath;
                                inHome = true;
                              });
                              return;
                            }
                            String extraPath = selectedPath.sublist(1, i + 1)
                                .join("/");
                            setState(() {
                              currentPath = rootPath + "/" + extraPath;
                            });
                          },
                          child: Text(selectedPath[i], style: TextStyle(
                              fontSize: 18, color: Colors.grey[300]))),

                      Icon(Icons.arrow_right, size: 30,
                          color: Colors.grey[300])
                    ],
                  ),

                Text(
                    selectedPath.last,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold
                    )
                ),

                const SizedBox(width: 10)
              ],
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text("Creating new folder", style: TextStyle(fontWeight: FontWeight.bold)),
              content: TextField(
                controller: folderNameController,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[700]),

                inputFormatters: [LengthLimitingTextInputFormatter(120)],

                decoration: const InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  hintText: "New folder",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    try {
                      String name = Shared.nameValidator(folderNameController.text);
                      if (name == "/") {
                        Shared.showToast("Invalid name");
                      } else {
                        Navigator.of(context).pop();
                        String newPath = currentPath + "/" + name;

                        if (Directory(newPath).existsSync()) {
                          Shared.showToast("Folder already exists");
                        } else {
                          Directory(newPath).createSync();
                        }

                        setState(() {
                          currentPath = newPath;
                        });
                      }
                    } catch(e) {
                      Shared.showToast("Exception: $e");
                    }
                  },
                  child: const Text("Create", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.create_new_folder, size: 40, color: Colors.purple),
        tooltip: "Create new folder",
        backgroundColor: const Color.fromRGBO(0, 255, 0, 0.2),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        if (currentPath == rootPath) {
          return true;
        } else {
          setState(() {
            currentPath = currentPath.substring(0, currentPath.lastIndexOf("/"));
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
                child: Text("Save ${isFile ? "file" : "folder"} to"),
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
            //   padding: const EdgeInsets.symmetric(horizontal: 10),
            //   child: Visibility(
            //       visible: !inHome,
            //       child: IconButton(
            //         icon: const Icon(Icons.arrow_back, size: 30),
            //
            //         onPressed: () {
            //           setState(() {
            //             currentPath = Directory(currentPath).parent.path;
            //             inHome = currentPath == rootPath;
            //           });
            //         },
            //       )
            //   ),
            // ),

            PopupMenuButton(
                icon: const Icon(Icons.sort, size: 30),
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem(
                      enabled: !sortByName,
                      child: const Text("Sort by name"),
                      textStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
                      onTap: () {
                        setState(() {
                          sortByName = true;
                        });
                      },
                    ),

                    PopupMenuItem(
                      enabled: sortByName,
                      child: const Text("Sort by last modified"),
                      textStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
                      onTap: () {
                        setState(() {
                          sortByName = false;
                        });
                      },
                    ),
                  ];
                }
            ),

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
              future: listFolder(),
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
      ),
    );
  }
}


class FilePicker extends StatefulWidget {
  final double _width;
  const FilePicker(this._width, {Key? key}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<FilePicker> createState() => _FilePickerState(_width);
}

class _FilePickerState extends State<FilePicker> {
  final double _width;
  _FilePickerState(this._width);

  String currentPath = "null";
  String rootPath = "null";
  bool inHome = true;
  bool sortByName = true;  // true by name, false by last modified


  Widget folderWidget(String folderName) {
    return Card(
      color: Shared.isDark ? Colors.grey[900] : Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.fromLTRB(2, 2, 2, 0),

      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: _width - 5,
          height: 50,
          child: Center(
            child: Row(
              children: [
                const SizedBox(width: 5),
                Icon(Icons.folder, size: 40, color: Colors.amber[600]),
                const SizedBox(width: 5),

                SizedBox(
                  width: _width - 180,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      folderName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Shared.isDark ? Colors.grey[200] : Colors.grey[900],
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
            currentPath += "/$folderName";
            inHome = false;
          });
        },
      ),
    );
  }

  Widget fileWidget(String fileName) {
    return Card(
      color: Shared.isDark ? Colors.grey[900] : Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.fromLTRB(2,2,2,0),

      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: _width - 5,
          height: 50,
          child: Center(
            child: Row(
              children: [
                const SizedBox(width: 5),

                // FileIcon(fileName, size: 40),
                Icon(Icons.insert_drive_file, size: 40, color: Colors.purple[400]),

                const SizedBox(width: 5),

                SizedBox(
                  width: _width - 180,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      fileName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Shared.isDark ? Colors.grey[200] : Colors.grey[900],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          Shared.pickedFileSystem = currentPath + "/" + fileName;
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<Widget> listFolder() async {
    if (currentPath == "null") {
      String _rootPath = (await ExternalPath.getExternalStorageDirectories())[0];
      currentPath = _rootPath;
      rootPath = _rootPath;
    }
    Directory _dir = Directory(currentPath);

    List<FileSystemEntity> entities;

    if (sortByName) {
      //sorting by name
      entities = _dir.listSync()
        ..sort((l, r) => l.path.toLowerCase().compareTo(r.path.toLowerCase()));
    } else {
      //sorting by last modified
      entities = _dir.listSync()
        ..sort((l, r) => r.statSync().modified.compareTo(l.statSync().modified));
    }

    // List<FileSystemEntity> entities = await _dir.list().toList();

    Iterable<Directory> folders = entities.whereType<Directory>();
    Iterable<File> files = entities.whereType<File>();

    List<Widget> body = [];

    for (Directory folder in folders) {
      body.add(folderWidget(folder.path.split("/").last));
    }

    for (File file in files) {
      if (file.path.split(".").last == Shared.extension) {
        body.add(fileWidget(file.path.split("/").last));
      }
    }

    List<String> selectedPath = currentPath != rootPath ? currentPath
        .substring(rootPath.length + 1, currentPath.length).split("/") : [];
    selectedPath.insert(0, "Internal storage");

    return Scaffold(
      backgroundColor: Shared.isDark ? Colors.black : Colors.white,

      body: SingleChildScrollView(
        child: Column(
          children: body,
        ),
      ),

      appBar: AppBar(
        toolbarHeight: 30,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.purple[400],

        title: SizedBox(
          height: 50,

          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(
              children: [

                for (int i = 0; i < selectedPath.length - 1; i++)
                  Row(
                    children: [
                      TextButton(
                          onPressed: () {
                            if (i == 0) {
                              setState(() {
                                currentPath = rootPath;
                                inHome = true;
                              });
                              return;
                            }
                            String extraPath = selectedPath.sublist(1, i + 1).join("/");
                            setState(() {
                              currentPath = rootPath + "/" + extraPath;
                            });
                          },
                          child: Text(selectedPath[i], style: TextStyle(
                              fontSize: 15, color: Colors.grey[300]))),

                      Icon(Icons.arrow_right, size: 20, color: Colors.grey[300])
                    ],
                  ),

                Text(selectedPath.last, style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold)),

                const SizedBox(width: 10)
              ],
            ),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        automaticallyImplyLeading: false,
        toolbarHeight: 60,
        // elevation: 0,

        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 60),

            Container(
              child: Text("Pick ${Shared.extension} file", style: const TextStyle(fontSize: 15)),
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
          PopupMenuButton(
              icon: const Icon(Icons.sort, size: 20),
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    enabled: !sortByName,
                    child: const Text("Sort by name"),
                    textStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
                    onTap: () {
                      setState(() {
                        sortByName = true;
                      });
                    },
                  ),

                  PopupMenuItem(
                    enabled: sortByName,
                    child: const Text("Sort by last modified"),
                    textStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
                    onTap: () {
                      setState(() {
                        sortByName = false;
                      });
                    },
                  ),
                ];
              }
          ),

          Visibility(
              visible: !inHome,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),

                onPressed: () {
                  setState(() {
                    currentPath = Directory(currentPath).parent.path;
                    inHome = currentPath == rootPath;
                  });
                },
              )
          ),
        ],
      ),

      body: SizedBox(
        width: double.infinity,
        child: FutureBuilder<Widget>(
            future: listFolder(),
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
    );
  }
}


class FolderPicker extends StatefulWidget {
  const FolderPicker({Key? key}) : super(key: key);

  @override
  State<FolderPicker> createState() => _FolderPickerState();
}

class _FolderPickerState extends State<FolderPicker> {
  String currentPath = "null";
  String rootPath = "null";
  bool inHome = true;
  bool sortByName = true;


  Widget folderWidget(String folderName) {
    return Card(
      color: Shared.isDark ? Colors.grey[900] : Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.fromLTRB(2, 2, 2, 0),

      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 290,
          height: 50,
          child: Center(
            child: Row(
              children: [
                const SizedBox(width: 5),
                Icon(Icons.folder, size: 40, color: Colors.amber[600]),
                const SizedBox(width: 5),

                SizedBox(
                  width: 210,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      folderName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Shared.isDark ? Colors.grey[200] : Colors.grey[900],
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
            currentPath += "/$folderName";
            inHome = false;
          });
        },
      ),
    );
  }


  Future<Widget> listFolder() async {
    if (currentPath == "null") {
      List<String> _rootPath = await ExternalPath.getExternalStorageDirectories();
      currentPath = _rootPath[0];
      rootPath = _rootPath[0];
    }
    Directory _dir = Directory(currentPath);

    List<FileSystemEntity> entities;

    if (sortByName) {
      //sorting by name
      entities = _dir.listSync()
        ..sort((l, r) => l.path.toLowerCase().compareTo(r.path.toLowerCase()));
    } else {
      //sorting by last modified
      entities = _dir.listSync()
        ..sort((l, r) => r.statSync().modified.compareTo(l.statSync().modified));
    }

    // List<FileSystemEntity> entities = await _dir.list().toList();

    Iterable<Directory> folders = entities.whereType<Directory>();

    List<Widget> body = [];

    for (Directory folder in folders) {
      body.add(folderWidget(folder.path.split("/").last));
    }

    List<String> selectedPath = currentPath != rootPath ? currentPath.substring(rootPath.length + 1, currentPath.length).split("/") : [];
    selectedPath.insert(0, "Internal storage");

    return Scaffold(
      backgroundColor: Shared.isDark ? Colors.black : Colors.white,

      body: SingleChildScrollView(
        child: Column(
          children: body,
        ),
      ),

      appBar: AppBar(
        toolbarHeight: 30,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.purple[400],

        title: SizedBox(
          height: 50,

          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(
              children: [

                for (int i = 0; i < selectedPath.length - 1; i++)
                  Row(
                    children: [
                      TextButton(
                          onPressed: () {
                            if (i == 0) {
                              setState(() {
                                currentPath = rootPath;
                                inHome = true;
                              });
                              return;
                            }
                            String extraPath = selectedPath.sublist(1, i + 1).join("/");
                            setState(() {
                              currentPath = rootPath + "/" + extraPath;
                            });
                          },
                          child: Text(selectedPath[i], style: TextStyle(
                              fontSize: 15, color: Colors.grey[300]))),

                      Icon(Icons.arrow_right, size: 20,
                          color: Colors.grey[300])
                    ],
                  ),

                Text(selectedPath.last, style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold)),

                const SizedBox(width: 10)
              ],
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Shared.pickedFileSystem = currentPath;
          Navigator.of(context).pop();
        },

        backgroundColor: const Color.fromRGBO(0, 255, 0, 0.2),
        child: const Icon(Icons.check_circle_outline,color: Colors.purple, size: 40),
        tooltip: "Pick",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        automaticallyImplyLeading: false,
        toolbarHeight: 60,

        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 60),

            Container(
              child: const Text("Pick this folder", style: TextStyle(fontSize: 15)),
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
          PopupMenuButton(
              icon: const Icon(Icons.sort, size: 20),
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    enabled: !sortByName,
                    child: const Text("Sort by name"),
                    textStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
                    onTap: () {
                      setState(() {
                        sortByName = true;
                      });
                    },
                  ),

                  PopupMenuItem(
                    enabled: sortByName,
                    child: const Text("Sort by last modified"),
                    textStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
                    onTap: () {
                      setState(() {
                        sortByName = false;
                      });
                    },
                  ),
                ];
              }
          ),

          Visibility(
              visible: !inHome,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),

                onPressed: () {
                  setState(() {
                    currentPath = Directory(currentPath).parent.path;
                    inHome = currentPath == rootPath;
                  });
                },
              )
          ),
        ],
      ),

      body: SizedBox(
        width: double.infinity,
        child: FutureBuilder<Widget>(
            future: listFolder(),
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
    );
  }
}



class PickFromSaved extends StatefulWidget {
  final bool isFavorite;
  const PickFromSaved(this.isFavorite, {Key? key}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<PickFromSaved> createState() => _PickFromSavedState(isFavorite);
}

class _PickFromSavedState extends State<PickFromSaved> {
  bool isFavorite;
  _PickFromSavedState(this.isFavorite);

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
          width: Shared.width - 100,
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
                      width: Shared.width - 190,
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
              ],
            ),
          ),
        ),
        onTap: () {
          Shared.pickedFileSystem = filePath;
          Navigator.of(Shared.context).pop();
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
                isFavorite ? "No favorite files" : "No saved files",
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

    return Scaffold(
      backgroundColor: Shared.isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Shared.isDark ? Colors.black : Colors.white,
        toolbarHeight: 80,
        titleSpacing: 0,

        title: Container(
          height: 80,
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
            child: Container(
              height: 70,
              margin: const EdgeInsets.only(top: 20),
              child: Center(
                child: Text(
                  isFavorite ? "Favorite" : "Saved Files",
                  style: GoogleFonts.tangerine(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 45,
                  )
                ),
              ),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: body,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      body: SizedBox(
        width: double.infinity,
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
    );
  }
}


/*
class FileSaver extends StatefulWidget {
  final double _width;
  bool isNewFile;
  String defaultName;

  FileSaver(this._width, this.isNewFile, this.defaultName, {Key? key}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<FileSaver> createState() => _FileSaverState(_width, isNewFile, defaultName);
}

class _FileSaverState extends State<FileSaver> {
  final double _width;
  bool isNewFile;
  String defaultName;
  _FileSaverState(this._width, this.isNewFile, this.defaultName);

  String currentPath = "null";
  String rootPath = "null";
  bool inHome = true;
  bool sortByName = true;

  final TextEditingController fileNameController = TextEditingController();
  final TextEditingController folderNameController = TextEditingController();

  @override
  void initState() {
    TODO: implement initState
    if (!isNewFile) {
      fileNameController.text = defaultName;
    }

    super.initState();
  }

  String nameValidator(String name) {
    List<String> notAllowed = [":", "/", "\\", "\"", ">", "<", "|", "*", "?", "\n"];

    for (int i = 0; i < name.length; i++) {
      if (notAllowed.contains(name[i])) {
        return "/";
      }
    }

    if (name.trim().isEmpty) {
      return "/";
    }

    return name.trim();
  }

  Widget folderWidget(String folderName) {
    return Card(
      color: Shared.isDark ? Colors.grey[900] : Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.fromLTRB(2, 2, 2, 0),

      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: _width - 5,
          height: 50,
          child: Center(
            child: Row(
              children: [
                const SizedBox(width: 5),
                Icon(Icons.folder, size: 40, color: Colors.amber[600]),
                const SizedBox(width: 5),

                SizedBox(
                  width: _width - 180,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      folderName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Shared.isDark ? Colors.grey[200] : Colors.grey[900],
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
            currentPath += "/$folderName";
            inHome = false;
          });
        },
      ),
    );
  }

  Widget fileWidget(String fileName) {
    return Card(
      color: Shared.isDark ? Colors.grey[900] : Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.fromLTRB(2,2,2,0),

      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: _width - 5,
          height: 50,
          child: Center(
            child: Row(
              children: [
                const SizedBox(width: 5),

                // FileIcon(fileName, size: 40),
                Icon(Icons.insert_drive_file, size: 40, color: Colors.purple[400]),

                const SizedBox(width: 5),

                SizedBox(
                  width: _width - 180,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      fileName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Shared.isDark ? Colors.grey[200] : Colors.grey[900],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          Shared.pickedFileSystem = currentPath + "/" + fileName;
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<Widget> listFolder() async {
    if (currentPath == "null") {
      List<String> _rootPath = await ExternalPath.getExternalStorageDirectories();
      currentPath = _rootPath[0];
      rootPath = _rootPath[0];
    }
    Directory _dir = Directory(currentPath);

    List<FileSystemEntity> entities;

    if (sortByName) {
      //sorting by name
      entities = _dir.listSync()
        ..sort((l, r) => l.path.toLowerCase().compareTo(r.path.toLowerCase()));
    } else {
      //sorting by last modified
      entities = _dir.listSync()
        ..sort((l, r) => r.statSync().modified.compareTo(l.statSync().modified));
    }

    Iterable<Directory> folders = entities.whereType<Directory>();
    Iterable<File> files = entities.whereType<File>();

    List<Widget> body = [];

    for (Directory folder in folders) {
      body.add(folderWidget(folder.path.split("/").last));
    }

    if (isNewFile) {
      for (File file in files) {
        if (file.path.split(".").last == Shared.extension) {
          body.add(fileWidget(file.path.split("/").last));
        }
      }
    } else {
      for (File file in files) {
        body.add(fileWidget(file.path.split("/").last));
      }
    }

    List<String> selectedPath = currentPath != rootPath ?
    currentPath.substring(rootPath.length + 1, currentPath.length).split("/") : [];

    selectedPath.insert(0, "Internal storage");

    return Scaffold(
      backgroundColor: Shared.isDark ? Colors.black : Colors.white,

      body: SingleChildScrollView(
        child: Column(
          children: body,
        ),
      ),

      bottomNavigationBar: BottomAppBar(
          color: Colors.grey[400],

          child: isNewFile ?
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 45,
                width: Shared.width - 180,

                child: TextField(
                  controller: fileNameController,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[700]),

                  inputFormatters: [LengthLimitingTextInputFormatter(120)],

                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    hintText: "Untitled",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),

              Container(
                height: 45,
                padding: const EdgeInsets.fromLTRB(3, 3, 7, 3),
                margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                decoration: BoxDecoration(
                  color: Colors.purple[400],
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Center(
                    child: Text(
                        ".${Shared.extension}",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                        )
                    )
                ),
              ),

              IconButton(
                onPressed: () {
                  if (fileNameController.text.isEmpty) {
                    Shared.showToast("No name entered");
                    return;
                  }
                  String name = nameValidator(fileNameController.text + ".${Shared.extension}");
                  if (name == "/") {
                    Shared.showToast("Invalid name");
                    return;
                  }

                  String savedFilePath = currentPath + "/" + name;

                  File file = File(savedFilePath);
                  if (file.existsSync()) {
                    showDialog<String>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text(
                            "Warning!!",
                            style: TextStyle(
                                fontWeight: FontWeight.bold
                            )
                        ),

                        content: const Text(
                            "File already exists\nDo you want to replace it?",
                            style: TextStyle(
                                fontWeight: FontWeight.bold
                            )
                        ),

                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                  "Cancel",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  )
                              )
                          ),

                          TextButton(
                              onPressed: () {
                                file.deleteSync();
                                Shared.savedFilePath = savedFilePath;
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                  "Replace",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  )
                              )
                          )
                        ],
                      ),
                    );
                  } else {
                    Shared.savedFilePath = savedFilePath;
                    Navigator.of(context).pop();
                  }
                },
                icon: Icon(Icons.done_outline, color: Colors.purple[400]),
                // style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.purple[400])),
              )
            ],
          )

              : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 53,
                    width: Shared.width - 140,

                    child: Center(
                      child: TextField(
                        controller: fileNameController,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[700]),

                        inputFormatters: [LengthLimitingTextInputFormatter(120)],

                        decoration: const InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      if (fileNameController.text.isEmpty) {
                        Shared.showToast("No name entered");
                        return;
                      }
                      String name = nameValidator(fileNameController.text);
                      if (name == "/") {
                        Shared.showToast("Invalid name");
                        return;
                      }

                      String savedFilePath = currentPath + "/" + name;

                      File file = File(savedFilePath);
                      if (file.existsSync()) {
                        showDialog<String>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text(
                                "Warning!!",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold
                                )
                            ),

                            content: const Text(
                                "File already exists\nDo you want to replace it?",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold
                                )
                            ),

                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                      "Cancel",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold
                                      )
                                  )
                              ),

                              TextButton(
                                  onPressed: () {
                                    file.deleteSync();
                                    Shared.savedFilePath = savedFilePath;
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                      "Replace",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold
                                      )
                                  )
                              )
                            ],
                          ),
                        );
                      } else {
                        Shared.savedFilePath = savedFilePath;
                        Navigator.of(context).pop();
                      }
                    },
                    icon: Icon(Icons.done_outline, color: Colors.purple[400]),
                  )
            ],
          )
      ),

      appBar: AppBar(
        toolbarHeight: 30,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.purple[400],

        title: SizedBox(
          height: 50,

          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(
              children: [

                for (int i = 0; i < selectedPath.length - 1; i++)
                  Row(
                    children: [
                      TextButton(
                          onPressed: () {
                            if (i == 0) {
                              setState(() {
                                currentPath = rootPath;
                                inHome = true;
                              });
                              return;
                            }
                            String extraPath = selectedPath.sublist(1, i + 1).join("/");
                            setState(() {
                              currentPath = rootPath + "/" + extraPath;
                            });
                          },
                          child: Text(selectedPath[i], style: TextStyle(
                              fontSize: 15, color: Colors.grey[300]))),

                      Icon(Icons.arrow_right, size: 20,
                          color: Colors.grey[300])
                    ],
                  ),

                Text(selectedPath.last, style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold)),

                const SizedBox(width: 10)
              ],
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text("Creating new folder", style: TextStyle(fontWeight: FontWeight.bold)),
              content: TextField(
                controller: folderNameController,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[700]),

                inputFormatters: [LengthLimitingTextInputFormatter(120)],

                decoration: const InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  hintText: "New folder",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    try {
                      String name = nameValidator(folderNameController.text);
                      if (name == "/") {
                        Shared.showToast("Invalid name");
                      } else {
                        Navigator.of(context).pop();
                        String newPath = currentPath + "/" + name;

                        if (Directory(newPath).existsSync()) {
                          Shared.showToast("Folder already exists");
                        } else {
                          Directory(newPath).createSync();
                        }

                        setState(() {
                          currentPath = newPath;
                        });
                      }
                    } catch(e) {
                      Shared.showToast("Exception: $e");
                    }
                  },
                  child: const Text("Create", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.create_new_folder, size: 35, color: Colors.amber),
        backgroundColor: Colors.green[700],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        automaticallyImplyLeading: false,
        toolbarHeight: 60,
        // elevation: 0,

        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 60),

            Container(
              child: const Text("Save file to", style: TextStyle(fontSize: 15)),
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
          PopupMenuButton(
              icon: const Icon(Icons.sort, size: 20),
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    enabled: !sortByName,
                    child: const Text("Sort by name"),
                    textStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
                    onTap: () {
                      setState(() {
                        sortByName = true;
                      });
                    },
                  ),

                  PopupMenuItem(
                    enabled: sortByName,
                    child: const Text("Sort by last modified"),
                    textStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
                    onTap: () {
                      setState(() {
                        sortByName = false;
                      });
                    },
                  ),
                ];
              }
          ),

          Visibility(
              visible: !inHome,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),

                onPressed: () {
                  setState(() {
                    currentPath = Directory(currentPath).parent.path;
                    inHome = currentPath == rootPath;
                  });
                },
              )
          ),
        ],
      ),

      body: SizedBox(
        width: double.infinity,
        child: FutureBuilder<Widget>(
            future: listFolder(),
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
    );
  }
}
*/


// static Future<String> pickFolder2() async {
//   List<String> rootPath = await ExternalPath.getExternalStorageDirectories();
//
//   String? path = await FilesystemPicker.open(
//     title: 'Pick folder',
//     context: context,
//     rootDirectory: Directory(rootPath[0]),
//     fsType: FilesystemType.folder,
//     folderIconColor: Shared.folderColor,
//
//     fileTileSelectMode: FileTileSelectMode.wholeTile,
//   );
//
//   return path ?? "null";
// }
//
// static Future<String> pickFile2() async {
//   List<String> rootPath = await ExternalPath.getExternalStorageDirectories();
//
//   String? path = await FilesystemPicker.open(
//     title: 'Pick ${Shared.extension} file',
//     context: context,
//     rootDirectory: Directory(rootPath[0]),
//     fsType: FilesystemType.file,
//     folderIconColor: Shared.folderColor,
//     allowedExtensions: [".${Shared.extension}"],
//
//     fileTileSelectMode: FileTileSelectMode.wholeTile,
//   );
//
//   return path ?? "null";
// }
//
// static Future<int> saveFile(context) async {
//   List<String> rootPath = await ExternalPath.getExternalStorageDirectories();
//   final String filePath = await Shared.tempPath();
//
//   File compressedFile = File(filePath);
//   bool exist = await compressedFile.exists();
//
//   if (exist) {
//     FileSaver fileSaver = FileSaver(
//       fileTypes: [Shared.extension],
//       initialFileName: 'Assembled',
//       initialDirectory: Directory(rootPath[0]),
//     );
//     List<int> bytes = await compressedFile.readAsBytes();
//     File? fileResponse = await fileSaver.writeAsBytes(bytes, context: context);
//     if (fileResponse != null) {
//       await compressedFile.delete();
//       return 0;
//     } else {
//       return 1;
//     }
//   } else {
//     return 1;
//   }
// }
//
// static Future<String> pickFile3() async {
// pickedFileSystem = "null";
//
// await Navigator.push(
// context,
// MaterialPageRoute(builder: (context) => const FilePicker3()),
// );
//
// return pickedFileSystem;
// }

/*
class FilePicker3 extends StatefulWidget {
  const FilePicker3({Key? key}) : super(key: key);

  @override
  State<FilePicker3> createState() => _FilePickerState3();
}

class _FilePickerState3 extends State<FilePicker3> {
  String currentPath = "null";
  String rootPath = "null";
  bool inHome = true;
  bool sortByName = true;  // true by name, false by last modified

  @override
  Widget build(BuildContext context) {

    Widget folderWidget(String folderName) {
      return Card(
        color: Colors.grey[200],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(2, 2, 2, 0),

        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: double.infinity,
            height: 80,
            child: Center(
              child: Row(
                children: [
                  const SizedBox(width: 10),

                  const Icon(Icons.folder, size: 55, color: Colors.amber),

                  const SizedBox(width: 10),

                  SizedBox(
                    width: Shared.width - 100,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        folderName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          onTap: () {
            setState(() {
              currentPath += "/$folderName";
              inHome = false;
            });
          },
        ),
      );
    }

    Widget fileWidget(String fileName) {
      return Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(2,2,2,0),

        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: double.infinity,
            height: 80,
            child: Center(
              child: Row(
                children: [
                  const SizedBox(width: 10),

                  FileIcon(fileName, size: 60),

                  const SizedBox(width: 10),

                  SizedBox(
                    width: Shared.width - 100,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        fileName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          onTap: () {
            Shared.pickedFileSystem = currentPath + "/" + fileName;
            Navigator.of(context).pop();
          },
        ),
      );
    }

    Future<Widget> listFolder() async {
      if (currentPath == "null") {
        List<String> _rootPath = await ExternalPath.getExternalStorageDirectories();
        currentPath = _rootPath[0];
        rootPath = _rootPath[0];
      }
      Directory _dir = Directory(currentPath);

      List<FileSystemEntity> entities;

      if (sortByName) {
        //sorting by name
        entities = _dir.listSync()
          ..sort((l, r) => l.path.toLowerCase().compareTo(r.path.toLowerCase()));
      } else {
        //sorting by last modified
        entities = _dir.listSync()
          ..sort((l, r) => r.statSync().modified.compareTo(l.statSync().modified));
      }

      // List<FileSystemEntity> entities = await _dir.list().toList();

      Iterable<Directory> folders = entities.whereType<Directory>();
      Iterable<File> files = entities.whereType<File>();

      List<Widget> body = [];

      for (Directory folder in folders) {
        body.add(folderWidget(folder.path
            .split("/")
            .last));
      }

      for (File file in files) {
        if (file.path.split(".").last == Shared.extension) {
          body.add(fileWidget(file.path.split("/").last));
        }
      }

      List<String> selectedPath = currentPath != rootPath ? currentPath
          .substring(rootPath.length + 1, currentPath.length).split("/") : [];
      selectedPath.insert(0, "Internal storage");

      return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: body,
          ),
        ),

        appBar: AppBar(
          toolbarHeight: 40,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.purple[400],

          title: SizedBox(
            height: 50,

            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                children: [
                  const SizedBox(width: 10),

                  for (int i = 0; i < selectedPath.length - 1; i++)
                    Row(
                      children: [
                        TextButton(
                            onPressed: () {
                              if (i == 0) {
                                setState(() {
                                  currentPath = rootPath;
                                  inHome = true;
                                });
                                return;
                              }
                              String extraPath = selectedPath.sublist(1, i + 1).join("/");
                              setState(() {
                                currentPath = rootPath + "/" + extraPath;
                              });
                            },
                            child: Text(selectedPath[i], style: TextStyle(
                                fontSize: 18, color: Colors.grey[300]))),

                        Icon(Icons.arrow_right, size: 30,
                            color: Colors.grey[300])
                      ],
                    ),

                  Text(selectedPath.last, style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),

                  const SizedBox(width: 10)
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        automaticallyImplyLeading: false,
        toolbarHeight: 60,
        // elevation: 0,

        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 60),

            Container(
              child: Text("Pick ${Shared.extension} file from"),
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
          PopupMenuButton(
            icon: const Icon(Icons.sort, size: 30),
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    enabled: !sortByName,
                    child: const Text("Sort by name"),
                    textStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
                    onTap: () {
                      setState(() {
                        sortByName = true;
                      });
                    },
                  ),

                  PopupMenuItem(
                    enabled: sortByName,
                    child: const Text("Sort by last modified"),
                    textStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
                    onTap: () {
                      setState(() {
                        sortByName = false;
                      });
                    },
                  ),
                ];
              }
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Visibility(
                visible: !inHome,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, size: 30),

                  onPressed: () {
                    setState(() {
                      currentPath = Directory(currentPath).parent.path;
                      inHome = currentPath == rootPath;
                    });
                  },
                )
            ),
          ),
        ],
      ),

      body: SizedBox(
        width: double.infinity,
        child: FutureBuilder<Widget>(
            future: listFolder(),
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
    );
  }
}
 */


// class FolderPicker extends StatefulWidget {
//   const FolderPicker({Key? key}) : super(key: key);
//
//   @override
//   State<FolderPicker> createState() => _FolderPickerState();
// }
//
// class _FolderPickerState extends State<FolderPicker> {
//   String currentPath = "null";
//   String rootPath = "null";
//   bool inHome = true;
//   bool sortByName = true;
//
//   @override
//   Widget build(BuildContext context) {
//
//     Widget folderWidget(String folderName) {
//       return Card(
//         color: Colors.grey[200],
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         margin: const EdgeInsets.fromLTRB(2,2,2,0),
//
//         child: InkWell(
//           borderRadius: BorderRadius.circular(10),
//           child: SizedBox(
//             width: double.infinity,
//             height: 80,
//             child: Center(
//               child: Row(
//                 children: [
//                   const SizedBox(width: 10),
//
//                   const Icon(Icons.folder, size: 55, color: Colors.amber),
//
//                   const SizedBox(width: 10),
//
//                   SizedBox(
//                     width: Shared.width - 100,
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Text(
//                         folderName,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                             fontSize: 20, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           onTap: () {
//             setState(() {
//               currentPath += "/$folderName";
//               inHome = false;
//             });
//           },
//         ),
//       );
//     }
//
//     Future<Widget> listFolder() async {
//       if (currentPath == "null") {
//         List<String> _rootPath = await ExternalPath.getExternalStorageDirectories();
//         currentPath = _rootPath[0];
//         rootPath = _rootPath[0];
//       }
//       Directory _dir = Directory(currentPath);
//
//       // FileManager fm = FileManager(root: Directory(currentPath));
//       // List<Directory> folders = await fm.dirsTree();
//
//       List<FileSystemEntity> entities;
//
//       if (sortByName) {
//         //sorting by name
//         entities = _dir.listSync()
//           ..sort((l, r) => l.path.toLowerCase().compareTo(r.path.toLowerCase()));
//       } else {
//         //sorting by last modified
//         entities = _dir.listSync()
//           ..sort((l, r) => r.statSync().modified.compareTo(l.statSync().modified));
//       }
//
//       // List<FileSystemEntity> entities = await _dir.list().toList();
//
//       Iterable<Directory> folders = entities.whereType<Directory>();
//
//       List<Widget> body = [];
//
//       for (Directory folder in folders) {
//         body.add(folderWidget(folder.path.split("/").last));
//       }
//
//       List<String> selectedPath = currentPath != rootPath ? currentPath.substring(rootPath.length + 1, currentPath.length).split("/") : [];
//       selectedPath.insert(0, "Internal storage");
//
//       return Scaffold(
//         body: SingleChildScrollView(
//           child: Column(
//             children: body,
//           ),
//         ),
//
//         appBar: AppBar(
//           toolbarHeight: 40,
//           automaticallyImplyLeading: false,
//           backgroundColor: Colors.purple[400],
//
//           title: SizedBox(
//             height: 50,
//
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               reverse: true,
//               child: Row(
//                 children: [
//                   const SizedBox(width: 10),
//
//                   for (int i = 0; i < selectedPath.length - 1; i++)
//                     Row(
//                       children: [
//                         TextButton(
//                           onPressed: () {
//                             if (i == 0) {
//                               setState(() {
//                                 currentPath = rootPath;
//                                 inHome = true;
//                               });
//                               return;
//                             }
//                             String extraPath = selectedPath.sublist(1,i + 1).join("/");
//                             setState(() {
//                               currentPath = rootPath + "/" + extraPath;
//                             });
//                           },
//                           child: Text(selectedPath[i], style: TextStyle(fontSize: 18, color: Colors.grey[300]))),
//
//                         Icon(Icons.arrow_right, size: 30, color: Colors.grey[300])
//                       ],
//                     ),
//
//                   Text(selectedPath.last, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//
//                   const SizedBox(width: 10)
//                 ],
//               ),
//             ),
//           ),
//         ),
//
//         floatingActionButton: FloatingActionButton(
//             onPressed: () {
//               Shared.pickedFileSystem = currentPath;
//               Navigator.of(context).pop();
//             },
//             child: const Icon(Icons.check_circle, size: 35),
//           tooltip: "Pick",
//         ),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.green[700],
//         automaticallyImplyLeading: false,
//         toolbarHeight: 60,
//         // elevation: 0,
//
//         title: Row(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             const SizedBox(height: 60),
//
//             Container(
//               child: const Text("Pick this folder"),
//               padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//               decoration: BoxDecoration(
//                   color: Colors.purple[400],
//                   borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(20),
//                       topRight: Radius.circular(20)
//                   )
//               ),
//             ),
//           ],
//         ),
//
//         actions: [
//           PopupMenuButton(
//               icon: const Icon(Icons.sort, size: 30),
//               itemBuilder: (BuildContext context) {
//                 return [
//                   PopupMenuItem(
//                     enabled: !sortByName,
//                     child: const Text("Sort by name"),
//                     textStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
//                     onTap: () {
//                       setState(() {
//                         sortByName = true;
//                       });
//                     },
//                   ),
//
//                   PopupMenuItem(
//                     enabled: sortByName,
//                     child: const Text("Sort by last modified"),
//                     textStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
//                     onTap: () {
//                       setState(() {
//                         sortByName = false;
//                       });
//                     },
//                   ),
//                 ];
//               }
//           ),
//
//
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             child: Visibility(
//                 visible: !inHome,
//                 child: IconButton(
//                   icon: const Icon(Icons.arrow_back, size: 30),
//
//                   onPressed: () {
//                     setState(() {
//                       currentPath = Directory(currentPath).parent.path;
//                       inHome = currentPath == rootPath;
//                     });
//                   },
//                 )
//             ),
//           ),
//         ],
//       ),
//
//       body: SizedBox(
//         width: double.infinity,
//         child: FutureBuilder<Widget>(
//             future: listFolder(),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData) {
//                 return Center(
//                     child: Column(
//                       children: [
//                         SizedBox(height: Shared.height / 3),
//                         const CircularProgressIndicator(color: Colors.blue),
//                       ],
//                     )
//                 );
//               }
//
//               return snapshot.data!;
//             }
//         ),
//       ),
//     );
//   }
// }


// ignore: must_be_immutable

// static Future<String> pickFolder() async {
//   pickedFileSystem = "null";
//
//   await Navigator.push(
//     context,
//     MaterialPageRoute(builder: (context) => const FolderPicker()),
//   );
//
//   return pickedFileSystem;
// }