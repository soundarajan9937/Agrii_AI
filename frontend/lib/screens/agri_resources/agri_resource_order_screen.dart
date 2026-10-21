import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/agri_resource_model.dart';
import '../../services/agri_resource_service.dart';

class AgriResourceOrderScreen extends StatefulWidget {
  final AgriResourceModel resource;
  const AgriResourceOrderScreen({super.key, required this.resource});

  @override
  State<AgriResourceOrderScreen> createState() => _AgriResourceOrderScreenState();
}

class _AgriResourceOrderScreenState extends State<AgriResourceOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final AgriResourceService _service = AgriResourceService();

  String buyerName = '';
  String buyerPhone = '';
  String deliveryAddress = '';
  String paymentMethod = 'Cash on Delivery';
  bool isOrdering = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      buyerName = prefs.getString("name") ?? "";
      buyerPhone = prefs.getString("phone") ?? "";
    });
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.blue),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => isOrdering = true);

    final success = await _service.placeOrder(
      buyerName: buyerName,
      resourceId: widget.resource.id,
      sellerId: widget.resource.sellerId,
      price: widget.resource.price,
      paymentMethod: paymentMethod,
      buyerPhone: buyerPhone,
      deliveryAddress: deliveryAddress,
    );

    setState(() => isOrdering = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Order placed successfully! Farmer will contact you soon."),
        backgroundColor: Colors.blue,
      ));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Failed to place order. Try again."),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Resource"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Ordering: ${widget.resource.name}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text("Price: ₹${widget.resource.price}", style: const TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold)),
              const Divider(height: 40),
              TextFormField(
                initialValue: buyerName,
                decoration: _inputDecoration("Buyer Name"),
                onSaved: (v) => buyerName = v!,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                initialValue: buyerPhone,
                decoration: _inputDecoration("Your Phone Number"),
                keyboardType: TextInputType.phone,
                onSaved: (v) => buyerPhone = v!,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                decoration: _inputDecoration("Delivery Address"),
                maxLines: 3,
                onSaved: (v) => deliveryAddress = v!,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 25),
              const Text("Select Payment Method", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              RadioListTile(
                title: const Text("Cash on Delivery"),
                value: "Cash on Delivery",
                groupValue: paymentMethod,
                activeColor: Colors.blue,
                onChanged: (v) => setState(() => paymentMethod = v.toString()),
              ),
              RadioListTile(
                title: Text("GPay (${widget.resource.phoneNumber})"),
                value: "GPay",
                groupValue: paymentMethod,
                activeColor: Colors.blue,
                onChanged: (v) => setState(() => paymentMethod = v.toString()),
              ),
              const SizedBox(height: 30),
              isOrdering
                  ? const Center(child: CircularProgressIndicator(color: Colors.blue))
                  : SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _placeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("CONFIRM ORDER", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
