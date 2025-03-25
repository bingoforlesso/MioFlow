import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddressFormPage extends StatefulWidget {
  final Map<String, dynamic>? address;
  
  const AddressFormPage({super.key, this.address});

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _nameController.text = widget.address!['name'] as String;
      _phoneController.text = widget.address!['phone'] as String;
      _addressController.text = widget.address!['address'] as String;
      _isDefault = widget.address!['isDefault'] as bool;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.address != null;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Text(
          isEditing ? '编辑地址' : '新增地址',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '收货人姓名',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return '请输入收货人姓名';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: '联系电话',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return '请输入联系电话';
                }
                if (!RegExp(r'^\d{11}$').hasMatch(value!)) {
                  return '请输入正确的手机号码';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: '详细地址',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return '请输入详细地址';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('设为默认地址'),
              value: _isDefault,
              onChanged: (value) {
                setState(() {
                  _isDefault = value;
                });
              },
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  // TODO: Save address
                  final address = {
                    'name': _nameController.text,
                    'phone': _phoneController.text,
                    'address': _addressController.text,
                    'isDefault': _isDefault,
                  };
                  context.pop(address);
                }
              },
              child: Text(isEditing ? '保存修改' : '保存地址'),
            ),
          ],
        ),
      ),
    );
  }
}