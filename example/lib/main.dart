import 'package:flutter/material.dart';
import 'package:muscle_selector/muscle_selector.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: HomeView(),
      theme: ThemeData.light(),
    );
  }
}

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Set<Muscle>? selectedMuscles;
  Map<String, MuscleIntensity> selectedMuscleGroups = {};
  String selectedMap = Maps.BODY;
  final GlobalKey<MusclePickerMapState> _mapKey = GlobalKey();

  @override
  void initState() {
    selectedMuscleGroups["chest"] = MuscleIntensity.light;
    selectedMuscleGroups["biceps"] = MuscleIntensity.hard;
    selectedMuscleGroups["triceps"] = MuscleIntensity.hard;
    selectedMuscleGroups["shoulders"] = MuscleIntensity.medium;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _mapKey.currentState?.clearSelect();
              setState(() {
                selectedMuscles = null;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.swap_horizontal_circle, color: Colors.red),
            onPressed: () {
              setState(() {
                if(selectedMap == Maps.BODY){
                  selectedMap = Maps.FRONT_BODY;
                }else
                if(selectedMap == Maps.FRONT_BODY){
                  selectedMap = Maps.BACK_BODY;
                }else
                if(selectedMap == Maps.BACK_BODY){
                  selectedMap = Maps.BODY;
                }
              });
            },
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          scaleEnabled: true,
          panEnabled: true,
          constrained: true,
          child: Padding(
            padding: const EdgeInsets.only(right: 30.0),
            child: Align(
              alignment: Alignment.center,
              child: Transform.scale(
                scale: 1.2,
                child: MuscleIntensityMap(
                  key: _mapKey,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  map: selectedMap,
                  initialSelectedGroups: selectedMuscleGroups,
                  onChanged: (muscles) {
                    setState(() {
                      selectedMuscles = muscles;
                    });
                  },
                  strokeColor: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
