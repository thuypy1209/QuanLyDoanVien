class ProductModel{
  int id;
  String name;
  double price;
  String imageUrl;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl = "",
  });
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      price: json['price'] == null ? 0: double.parse(json['price'].toString()),
      imageUrl: json['imageUrl'] ?? '', //de hinh default
    );
  }

  @override
  String toString() {
    return 'ProductModel{id: $id, name: $name, price: $price, imageUrl: $imageUrl}';
  }
}