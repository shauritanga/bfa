import 'package:flutter_test/flutter_test.dart';
import 'package:bfa/features/cart/domain/entities/cart_entity.dart';
import 'package:bfa/features/cart/domain/entities/cart_item_entity.dart';
import 'package:bfa/features/products/domain/entities/product_entity.dart';

void main() {
  group('CartEntity', () {
    late ProductEntity testProduct;
    late CartItemEntity testCartItem;

    setUp(() {
      testProduct = ProductEntity(
        id: 'product1',
        name: 'Test Product',
        description: 'Test Description',
        price: 10.0,
        quantity: 100.0,
        unit: 'kg',
        categoryId: 'category1',
        farmerId: 'farmer1',
        farmerName: 'Test Farmer',
        imageUrls: const [],
        tags: const [],
        isOrganic: false,
        isFeatured: false,
        isAvailable: true,
        rating: 4.5,
        reviewCount: 10,
        harvestDate: DateTime.now(),
        expiryDate: DateTime.now().add(const Duration(days: 7)),
        location: 'Test Location',
        nutritionalInfo: const {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      testCartItem = CartItemEntity.fromProduct(
        id: 'item1',
        userId: 'user1',
        product: testProduct,
        quantity: 2.0,
      );
    });

    test('should create empty cart', () {
      final cart = CartEntity.empty(id: 'cart1', userId: 'user1');

      expect(cart.isEmpty, true);
      expect(cart.itemCount, 0);
      expect(cart.total, 0.0);
    });

    test('should add item to cart', () {
      final cart = CartEntity.empty(id: 'cart1', userId: 'user1');
      final updatedCart = cart.addItem(testCartItem);

      expect(updatedCart.isEmpty, false);
      expect(updatedCart.itemCount, 1);
      expect(updatedCart.total, 20.0); // 2 * 10.0
    });

    test('should calculate totals correctly', () {
      final cart = CartEntity.empty(id: 'cart1', userId: 'user1');
      final updatedCart = cart.addItem(testCartItem);

      expect(updatedCart.subtotal, 20.0);
      expect(updatedCart.total, 20.0);
      expect(updatedCart.totalQuantity, 2.0);
    });

    test('should remove item from cart', () {
      final cart = CartEntity.empty(id: 'cart1', userId: 'user1');
      final cartWithItem = cart.addItem(testCartItem);
      final cartWithoutItem = cartWithItem.removeItem(testProduct.id);

      expect(cartWithoutItem.isEmpty, true);
      expect(cartWithoutItem.itemCount, 0);
    });

    test('should update item quantity', () {
      final cart = CartEntity.empty(id: 'cart1', userId: 'user1');
      final cartWithItem = cart.addItem(testCartItem);
      final updatedCart = cartWithItem.updateItemQuantity(testProduct.id, 5.0);

      expect(updatedCart.totalQuantity, 5.0);
      expect(updatedCart.total, 50.0); // 5 * 10.0
    });

    test('should check if product is in cart', () {
      final cart = CartEntity.empty(id: 'cart1', userId: 'user1');
      final cartWithItem = cart.addItem(testCartItem);

      expect(cartWithItem.containsProduct(testProduct.id), true);
      expect(cartWithItem.containsProduct('nonexistent'), false);
    });
  });
}
