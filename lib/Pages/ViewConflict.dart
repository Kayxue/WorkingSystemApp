import 'package:flutter/material.dart';
import 'package:rhttp/rhttp.dart';
import 'dart:convert';
import 'package:maps_launcher/maps_launcher.dart';
import '../Others/Utils.dart';
import 'package:working_system_app/Pages/ScheduleGigDetails.dart';
import 'package:working_system_app/Widget/LoadingIndicator.dart';
import 'package:working_system_app/Types/JSONObject/Conflict/ConflictReturn.dart';
import 'package:working_system_app/Types/JSONObject/Conflict/ConfirmedGig.dart';
import 'package:working_system_app/Types/JSONObject/Conflict/PendingApplication.dart';

class ViewConflict extends StatefulWidget {
  final String sessionKey;
  final String applicationId;
  final String gigTitle;
  final String conflictType;

  const ViewConflict({
    super.key,
    required this.sessionKey,
    required this.applicationId,
    required this.gigTitle,
    required this.conflictType,
  });

  @override
  State<ViewConflict> createState() => _ViewConflictState();
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

class _ViewConflictState extends State<ViewConflict> {
  int offset = 0;
  bool hasMore = true;
  bool isLoading = true;
  bool isLoadingMore = false;
  List<ConfirmedGig> confirmedConflicts = [];
  List<PendingApplication> pendingConflicts = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchConflictDetails();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          hasMore) {
        fetchConflictDetails();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchConflictDetails({bool isRefresh = false}) async {
    if (isRefresh) {
      offset = 0;
      hasMore = true;
      setState(() {
        isLoading = true;
      });
    } else {
      if (!hasMore) {
        return;
      }
      setState(() {
        isLoadingMore = true;
      });
    }

    try {
      final response = await Utils.client.get(
        '/application/${widget.applicationId}/conflicts?type=${widget.conflictType}&limit=10&offset=$offset',
        headers: HttpHeaders.rawMap({
          "cookie": widget.sessionKey,
        }),
      );

      if (response.statusCode == 200) {
        final data = ConflictReturn.fromJson(jsonDecode(response.body));
        setState(
          () {
            if (isRefresh) {
              if (widget.conflictType == 'confirmed') {
                confirmedConflicts.clear();
              } else {
                pendingConflicts.clear();
              }
            }
            
            if (widget.conflictType == 'confirmed') {
              confirmedConflicts.addAll(data.confirmedGigConflicts);
              offset += data.confirmedGigConflicts.length;
              hasMore = data.pagination.hasMore;
            } else {
              pendingConflicts.addAll(data.pendingApplicationConflicts);
              offset += data.pendingApplicationConflicts.length;
              hasMore = data.pagination.hasMore;
            }
            
          },
        );
      } else {
        // Handle error
        setState(() {
          hasMore = false;
        });
      }
    } catch (e) {
      // Handle error
      setState(() {
        hasMore = false;
      });
    } finally {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  Future<void> _rejectApplicationAction(String gigId) async {

    final confirmed = await _showConfirmationDialog('確認拒絕', '您確定要拒絕此工作邀請嗎？');
    if (!confirmed || !mounted) return;

    try {
      final response = await Utils.client.put(
        '/application/$gigId/confirm',
        headers: HttpHeaders.rawMap({'cookie': widget.sessionKey}),
        body: HttpBody.json({'action': 'reject'}),
      );

      if (response.statusCode == 200) {
        fetchConflictDetails(isRefresh: true);
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
        fetchConflictDetails(isRefresh: true);
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle error
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.gigTitle} 衝突申請'),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0.0,
      ),
      body: isLoading
          ? LoadingIndicator()
          : RefreshIndicator(
              onRefresh: () => fetchConflictDetails(isRefresh: true),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (widget.conflictType == 'confirmed'
                          ? '以下的工作和您的申請有衝突'
                          : '以下的工作申請和您的申請有衝突，請確認後再進行操作'),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                      
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: widget.conflictType == 'confirmed'
                          ? _buildConfirmedList()
                          : _buildPendingList(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildConfirmedList() {
    if (confirmedConflicts.isEmpty) {
      return const Center(child: Text('沒有已確認的申請衝突'));
    }
    return ListView.builder(
      controller: _scrollController,
      itemCount: confirmedConflicts.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == confirmedConflicts.length) {
          return isLoadingMore ? LoadingIndicator() : Container();
        }
        final gig = confirmedConflicts[index];
        return GigCard(gig: gig);
      },
    );
  }

  Widget _buildPendingList() {
    if (pendingConflicts.isEmpty) {
      return const Center(child: Text('沒有待處理的申請衝突'));
    }
    return ListView.builder(
      controller: _scrollController,
      itemCount: pendingConflicts.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == pendingConflicts.length) {
          return isLoadingMore ? LoadingIndicator() : Container();
        }
        final pendingApp = pendingConflicts[index];
        return PendingApplicationCard(
          app: pendingApp, 
          onReject: () => _rejectApplicationAction(pendingApp.gigId),
          onWithdraw: () => _withdrawApplication(pendingApp.applicationId),
        );
      },
    );
  }
}

class GigCard extends StatelessWidget {
  final ConfirmedGig gig;

  const GigCard({super.key, required this.gig});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to Gig Detail Page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ScheduleGigDetails(
              gigId: gig.gigId,
              title: gig.title,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
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
                  Text(
                    gig.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  _buildStatusTag('worker_confirmed'),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                gig.employerName,
                style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '時薪${gig.hourlyRate} ',
                      style: TextStyle(fontSize: 14, color: Colors.orange[500], fontWeight: FontWeight.w500),
                    ),
                    TextSpan(
                      text: '| ${gig.dateStart} - ${gig.dateEnd} (${gig.timeStart} - ${gig.timeEnd})',
                      style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),
                    ),
                  ],
                )
              ),
              const SizedBox(height: 8),
              Text(
                '${gig.city} ${gig.district} ${gig.address}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              )

            ],
          ),
        ),
      ),
    ); 
  }
}

class PendingApplicationCard extends StatelessWidget {
  final PendingApplication app;
  final VoidCallback onReject;
  final VoidCallback onWithdraw;

  const PendingApplicationCard({
    super.key, 
    required this.app,
    required this.onReject,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to Gig Detail Page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ScheduleGigDetails(
              gigId: app.gigId,
              title: app.title,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
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
                  Text(
                    app.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  _buildStatusTag(app.status),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                app.employerName,
                style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '時薪${app.hourlyRate} ',
                              style: TextStyle(fontSize: 14, color: Colors.orange[500], fontWeight: FontWeight.w500),
                            ),
                            TextSpan(
                              text: '| ${app.dateStart} - ${app.dateEnd} (${app.timeStart} - ${app.timeEnd})',
                              style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),
                            ),
                          ],
                        )
                      ),                  
                      Text(
                        '${app.city} ${app.district} ${app.address}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ]
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

  List<Widget> _buildActionButtons(BuildContext context) {
    switch (app.status) {
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