import 'package:flutter/material.dart';
import 'package:quanlidoanvien/Services/ActivityService.dart';
import 'package:quanlidoanvien/Models/ActivityModel.dart';
import 'package:quanlidoanvien/Views/Profile/ActivityDetail.dart';

class AllActivitiesScreen extends StatefulWidget {
  const AllActivitiesScreen({super.key});

  @override
  State<AllActivitiesScreen> createState() => _AllActivitiesScreenState();
}

class _AllActivitiesScreenState extends State<AllActivitiesScreen> {
  List<ActivityModel> _activities = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final service = ActivityService();

    try {
      final results = await Future.wait([
        service.getActivities(),
        service.getHistory()
      ]);

      final activityRes = results[0];
      final historyRes = results[1];

      if (mounted) {
        setState(() {
          if (activityRes.data != null) {
            _activities = activityRes.data!;

            if (historyRes.data != null) {
              final historyList = historyRes.data!;
              Set<int> registeredIds = historyList.map((e) => e.hoatDongId ?? -1).toSet();

              for (var act in _activities) {
                if (registeredIds.contains(act.id)) {
                  act.isRegistered = true;
                }
              }
            }
          } else {
            _errorMessage = activityRes.message ?? "Lỗi tải dữ liệu";
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Lỗi kết nối: $e";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hoạt động Đoàn"),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
          : _activities.isEmpty
          ? const Center(child: Text("Hiện chưa có hoạt động nào."))
          : GridView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _activities.length,

        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,

          crossAxisSpacing: 10,
          mainAxisSpacing: 10,

          childAspectRatio: isLandscape ? 1.3 : 0.75,
        ),

        itemBuilder: (ctx, index) {
          final item = _activities[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActivityDetail(activity: item),
                  ),
                ).then((_) {
                  _loadData();
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      child: Image.network(
                        item.imageUrl ?? "https://via.placeholder.com/400x400",
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          color: Colors.grey[300],
                          child: const Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.tenHoatDong ?? "Hoạt động",
                            style: TextStyle(
                                fontSize: isLandscape ? 16 : 14,
                                fontWeight: FontWeight.bold
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const Spacer(),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item.thoiGianBatDau != null && item.thoiGianBatDau!.length >= 10
                                      ? item.thoiGianBatDau!.substring(0, 10)
                                      : "--/--",
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item.diaDiem ?? 'Chưa rõ',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}