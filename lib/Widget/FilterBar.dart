import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';

class Filterbar extends StatefulWidget {
  final Map<String, List<String>>? cityDistrictMap;
  final TextEditingController districtController;
  final String selectedCity;
  final String selectedDistrict;
  final Function(String) setCity;
  final Function(String) setDistrict;
  final PublishSubject<String> textSearchObservable;

  const Filterbar({
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
  State<Filterbar> createState() => _FilterbarState();
}

class _FilterbarState extends State<Filterbar> {
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
          decoration: InputDecoration(
            hint: Text("Search works", style: TextStyle(color: Colors.grey)),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => widget.textSearchObservable.add(value),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                child: DropdownMenu(
                  expandedInsets: EdgeInsets.zero,
                  enableSearch: false,
                  initialSelection: "",
                  dropdownMenuEntries: [
                    DropdownMenuEntry<String>(value: "", label: "無指定縣市"),
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
            SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                child: DropdownMenu(
                  expandedInsets: EdgeInsets.zero,
                  initialSelection: "",
                  dropdownMenuEntries: [
                    DropdownMenuEntry<String>(value: "", label: "無指定區"),
                    if (widget.cityDistrictMap != null)
                      ...(widget.selectedCity.isEmpty
                          ? (widget.cityDistrictMap!.values.flattenedToSet.map(
                              (district) => DropdownMenuEntry<String>(
                                value: district,
                                label: district,
                              ),
                            ))
                          : widget.cityDistrictMap![widget.selectedCity]!.map(
                              (district) => DropdownMenuEntry<String>(
                                value: district,
                                label: district,
                              ),
                            )),
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
