import 'package:flutter/material.dart';
import 'package:rhttp/rhttp.dart';
import 'package:working_system_app/Types/JSONObject/UserApplication.dart';
import '../Types/JSONObject/Application.dart';
import '../Others/Utils.dart';
import 'dart:convert';

// Manages the state for a single tab
class TabState {
  List<Application> applications = [];
  int offset = 0;
  bool hasMore = true;
  bool isLoading = true;
  bool isLoadingMore = false;
  final ScrollController scrollController = ScrollController();
}

class MyApplicationsPage extends StatefulWidget {
  final String sessionKey;
  final String userId;

  const MyApplicationsPage({
    super.key,
    required this.sessionKey,
    required this.userId,
  });

  @override
  State<MyApplicationsPage> createState() => _MyApplicationsPageState();
}

class _MyApplicationsPageState extends State<MyApplicationsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final int _limit = 30;

  final Map<int, TabState> _tabStates = {
    0: TabState(),
    1: TabState(),
    2: TabState(),
    3: TabState(),
  };

  final Map<int, String> _tabIndexToStatus = {
    0: 'pending_worker_confirmation',
    1: 'pending_employer_review',
    2: 'worker_confirmed',
    3: 'inactive',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final tabIndex = _tabController.index;
        if (_tabStates[tabIndex]!.isLoading) {
          _fetchApplications(tabIndex: tabIndex);
        }
      }
    });

    _tabStates.forEach((index, state) {
      state.scrollController.addListener(() {
        if (state.scrollController.position.pixels >= state.scrollController.position.maxScrollExtent - 100 &&
            state.hasMore &&
            !state.isLoadingMore) {
          _fetchApplications(tabIndex: index);
        }
      });
    });

    _fetchApplications(tabIndex: 0); // Initial fetch for the first tab
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tabStates.values.forEach((state) => state.scrollController.dispose());
    super.dispose();
  }

  Future<void> _fetchApplications({required int tabIndex, bool isRefresh = false}) async {
    final state = _tabStates[tabIndex]!;
    final status = _tabIndexToStatus[tabIndex]!;

    if (isRefresh) {
      state.offset = 0;
      state.applications.clear();
      state.hasMore = true;
      setState(() {
        state.isLoading = true;
      });
    } else {
      if (state.isLoadingMore || !state.hasMore) return;
      setState(() {
        state.isLoadingMore = true;
      });
    }

    try {
      final response = await Utils.client.get(
        '/application/my-applications?limit=$_limit&offset=${state.offset}&status=$status',
        headers: HttpHeaders.rawMap({
          'cookie': widget.sessionKey,
        })
      );

      if (response.statusCode == 200) {
        final data = UserApplication.fromJson(jsonDecode(response.body));
        setState(() {
          if (isRefresh) state.applications.clear();
          state.applications.addAll(data.applications);
          state.offset += data.applications.length;
          state.hasMore = data.applications.length == _limit;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load applications: ${response.body}')),
        );
        setState(() => state.hasMore = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
      setState(() => state.hasMore = false);
    } finally {
      setState(() {
        state.isLoading = false;
        state.isLoadingMore = false;
      });
    }
  }

  Future<void> _handleApplicationAction(String gigId, String action) async {
    try {
      final response = await Utils.client.put(
        '/application/$gigId/confirm',
        headers: HttpHeaders.rawMap({
          'cookie': widget.sessionKey,
        }),
        body: HttpBody.json({'action': action})
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Application action ($action) successful!')),
        );
        _fetchApplications(tabIndex: _tabController.index, isRefresh: true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action failed: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<void> _withdrawApplication(String applicationId) async {
    try {
      final response = await Utils.client.post(
        '/application/cancel/$applicationId',
        headers: HttpHeaders.rawMap({
          'cookie': widget.sessionKey,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application withdrawn!')),
        );
        _fetchApplications(tabIndex: _tabController.index, isRefresh: true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Withdrawal failed: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double tabSizeRatio = 0.15;
    final double tabWidth = screenWidth * tabSizeRatio;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的申請', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        titleSpacing: 0.0,  
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.black,
          indicatorColor: Colors.blue,
          isScrollable: true,
          tabs: [
            SizedBox(
              width: tabWidth,
              child: const Tab(text: '待回覆'),
            ),
            SizedBox(
              width: tabWidth,
              child: const Tab(text: '待雇主處理'),
            ),
            SizedBox(
              width: tabWidth,
              child: const Tab(text: '已確認'),
            ),
            SizedBox(
              width: tabWidth,
              child: const Tab(text: '已拒絕'),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(4, (index) => _buildApplicationList(index)),
      ),
    );
  }

  Widget _buildApplicationList(int tabIndex) {
    final state = _tabStates[tabIndex]!;

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.applications.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _fetchApplications(tabIndex: tabIndex, isRefresh: true),
        child: Stack(
          children: [ 
            ListView(), // Required for RefreshIndicator to work on empty list
            const Center(child: Text('沒有相關的申請記錄')),
          ], 
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetchApplications(tabIndex: tabIndex, isRefresh: true),
      child: ListView.builder(
        controller: state.scrollController,
        padding: const EdgeInsets.all(8.0),
        itemCount: state.applications.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.applications.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final app = state.applications[index];
          return ApplicationCard(
            application: app,
            onAccept: () => _handleApplicationAction(app.applicationId, 'accept'),
            onReject: () => _handleApplicationAction(app.applicationId, 'reject'),
            onWithdraw: () => _withdrawApplication(app.applicationId),
          );
        },
      ),
    );
  }
}

class ApplicationCard extends StatelessWidget {
  final Application application;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onWithdraw;

  const ApplicationCard({
    super.key,
    required this.application,
    required this.onAccept,
    required this.onReject,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text(application.employerName,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                        overflow: TextOverflow.ellipsis)),
                _buildStatusTag(application.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(application.gigTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('工作日期: ${application.workDate}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('申請於: ${application.appliedAt.split('T')[0]}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                if (_buildActionButtons(context).isNotEmpty)
                  Row(children: _buildActionButtons(context)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    Color color;
    String text;
    switch (status) {
      case 'pending_worker_confirmation':
        text = '待你確認';
        color = Colors.orange;
        break;
      case 'pending_employer_review':
        text = '待雇主審核';
        color = Colors.blueGrey;
        break;
      case 'worker_confirmed':
        text = '已確認';
        color = Colors.green;
        break;
      case 'employer_rejected':
        text = '雇主已婉拒';
        color = Colors.red;
        break;
      case 'worker_declined':
        text = '你已婉拒';
        color = Colors.red;
        break;
      case 'worker_cancelled':
        text = '你已取消';
        color = Colors.grey;
        break;
      case 'system_cancelled':
        text = '系統已取消';
        color = Colors.grey;
        break;
      default:
        text = status;
        color = Colors.grey;
    }
    return Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold));
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    switch (application.status) {
      case 'pending_worker_confirmation':
        return [
          OutlinedButton(onPressed: onReject, child: const Text('婉拒')),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: onAccept, child: const Text('接受')),
        ];
      case 'pending_employer_review':
        return [OutlinedButton(onPressed: onWithdraw, child: const Text('取消申請'))];
      default:
        return [];
    }
  }
}
