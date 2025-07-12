import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const CedulaCheckerApp());
}

class CedulaCheckerApp extends StatelessWidget {
  const CedulaCheckerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CI.UY',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.lightBlue),
          ),
        ),
      ),
      home: const CedulaHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CedulaHomePage extends StatefulWidget {
  const CedulaHomePage({super.key});

  @override
  State<CedulaHomePage> createState() => _CedulaHomePageState();
}

class _CedulaHomePageState extends State<CedulaHomePage> {
  final TextEditingController _controllerVerificar = TextEditingController();
  final TextEditingController _controllerCalcular = TextEditingController();

  String _resultVerificar = '';
  String _resultCalcular = '';

  bool _canVerify = false;
  bool _canCalculate = false;

  bool _verifyFieldError = false;
  bool _calculateFieldError = false;

  final List<String> _historial = [];

  @override
  void initState() {
    super.initState();
    _controllerVerificar.addListener(_updateVerifyButton);
    _controllerCalcular.addListener(_updateCalculateButton);
  }

  @override
  void dispose() {
    _controllerVerificar.dispose();
    _controllerCalcular.dispose();
    super.dispose();
  }

  void _updateVerifyButton() {
    final text = _controllerVerificar.text.trim().replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    setState(() {
      _canVerify = text.length >= 7 && text.length <= 8;
      _verifyFieldError = !_canVerify && text.isNotEmpty;
    });
  }

  void _updateCalculateButton() {
    final text = _controllerCalcular.text.trim().replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    setState(() {
      _canCalculate = text.length == 7;
      _calculateFieldError = !_canCalculate && text.isNotEmpty;
    });
  }

  bool validarCedula(String cedula) {
    cedula = cedula.replaceAll(RegExp(r'[^0-9]'), '');
    if (cedula.length < 7 || cedula.length > 8) {
      return false;
    }
    List<int> coeficientes = [2, 9, 8, 7, 6, 3, 4];
    List<int> digitos = cedula.split('').map(int.parse).toList();

    int suma = 0;
    for (int i = 0; i < coeficientes.length; i++) {
      suma += digitos[i] * coeficientes[i];
    }

    int resto = suma % 10;
    int digitoVerificador = resto == 0 ? 0 : 10 - resto;

    return digitoVerificador == digitos.last;
  }

  int calcularDigitoVerificador(String numero) {
    numero = numero.replaceAll(RegExp(r'[^0-9]'), '');
    if (numero.length != 7) {
      return -1;
    }

    List<int> coeficientes = [2, 9, 8, 7, 6, 3, 4];
    List<int> digitos = numero.split('').map(int.parse).toList();

    int suma = 0;
    for (int i = 0; i < coeficientes.length; i++) {
      suma += digitos[i] * coeficientes[i];
    }

    int resto = suma % 10;
    int digitoVerificador = resto == 0 ? 0 : 10 - resto;

    return digitoVerificador;
  }

  void _verificarCedula() {
    String cedula = _controllerVerificar.text.trim();
    bool esValida = validarCedula(cedula);

    setState(() {
      _resultVerificar = esValida ? '✅ Cédula válida' : '❌ Cédula inválida';
      _historial.insert(0, 'Verificar: $cedula ➜ $_resultVerificar');
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_resultVerificar)));
  }

  void _calcularDigito() {
    String numero = _controllerCalcular.text.trim();
    int digito = calcularDigitoVerificador(numero);

    setState(() {
      if (digito == -1) {
        _resultCalcular = '❌ Debe tener 7 dígitos';
      } else {
        _resultCalcular = 'Número completo: $numero-$digito';
      }
      _historial.insert(0, 'Calcular: $numero ➜ $_resultCalcular');
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_resultCalcular)));
  }

  void _clearVerificar() {
    _controllerVerificar.clear();
    setState(() {
      _resultVerificar = '';
      _verifyFieldError = false;
    });
  }

  void _clearCalcular() {
    _controllerCalcular.clear();
    setState(() {
      _resultCalcular = '';
      _calculateFieldError = false;
    });
  }

  void _goToHistorial() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HistorialPage(historial: _historial, onClear: _clearHistorial),
      ),
    );
  }

  void _clearHistorial() {
    setState(() {
      _historial.clear();
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final verifyBorderColor = _verifyFieldError ? Colors.red : Colors.grey;
    final calculateBorderColor = _calculateFieldError
        ? Colors.red
        : Colors.grey;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CI.UY'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _historial.isNotEmpty ? _goToHistorial : null,
            tooltip: 'Ver historial',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset('assets/uruguay.png', height: 200),
              const SizedBox(height: 20),
              const Text(
                'Una aplicación para validar número de cédula de identidad uruguaya o calcular dígito verificador',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              const Text(
                'Verificar una cédula',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _controllerVerificar,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: verifyBorderColor),
                  ),
                  labelText: 'Ingresa la cédula',
                  hintText: 'Ej: 12345678',
                  suffixIcon: _controllerVerificar.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _clearVerificar,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _canVerify ? _verificarCedula : null,
                child: const Text('Verificar'),
              ),
              Text(_resultVerificar, style: const TextStyle(fontSize: 18)),

              const Divider(height: 40),

              const Text(
                'Calcular dígito verificador',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _controllerCalcular,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: calculateBorderColor),
                  ),
                  labelText: 'Ingresa cédula sin guión',
                  hintText: 'Ej: 1234567',
                  suffixIcon: _controllerCalcular.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _clearCalcular,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _canCalculate ? _calcularDigito : null,
                child: const Text('Calcular dígito'),
              ),
              Text(_resultCalcular, style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}

class HistorialPage extends StatelessWidget {
  final List<String> historial;
  final VoidCallback onClear;

  const HistorialPage({
    super.key,
    required this.historial,
    required this.onClear,
  });

  void _shareHistorial() {
    if (historial.isNotEmpty) {
      Share.share(historial.join('\n'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: historial.isNotEmpty ? _shareHistorial : null,
            tooltip: 'Compartir historial',
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: historial.isNotEmpty ? onClear : null,
            tooltip: 'Limpiar historial',
          ),
        ],
      ),
      body: historial.isEmpty
          ? const Center(child: Text('No hay resultados aún.'))
          : ListView.builder(
              padding: const EdgeInsets.all(20.0),
              itemCount: historial.length,
              itemBuilder: (context, index) {
                return Text(historial[index]);
              },
            ),
    );
  }
}
