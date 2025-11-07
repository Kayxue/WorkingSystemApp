import 'package:flutter/material.dart';
import 'package:rhttp/rhttp.dart';
import 'package:working_system_app/Widget/ViewConflict/GigCard.dart';
import 'package:working_system_app/Widget/ViewConflict/PendingApplicationCard.dart';
import 'dart:convert';
import '../Others/Utils.dart';
import 'package:working_system_app/Widget/Others/LoadingIndicator.dart';
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
        headers: HttpHeaders.rawMap({"cookie": widget.sessionKey}),
      );

      if (response.statusCode == 200) {
        final data = ConflictReturn.fromJson(jsonDecode(response.body));
        setState(() {
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
        });
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
        title: Text('${widget.gigTitle}衝突'),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      (widget.conflictType == 'confirmed'
                          ? '以下的工作和您的申請有衝突'
                          : '以下的工作申請和您目前的申請有衝突'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
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
        return GigCard(gig: gig, sessionKey: widget.sessionKey);
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
          sessionKey: widget.sessionKey,
        );
      },
    );
  }
}
