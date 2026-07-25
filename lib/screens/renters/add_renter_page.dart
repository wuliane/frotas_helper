import 'package:flutter/material.dart';

import '../../core/database/database_helper.dart';
import '../../models/renter_model.dart';

class AddRenterPage extends StatefulWidget {
  final RenterModel? renter;

  const AddRenterPage({
    super.key,
    this.renter,
  });

  @override
  State<AddRenterPage> createState() => _AddRenterPageState();
}

class _AddRenterPageState extends State<AddRenterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _rgController = TextEditingController();
  final _cnhController = TextEditingController();
  final _cnhCategoryController = TextEditingController();
  final _cnhExpirationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _notesController = TextEditingController();

  bool _saving = false;

  bool get _isEditing => widget.renter != null;

  @override
  void initState() {
    super.initState();

    final renter = widget.renter;

    if (renter != null) {
      _nameController.text = renter.name;
      _cpfController.text = renter.cpf;
      _rgController.text = renter.rg;
      _cnhController.text = renter.cnh;
      _cnhCategoryController.text = renter.cnhCategory;
      _cnhExpirationController.text = renter.cnhExpiration;
      _phoneController.text = renter.phone;
      _emailController.text = renter.email;
      _addressController.text = renter.address;
      _emergencyContactController.text = renter.emergencyContact;
      _notesController.text = renter.notes;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _rgController.dispose();
    _cnhController.dispose();
    _cnhCategoryController.dispose();
    _cnhExpirationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }

    return null;
  }

  Future<void> _selectCnhExpiration() async {
    final currentDate = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(currentDate.year + 20),
    );

    if (selectedDate == null) {
      return;
    }

    _cnhExpirationController.text =
        '${selectedDate.day.toString().padLeft(2, '0')}/'
        '${selectedDate.month.toString().padLeft(2, '0')}/'
        '${selectedDate.year}';
  }

  Future<void> _saveRenter() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final renter = RenterModel(
        id: widget.renter?.id,
        name: _nameController.text.trim(),
        cpf: _cpfController.text.trim(),
        rg: _rgController.text.trim(),
        cnh: _cnhController.text.trim(),
        cnhCategory: _cnhCategoryController.text.trim().toUpperCase(),
        cnhExpiration: _cnhExpirationController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        emergencyContact: _emergencyContactController.text.trim(),
        notes: _notesController.text.trim(),
      );

      if (_isEditing) {
        await DatabaseHelper.instance.updateRenter(renter);
      } else {
        await DatabaseHelper.instance.insertRenter(renter);
      }

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível salvar: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar locatário' : 'Cadastrar locatário',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cpfController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'CPF',
                      ),
                      validator: _requiredValidator,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _rgController,
                      decoration: const InputDecoration(
                        labelText: 'RG',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _cnhController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Número da CNH',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cnhCategoryController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                        hintText: 'B',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _cnhExpirationController,
                      readOnly: true,
                      onTap: _selectCnhExpiration,
                      decoration: const InputDecoration(
                        labelText: 'Validade da CNH',
                        suffixIcon: Icon(Icons.calendar_month_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefone / WhatsApp',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _addressController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Endereço completo',
                  prefixIcon: Icon(Icons.home_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emergencyContactController,
                decoration: const InputDecoration(
                  labelText: 'Contato de emergência',
                  hintText: 'Nome e telefone',
                  prefixIcon: Icon(Icons.contact_emergency_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _saveRenter,
                  icon: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _saving
                        ? 'Salvando...'
                        : _isEditing
                            ? 'Salvar alterações'
                            : 'Salvar locatário',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}