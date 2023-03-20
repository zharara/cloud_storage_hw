import 'dart:io';

import 'package:firebase_cloud_storage/cloud_storage_functions.dart';
import 'package:firebase_cloud_storage/local_files_functions.dart';
import 'package:firebase_cloud_storage/utils.dart';
import 'package:firebase_cloud_storage/view_pdf.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'List Of App Users',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'List Of App Users'),
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Center(
        child: StreamBuilder<ListResult>(
            stream: getAllFiles(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              return ListView(
                children: snapshot.data!.items
                    .map((ref) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: const Icon(
                            Icons.picture_as_pdf,
                            color: Colors.red,
                            size: 50,
                          ),
                          title: Text(ref.name),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.download,
                              color: Colors.blueGrey,
                            ),
                            onPressed: () async {
                              try {
                                final fileURL = await ref.getDownloadURL();
                                if (mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (ctx) => ViewPDF(fileURL: fileURL),
                                    ),
                                  );
                                }
                              } catch (_) {
                                showErrorDialog(context);
                              }
                            },
                          ),
                        ),
                      );
                    })
                    .toList()
                    .cast(),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addFile(context),
        tooltip: 'Add User',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _addFile(BuildContext context) async {
    final file = await pickFile();

    if (file != null) {
      final upload = await uploadFile(File(file.path!));

      if (mounted) {
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: const Text('Uploading...'),
                  content: SizedBox(
                    height: 200,
                    child: Center(
                      child: StreamBuilder<TaskSnapshot>(
                          stream: upload.asStream(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              if (snapshot.hasData) {
                                return CircularProgressIndicator(
                                  value: (snapshot.data?.bytesTransferred ?? 0) /
                                      (snapshot.data?.totalBytes ?? 0.0001),
                                );
                              }
                            }

                            if (snapshot.connectionState == ConnectionState.done) {
                              SchedulerBinding.instance
                                  .addPostFrameCallback((timeStamp) {
                                Navigator.pop(context);
                              });
                            }
                            return const CircularProgressIndicator();
                          }),
                    ),
                  ),
                ));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No file selected'),
          ),
        );
      }
    }
  }
}
