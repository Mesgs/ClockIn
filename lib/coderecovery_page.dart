import 'package:flutter/material.dart';
import 'passwordchange_page.dart'; // Importa a próxima página
import 'sendemail_page.dart'; // Importa a tela anterior

class CodeRecoveryPage extends StatefulWidget {
  const CodeRecoveryPage({super.key});

  @override
  State<CodeRecoveryPage> createState() => _CodeRecoveryPageState();
}

class _CodeRecoveryPageState extends State<CodeRecoveryPage> {
  final _codeController = TextEditingController(); // Controlador para o código
  final _formKey = GlobalKey<FormState>(); // Chave do formulário para validação

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Fundo azul
      body: Stack(
        children: [
          // Botão de seta para voltar sobre o fundo azul
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SendEmailPage()),
                );
              },
            ),
          ),

          // Conteúdo principal com o formulário
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(24),
                width: MediaQuery.of(context).size.width * 0.8, // Largura responsiva
                decoration: BoxDecoration(
                  color: Colors.white, // Fundo branco
                  borderRadius: BorderRadius.circular(30), // Bordas arredondadas
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey, // Associando o formulário à chave
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Enter Recovery Code',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Please enter the code sent to your email.',
                        style: TextStyle(color: Colors.blue),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Campo de código de recuperação com validação
                      TextFormField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Recovery Code',
                          hintText: 'Enter your code',
                          border: UnderlineInputBorder(),
                        ),
                        validator: (code) {
                          if (code == null || code.isEmpty) {
                            return 'Por favor, insira o código de recuperação.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Botão "TO ENTER"
                      ElevatedButton(
                        onPressed: () {
                          // Verifica se o formulário é válido antes de prosseguir
                          if (_formKey.currentState!.validate()) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PasswordChangePage(),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('TO ENTER'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}