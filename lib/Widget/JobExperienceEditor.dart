import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class JobExperienceEditor extends StatelessWidget {
  final Function(String) removeJobExperience;
  final Function(String) addJobExperience;
  final Function(String, String) editJobExperience;
  final List<String> jobExperience;
  final SlidableController? controller;

  const JobExperienceEditor({
    super.key,
    required this.removeJobExperience,
    required this.addJobExperience,
    required this.editJobExperience,
    required this.jobExperience,
    required this.controller,
  });

  Future<(String, String?)> showTextInputDialog(
    BuildContext context,
    bool insert,
    String initialText,
  ) {
    final TextEditingController textController = TextEditingController(
      text: initialText,
    );
    return showDialog<(String, String?)>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(insert ? "Add Job Experience" : "Edit Job Experience"),
          content: TextField(
            controller: textController,
            decoration: InputDecoration(hintText: "Enter job experience"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(("", null)),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(
                context,
              ).pop((textController.text, insert ? null : initialText)),
              child: const Text("OK"),
            ),
          ],
        );
      },
    ).then((value) => value ?? ("", null));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Job Experience",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await controller!.close();
                          if (!context.mounted) return;
                          final (newExperience, _) = await showTextInputDialog(
                            context,
                            true,
                            "",
                          );
                          if (newExperience.isNotEmpty) {
                            if (!addJobExperience(newExperience)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Experience already exists"),
                                ),
                              );
                            }
                          }
                        },
                        child: const Text("Add"),
                      ),
                    ],
                  ),
                  ...[
                    for (final experience in jobExperience)
                      Slidable(
                        controller: controller,
                        key: ValueKey(experience),
                        endActionPane: ActionPane(
                          motion: DrawerMotion(),
                          extentRatio: 0.6,
                          dismissible: DismissiblePane(
                            onDismissed: () => removeJobExperience(experience),
                          ),
                          children: [
                            SlidableAction(
                              flex: 1,
                              onPressed: (_) async {
                                final (
                                  editedExperience,
                                  _,
                                ) = await showTextInputDialog(
                                  context,
                                  false,
                                  experience,
                                );
                                if (editedExperience.isNotEmpty) {
                                  editJobExperience(
                                    experience,
                                    editedExperience,
                                  );
                                }
                              },
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'Edit',
                            ),
                            SlidableAction(
                              flex: 1,
                              onPressed: (_) => removeJobExperience(experience),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: SizedBox(
                          height: 50,
                          child: ListTile(title: Text(experience)),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
