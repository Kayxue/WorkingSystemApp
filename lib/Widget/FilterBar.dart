import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class FilterBar extends StatefulWidget {
  final Map<String, List<String>>? cityDistrictMap;
  final TextEditingController districtController;
  final String selectedCity;
  final String selectedDistrict;
  final Function(String) setCity;
  final Function(String) setDistrict;
  final PublishSubject<String> textSearchObservable;

  const FilterBar({
    super.key,
    required this.cityDistrictMap,
    required this.setCity,
    required this.setDistrict,
    required this.selectedCity,
    required this.selectedDistrict,
    required this.districtController,
    required this.textSearchObservable,
  });

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  var cityObservable = PublishSubject<String>();
  var districtObservable = PublishSubject<String>();

  @override
  void initState() {
    super.initState();
    cityObservable.distinct().listen((city) {
      widget.setCity(city);
    });
    districtObservable.distinct().listen((district) {
      widget.setDistrict(district);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          decoration: const InputDecoration(
            hint: Text("Search works", style: TextStyle(color: Colors.grey)),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => widget.textSearchObservable.add(value),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                child: DropdownMenu(
                  expandedInsets: EdgeInsets.zero,
                  requestFocusOnTap: false,
                  initialSelection: "",
                  dropdownMenuEntries: [
                    const DropdownMenuEntry<String>(value: "", label: "無指定縣市"),
                    if (widget.cityDistrictMap != null)
                      ...widget.cityDistrictMap!.keys.map(
                        (city) =>
                            DropdownMenuEntry<String>(value: city, label: city),
                      ),
                  ],
                  onSelected: (value) {
                    if (value != null) {
                      cityObservable.add(value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                child: DropdownMenu(
                  expandedInsets: EdgeInsets.zero,
                  initialSelection: "",
                  enabled: widget.selectedCity.isNotEmpty,
                  requestFocusOnTap: false,
                  dropdownMenuEntries: [
                    const DropdownMenuEntry<String>(value: "", label: "無指定區"),
                    if (widget.cityDistrictMap != null &&
                        widget.selectedCity.isNotEmpty)
                      ...widget.cityDistrictMap![widget.selectedCity]!.map(
                        (district) => DropdownMenuEntry<String>(
                          value: district,
                          label: district,
                        ),
                      ),
                  ],
                  controller: widget.districtController,
                  onSelected: (value) {
                    if (value != null) {
                      districtObservable.add(value);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
