import 'package:flutter/material.dart';
import 'dart:convert';

class Findworks extends StatefulWidget {
  const Findworks({super.key});

  @override
  State<Findworks> createState() => _FindworksState();
}

class _FindworksState extends State<Findworks> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading", style: TextStyle(fontSize: 16)),
              ],
            ),
          )
        : Padding(
            padding: EdgeInsetsGeometry.only(top: 16, right: 16, left: 16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hint: Text(
                      "Search works",
                      style: TextStyle(color: Colors.grey),
                    ),
                    border: OutlineInputBorder(),
                  ),
                  readOnly: isLoading,
                ),
                SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: 20,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text("Work Title $index"),
                          subtitle: Text("Description of work $index"),
                          trailing: Icon(Icons.arrow_forward),
                          onTap: () {
                            // Handle tap
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Tapped on Work Title $index"),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
  }
}
