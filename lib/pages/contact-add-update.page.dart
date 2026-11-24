import 'package:flutter/material.dart';
import '../model/contact.model.dart';
import '../services/contact.service.dart';

class ContactAddUpdatePage extends StatefulWidget {
  final Contact? contact;
  const ContactAddUpdatePage({super.key, this.contact});

  @override
  State<ContactAddUpdatePage> createState() => _ContactAddUpdatePageState();
}

class _ContactAddUpdatePageState extends State<ContactAddUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _telController;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.contact?.nom ?? '');
    _telController = TextEditingController(text: widget.contact?.tel ?? '');
  }

  @override
  void dispose() {
    _nomController.dispose();
    _telController.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    if (_formKey.currentState!.validate()) {
      String nom = _nomController.text.trim();
      String tel = _telController.text.trim();

      if (widget.contact == null) {
        // Ajout
        Contact newContact = Contact(nom: nom, tel: tel);
        await ContactService.instance.insertContact(newContact);
      } else {
        // Modification
        Contact updatedContact = Contact(
          id: widget.contact!.id,
          nom: nom,
          tel: tel,
        );
        await ContactService.instance.updateContact(updatedContact);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.contact != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier Contact' : 'Nouveau Contact'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom du contact',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez saisir un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _telController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez saisir un numéro de téléphone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: _saveContact,
                child: Text(
                  isEditing ? 'Mettre à jour' : 'Enregistrer',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
