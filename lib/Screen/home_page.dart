import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // TextEditingControllers
  TextEditingController nameProductController = TextEditingController();
  TextEditingController priceProductController = TextEditingController();
  // Lists
  List<dynamic> countersList = [];
  double cuentaTotal = 0.0;
  void totalPayments() async {
    Directory filePath = await getApplicationSupportDirectory();

    String counterRoute = '${filePath.path}/.counter.json';

    File counterFile = File(counterRoute);

    List<dynamic> listCounters = jsonDecode(await counterFile.readAsString());

    for (var value in listCounters) {
      print('este es el value $value');
      setState(() {
        double removeComma = double.parse(
            value['price'].toString().replaceAll(".", "").replaceAll(",", "."));

        print('Esto es el valor de removecomma $removeComma');
        cuentaTotal += removeComma * double.parse(value['counter'].toString());
      });
    }
  }

  _deleteCounter() async {
    Directory rutaScriptCounter = await getApplicationSupportDirectory();

    String counters = '${rutaScriptCounter.path}/.counter.json';

    File countersFile = File(counters);

    List<dynamic> countersLists = jsonDecode(await countersFile.readAsString());

    countersLists.removeLast();
    countersList = countersLists;
    await countersFile.writeAsString(jsonEncode(countersLists));

    String readNewListCounter = await countersFile.readAsString();
    setState(() {});
    print('Lista actualizada de arreglos $readNewListCounter');
  }

  _addCounter() async {
    Directory infPath = await getApplicationSupportDirectory();
    String configLocal = '${infPath.path}/.counter.json';

    File file = File(configLocal);

    if (countersList.isEmpty) {
      countersList = jsonDecode(await file.readAsString());
    }

    // file.writeAsString('');
    // file.delete();
    // countersList.clear();
    print('valor de counterList $countersList');
    dynamic isExist = countersList.firstWhere((value) {
      print(
          'este es el valor $value y este es el nombre ${nameProductController.text}');
      return value['nombre'] == nameProductController.text &&
          value['price'] == priceProductController.text;
    }, orElse: () {
      return [];
    });

    if (nameProductController.text == "" || priceProductController.text == "") {
      return showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text('Error'),
            content: Text('Los campos no pueden estar vacios'),
          );
        },
      );
    } else if (isExist.isNotEmpty) {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Este Articulo ya existe'),
            content: const Text('Ingrese un Articulo diferente'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'ok',
                    style: TextStyle(fontSize: 18),
                  ))
            ],
          );
        },
      );
    }

    if (!await file.exists() || countersList.isEmpty) {
      await file.create();
      final counterObj = {
        "id": 1,
        "nombre": nameProductController.text.substring(0, 1).toUpperCase() +
            nameProductController.text.substring(1),
        "price": priceProductController.text,
        "counter": 1,
      };

      countersList.add(counterObj);

      await file.writeAsString(jsonEncode(countersList));
    } else {
      List<dynamic> listCounter = jsonDecode(await file.readAsString());
      print('esta es la lista de contadores $listCounter');
      if (listCounter.isNotEmpty) {
        Map<String, dynamic> lastValueCounter = listCounter.last;
        print('Esto es el lasvaluecounter $lastValueCounter');
        countersList.add(lastValueCounter);
        lastValueCounter['id'] = lastValueCounter['id'] + 1;
        lastValueCounter['nombre'] =
            nameProductController.text.substring(0, 1).toUpperCase() +
                nameProductController.text.substring(1);
        lastValueCounter['price'] = priceProductController.text;
        lastValueCounter['counter'] = 1;
        file.writeAsString(jsonEncode(countersList));
      }
      listCounter.clear();
      // countersList.clear();
    }

    final currentCountersIs = await file.readAsString();
    setState(() {
      nameProductController.clear();
      priceProductController.clear();
    });

    print('Lista de contadores $currentCountersIs');
  }

  _uploadCounter() async {
    Directory filePath = await getApplicationSupportDirectory();

    String routeScriptCounter = '${filePath.path}/.counter.json';
    File counterFile = File(routeScriptCounter);

    countersList = jsonDecode(await counterFile.readAsString());
    setState(() {});
  }

  @override
  void initState() {
    _uploadCounter();
    totalPayments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final colorSecondary = Theme.of(context).colorScheme.inversePrimary;

    var orientation = MediaQuery.of(context).orientation;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: color,
          title: Text(
            widget.title,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    child: Container(
                      color: color,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 18.sw,
                          ),
                          SizedBox(
                              width: 59.sp,
                              child: Text(
                                'Articulo',
                                style: TextStyle(
                                    fontSize: 23.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                          SizedBox(
                            width:
                                orientation == Orientation.portrait ? 0 : 24.sw,
                          ),
                          SizedBox(
                            width: orientation == Orientation.portrait
                                ? 31.sp
                                : 32.sw,
                            child: Text(
                              'Precio',
                              style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: color,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 25.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 7,
                                    spreadRadius: 2,
                                    color: Colors.grey,
                                  )
                                ],
                                borderRadius: BorderRadius.circular(25),
                                color: Colors.white,
                              ),
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: TextField(
                                controller: nameProductController,
                                decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.all(15),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide.none)),
                              ),
                            ),
                            SizedBox(
                              width: 15.sp,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 7,
                                    spreadRadius: 2,
                                    color: Colors.grey,
                                  )
                                ],
                                borderRadius: BorderRadius.circular(25),
                                color: Colors.white,
                              ),
                              width: MediaQuery.of(context).size.width * 0.2,
                              child: TextField(
                                keyboardType: TextInputType.number,
                                controller: priceProductController,
                                decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.all(15),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide.none)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 3.sh,
            ),
            countersList.isEmpty
                ? const Center(
                    child: Text('Lista vacia'),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: countersList.length,
                      itemBuilder: (context, index) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      '${countersList[index]['nombre']}',
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                    SizedBox(
                                      width: 28.sp,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Precio: ${countersList[index]['price']}',
                                        style: TextStyle(fontSize: 18.sp),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 18.sp,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    countersList[index]['counter'].toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  ),
                                  const SizedBox(
                                    width: 25,
                                  ),
                                  ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll(color)),
                                      onPressed: () async {
                                        Directory filePath =
                                            await getApplicationSupportDirectory();

                                        File counterFile = File(
                                            '${filePath.path}/.counter.json');

                                        setState(() {
                                          countersList[index]['counter']++;
                                          counterFile.writeAsString(
                                              jsonEncode(countersList));
                                          totalPayments();
                                          cuentaTotal = 0;
                                        });
                                      },
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      )),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  ElevatedButton(
                                      style: const ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll(
                                                  Colors.red)),
                                      onPressed: () async {
                                        Directory filePath =
                                            await getApplicationSupportDirectory();

                                        File counterFile = File(
                                            '${filePath.path}/.counter.json');
                                        if (countersList[index]['counter'] <
                                            1) {
                                          return;
                                        }

                                        setState(() {
                                          countersList[index]['counter']--;
                                          counterFile.writeAsString(
                                              jsonEncode(countersList));
                                          totalPayments();
                                          cuentaTotal = 0;
                                        });
                                      },
                                      child: const Icon(
                                        Icons.remove,
                                        color: Colors.white,
                                      ))
                                ],
                              ),
                              const Divider(),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
            SizedBox(
              height: 37.sp,
            ),
          ],
        ),

        floatingActionButton: Container(
          width: orientation == Orientation.portrait ? 95.sw : 89.9.sw,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19), color: color),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: orientation == Orientation.portrait ? 0.1.sw : 0.1,
                ),
                FloatingActionButton(
                  backgroundColor: colorSecondary,
                  foregroundColor: Colors.black,
                  onPressed: () async {
                    await _deleteCounter();

                    totalPayments();
                    setState(() {
                      cuentaTotal = 0;
                    });
                  },
                  tooltip: 'Decrement',
                  child: const Icon(Icons.remove),
                ),
                SizedBox(
                  width: orientation == Orientation.portrait ? 6.2.sw : 6.4.sw,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 9.0),
                  child: SizedBox(
                    width:
                        orientation == Orientation.portrait ? 33.5.sw : 45.sw,
                    child: Text(
                      'Total \$${cuentaTotal.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18.sp, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(
                  width: 22.sw,
                ),
                FloatingActionButton(
                  backgroundColor: colorSecondary,
                  foregroundColor: Colors.black,
                  onPressed: () async {
                    await _addCounter();
                    setState(() {
                      cuentaTotal = 0;
                    });
                    totalPayments();
                  },
                  tooltip: 'Increment',
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
