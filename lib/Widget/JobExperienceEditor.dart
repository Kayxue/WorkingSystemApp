import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class JobExperienceEditor extends StatelessWidget {
  final Function(String) removeJobExperience;
  final Function(String) addJobExperience;
  final Function(String, String) editJobExperience;
  final List<String> jobExperience;

  const JobExperienceEditor({
    super.key,
    required this.removeJobExperience,
    required this.addJobExperience,
    required this.editJobExperience,
    required this.jobExperience,
  });

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
                      Text(
                        "Job Experience",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(onPressed: () {}, child: Text("Add")),
                    ],
                  ),
                  ...[
                    for (final experience in jobExperience)
                      Slidable(
                        key: ValueKey(experience),
                        endActionPane: ActionPane(
                          motion: DrawerMotion(),
                          extentRatio: 0.25,
                          dismissible: DismissiblePane(
                            onDismissed: () => removeJobExperience(experience),
                          ),
                          children: [
                            SlidableAction(
                              flex: 1,
                              onPressed: null,
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
                          child: ListTile(title: Text("Test")),
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
