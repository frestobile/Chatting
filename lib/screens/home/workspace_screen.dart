import 'package:ainaglam/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';

class WorkspaceScreen extends StatefulWidget {
  final String tokenString;
  const WorkspaceScreen({super.key, required this.tokenString});
  @override
  _WorkSpaceScreenState createState() => _WorkSpaceScreenState();
}

class _WorkSpaceScreenState extends State<WorkspaceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WorkspaceProvider>(context, listen: false)
          .fetchWorkspaces(widget.tokenString);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('ワークスペースを選択')),
      body: Center(
        child: Container(
          width: 500, // Set a fixed width for the content box
          height: 300, // Set a fixed height for the content box
          decoration: BoxDecoration(
            color: Colors.white
                .withOpacity(0.7), // Semi-transparent background color
            borderRadius:
                BorderRadius.circular(10), // Optional: Rounded corners
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5), // Shadow effect
              ),
            ],
          ),
          child: Stack(children: [
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/images/home-cong.svg', // Path to SVG file
                fit: BoxFit.cover, // Fit the SVG to cover the entire container
              ),
            ),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Consumer<WorkspaceProvider>(
                  builder: (context, workspaceProvider, _) {
                    if (workspaceProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (workspaceProvider.errorMessage != null) {
                      return Center(
                          child: Text(workspaceProvider.errorMessage!));
                    }
                    final workspaces = workspaceProvider.workspaces;

                    if (workspaces.isEmpty) {
                      return const Center(
                          child: Text("No Workspaces Available"));
                    }
                    return Center(
                      child: ListView.builder(
                        itemCount: workspaces.length,
                        itemBuilder: (context, index) {
                          final workspace = workspaces[index];
                          return Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Card(
                              color: Colors.black,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  children: [
                                    if (index == 0)
                                      const Text(
                                        "ワークスペースを選択",
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.white),
                                      ),
                                    const SizedBox(height: 15),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 24,
                                              backgroundColor: Colors
                                                  .pinkAccent, // Avatar color
                                              child: Text(
                                                workspace.name[0],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  workspace.name,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  '${workspace.coWorkers.length} メンバー', // Member count
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    HomeScreen(
                                                        workspaceId:
                                                            workspaces[index]
                                                                .id,
                                                        workspaceName:
                                                            workspaces[index]
                                                                .name),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors
                                                .grey[850], // Button color
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                            ),
                                          ),
                                          child: const Row(
                                            children: [
                                              Text(
                                                '開ける', // Open in Japanese
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(Icons.arrow_forward,
                                                  color: Colors.white),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
