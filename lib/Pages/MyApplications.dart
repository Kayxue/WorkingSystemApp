import 'package:flutter/material.dart';
import 'package:rhttp/rhttp.dart';
import 'package:working_system_app/Types/JSONObject/UserApplication.dart';
import '../Types/JSONObject/Application.dart';
import '../Others/Utils.dart';
import 'dart:convert';
import 'package:working_system_app/Pages/ViewConflict.dart';
import 'package:working_system_app/Pages/ScheduleGigDetails.dart';

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

class _MyApplicationsPageState extends State<MyApplicationsPage>
    with SingleTickerProviderStateMixin {
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
        if (state.scrollController.position.pixels >=
                state.scrollController.position.maxScrollExtent - 100 &&
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
    for (var state in _tabStates.values) {
      state.scrollController.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchApplications({
    required int tabIndex,
    bool isRefresh = false,
  }) async {
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
        headers: HttpHeaders.rawMap({'cookie': widget.sessionKey}),
      );

      if (response.statusCode == 200) {
        final data = UserApplication.fromJson(jsonDecode(response.body));
        setState(() {
          if (isRefresh) state.applications.clear();
          state.applications.addAll(data.applications);
          state.offset += data.applications.length;
          state.hasMore = data.pagination.hasMore;
        });
      } else {
        // Handle error
        setState(() => state.hasMore = false);
      }
    } catch (e) {
      // Handle error
      setState(() => state.hasMore = false);
    } finally {
      setState(() {
        state.isLoading = false;
        state.isLoadingMore = false;
      });
    }
  }

  Future<bool> _showConfirmationDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('確認'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _handleApplicationAction(String gigId, String action) async {
    final title = action == 'accept' ? '確認接受' : '確認婉拒';
    final content = action == 'accept' ? '您確定要接受此工作邀請嗎？' : '您確定要婉拒此工作邀請嗎？';

    final confirmed = await _showConfirmationDialog(title, content);
    if (!confirmed || !mounted) return;

    try {
      final response = await Utils.client.put(
        '/application/$gigId/confirm',
        headers: HttpHeaders.rawMap({'cookie': widget.sessionKey}),
        body: HttpBody.json({'action': action}),
      );

      if (response.statusCode == 200) {
        _fetchApplications(tabIndex: _tabController.index, isRefresh: true);
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _withdrawApplication(String applicationId) async {
    final confirmed = await _showConfirmationDialog('確認取消申請', '您確定要取消這個工作申請嗎？');
    if (!confirmed || !mounted) return;

    try {
      final response = await Utils.client.post(
        '/application/cancel/$applicationId',
        headers: HttpHeaders.rawMap({'cookie': widget.sessionKey}),
      );

      if (response.statusCode == 200) {
        _fetchApplications(tabIndex: _tabController.index, isRefresh: true);
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的申請'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        titleSpacing: 0.0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: '未回覆'),
            const Tab(text: '審核中'),
            const Tab(text: '已接受'),
            const Tab(text: '未通過'),
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
        onRefresh: () =>
            _fetchApplications(tabIndex: tabIndex, isRefresh: true),
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
          state.applications[index].hasConflict ??= false;
          state.applications[index].hasPendingConflict ??= false;
          final app = state.applications[index];
          return ApplicationCard(
            sessionKey: widget.sessionKey,
            application: app,
            onAccept: () =>
                _handleApplicationAction(app.applicationId, 'accept'),
            onReject: () =>
                _handleApplicationAction(app.applicationId, 'reject'),
            onWithdraw: () => _withdrawApplication(app.applicationId),
          );
        },
      ),
    );
  }
}

class ApplicationCard extends StatelessWidget {
  final String sessionKey;
  final Application application;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onWithdraw;

  const ApplicationCard({
    super.key,
    required this.sessionKey,
    required this.application,
    required this.onAccept,
    required this.onReject,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ScheduleGigDetails(
                gigId: application.gigId,
                title: application.gigTitle,
              ),
            ),
          );          
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    application.gigTitle,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  _buildStatusTag(application.status),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                application.employerName,
                style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '時薪${application.hourlyRate} ',
                      style: TextStyle(fontSize: 14, color: Colors.orange[500], fontWeight: FontWeight.w500),
                    ),
                    TextSpan(
                      text: '| ${application.workDate} (${application.workTime})',
                      style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),
                    ),
                  ],
                )
              ),
              if (application.hasPendingConflict! == true || 
                  application.hasConflict! == true)
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ViewConflict(
                          sessionKey: sessionKey,
                          applicationId: application.applicationId,
                          gigTitle: application.gigTitle,
                          conflictType: application.hasConflict! == true ? 'confirmed' : 'pending',
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          '此申請與其他申請的工作時間有衝突。',
                          style: TextStyle(
                            color: Colors.red, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios_rounded, 
                          color: Colors.red,
                          size: 16.0,
                        ),
                      ]
                    )
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '申請於: ${application.appliedAt.split('T')[0]}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  if (_buildActionButtons(context).isNotEmpty)
                    Row(children: _buildActionButtons(context)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    Color color;
    String text;
    switch (status) {
      case 'pending_worker_confirmation':
        text = '待同意';
        color = Colors.orange;
        break;
      case 'pending_employer_review':
        text = '待審核';
        color = Colors.blueGrey;
        break;
      case 'worker_confirmed':
        text = '已通過';
        color = Colors.green;
        break;
      case 'employer_rejected':
        text = '審核未通過';
        color = Colors.red;
        break;
      case 'worker_declined':
        text = '已拒絕';
        color = Colors.red;
        break;
      case 'worker_cancelled':
        text = '已取消';
        color = Colors.grey;
        break;
      case 'system_cancelled':
        text = '已取消';
        color = Colors.grey;
        break;
      default:
        text = status;
        color = Colors.grey;
    }
    return Text(
      text,
      style: TextStyle(color: color, fontSize: 16),
    );
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    switch (application.status) {
      case 'pending_worker_confirmation':
        return [
          OutlinedButton(
            onPressed: onReject,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
            ),
            child: const Text(
              '拒絕',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
            )
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onAccept, 
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.green),
            ),            
            child: const Text(
              '接受',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)
            )
          ),
        ];
      case 'pending_employer_review':
        return [
          OutlinedButton(onPressed: onWithdraw, child: const Text('取消申請')),
        ];
      default:
        return [];
    }
  }
}
