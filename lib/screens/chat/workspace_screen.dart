import 'package:ainaglam/providers/org_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home/home_screen.dart';

class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Workspace')),
      body: Consumer<OrgProvider>(
        builder: (context, orgProvider, _) {
          if (orgProvider.workspaces.isEmpty) {
            orgProvider.fetchWorkspaces();
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: orgProvider.workspaces.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(orgProvider.workspaces[index].name),
                onTap: () {
                  orgProvider.selectWorkspace(orgProvider.workspaces[index]);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => ChannelAndCoworkersScreen(
                          workspaceId: orgProvider.workspaces[index].id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
