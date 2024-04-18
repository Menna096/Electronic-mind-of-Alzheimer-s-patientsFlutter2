import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vv/Family/Registerfamily/registerfamily.dart';
import 'package:vv/GPS/map_location_picker.dart';
import 'package:vv/GPS/autocomplete_view.dart';
import 'package:vv/map_location_picker.dart';

void main() {
  runApp(
    const MaterialApp(
      home: Gps(),
      debugShowCheckedModeBanner: false,
    ),
  );
}


  class Gps extends StatefulWidget {
  const Gps({Key? key}) : super(key: key);

  @override
  State<Gps> createState() => _GpsState();
}

class _GpsState extends State<Gps> {
  late double Lati = 0.0;
  late double Long = 0.0;
  String address = "No Information";
  String autocompletePlace = "No Information";
  Prediction? initialValue;

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('location picker'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PlacesAutocomplete(
            searchController: _controller,
            apiKey: 'AIzaSyDc7BLNnR3cQAhlKRDUgpcZYssqgDIHWxc',
            mounted: mounted,
            hideBackButton: true,
            onGetDetailsByPlaceId: (PlacesDetailsResponse? result) {
              if (result != null) {
                setState(() {
                  autocompletePlace = result.result.formattedAddress ?? "";
                });
              }
            },
          ),
          OutlinedButton(
            child: Text('show dialog'.toUpperCase()),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Example'),
                    content: PlacesAutocomplete(
                      apiKey: "AIzaSyDc7BLNnR3cQAhlKRDUgpcZYssqgDIHWxc",
                      searchHintText: "Search for a place",
                      mounted: mounted,
                      hideBackButton: true,
                      initialValue: initialValue,
                      onSuggestionSelected: (value) {
                        setState(() {
                          autocompletePlace =
                              value.structuredFormatting?.mainText ?? "";
                          initialValue = value;
                        });
                      },
                      onGetDetailsByPlaceId: (value) {
                        setState(() {
                          address = value?.result.formattedAddress ?? "";
                        });
                      },
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Done'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Google Map Location Picker 🚀",
              textAlign: TextAlign.center,
              textScaleFactor: 1.2,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Clipboard.setData(
              const ClipboardData(text: ""),
            ).then(
              (value) => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Copied to Clipboard"),
                ),
              ),
            ),
            child: const Text("https://www.mohesu.com"),
          ),
          const Spacer(),
          Center(
            child: ElevatedButton(
              child: const Text('Pick location'),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return MapLocationPicker(
                        apiKey: 'AIzaSyDc7BLNnR3cQAhlKRDUgpcZYssqgDIHWxc',
                        popOnNextButtonTaped: true,
                        currentLatLng: const LatLng(29.146727, 76.464895),
                        onNext: (GeocodingResult? result) {
                          if (result != null) {
                            setState(() {
                              Lati = result.geometry.location.lat;
                              Long = result.geometry.location.lng;

                              address = result.formattedAddress ?? "";
                              print(Lati);
                              print(Long);
                            });
                          }
                        },
                        onSuggestionSelected: (PlacesDetailsResponse? result) {
                          if (result != null) {
                            setState(() {
                              autocompletePlace =
                                  result.result.formattedAddress ?? "";
                            });
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const Spacer(),
          ListTile(
            title: Text("Geocoded Address: $address"),
          ),
          ListTile(
            title: Text("Autocomplete Address: $autocompletePlace"),
          ),
          const Spacer(
            flex: 3,
          ),
          
        ],
      ),
    );
  }
}