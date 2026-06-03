import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/products/domain/entities/product_entity.dart';
import '../features/products/domain/entities/category_entity.dart';
import '../core/config/firebase_config.dart';

/// Service to seed Firestore with sample data
class DataSeedingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Seed all data (categories and products)
  Future<void> seedAllData() async {
    print('🌱 Starting data seeding...');

    try {
      await seedCategories();
      await seedProducts();
      print('🎉 Data seeding completed successfully!');
    } catch (e) {
      print('❌ Error during seeding: $e');
      rethrow;
    }
  }

  /// Seed categories
  Future<void> seedCategories() async {
    print('📂 Seeding categories...');

    final categories = [
      CategoryEntity(
        id: 'vegetables',
        name: 'Vegetables',
        description: 'Fresh vegetables from local farms',
        iconName: 'eco',
        subcategoryIds: const [],
        productCount: 0,
        isActive: true,
        sortOrder: 1,
        metadata: const {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryEntity(
        id: 'fruits',
        name: 'Fruits',
        description: 'Seasonal fruits and berries',
        iconName: 'apple',
        subcategoryIds: const [],
        productCount: 0,
        isActive: true,
        sortOrder: 2,
        metadata: const {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryEntity(
        id: 'grains',
        name: 'Grains',
        description: 'Cereals and grain products',
        iconName: 'grain',
        subcategoryIds: const [],
        productCount: 0,
        isActive: true,
        sortOrder: 3,
        metadata: const {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryEntity(
        id: 'legumes',
        name: 'Legumes',
        description: 'Beans, peas, and lentils',
        iconName: 'spa',
        subcategoryIds: const [],
        productCount: 0,
        isActive: true,
        sortOrder: 4,
        metadata: const {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    final batch = _firestore.batch();

    for (final category in categories) {
      final docRef = _firestore
          .collection(FirebaseCollections.categories)
          .doc(category.id);
      batch.set(docRef, category.toMap());
    }

    await batch.commit();
    print('✅ Categories seeded');
  }

  /// Seed products
  Future<void> seedProducts() async {
    print('🥕 Seeding products...');

    final now = DateTime.now();
    final harvestDate = now.subtract(const Duration(days: 2));
    final expiryDate = now.add(const Duration(days: 7));

    final products = [
      // Vegetables
      ProductEntity(
        id: 'tomato-001',
        name: 'Fresh Tomatoes',
        description:
            'Juicy red tomatoes, perfect for salads and cooking. Grown organically without pesticides.',
        price: 3500.0, // TSH per kg
        unit: 'kg',
        categoryId: 'vegetables',
        farmerId: 'owner-001',
        farmerName: 'FreshCrops Store',
        imageUrls: const [
          'https://images.unsplash.com/photo-1546470427-e26264be0b0d?w=400',
          'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=400',
        ],
        quantity: 50.0,
        discountPrice: 3000.0,
        isAvailable: true,
        isOrganic: true,
        isFeatured: true,
        harvestDate: harvestDate,
        expiryDate: expiryDate,
        location: 'Available in Store',
        rating: 4.8,
        reviewCount: 24,
        nutritionalInfo: const {
          'calories': 18,
          'vitamin_c': '28mg',
          'potassium': '237mg',
          'fiber': '1.2g',
        },
        tags: const ['fresh', 'organic', 'local', 'vitamin-rich'],
        createdAt: now,
        updatedAt: now,
      ),

      ProductEntity(
        id: 'spinach-001',
        name: 'Baby Spinach',
        description:
            'Tender baby spinach leaves, rich in iron and vitamins. Perfect for salads and smoothies.',
        price: 2500.0,
        unit: 'bunch',
        categoryId: 'vegetables',
        farmerId: 'owner-001',
        farmerName: 'FreshCrops Store',
        imageUrls: const [
          'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400',
        ],
        quantity: 30.0,
        isAvailable: true,
        isOrganic: true,
        isFeatured: false,
        harvestDate: harvestDate,
        expiryDate: now.add(const Duration(days: 3)),
        location: 'Available in Store',
        rating: 4.6,
        reviewCount: 18,
        nutritionalInfo: const {
          'calories': 23,
          'iron': '2.7mg',
          'vitamin_k': '483mcg',
          'folate': '194mcg',
        },
        tags: const ['fresh', 'organic', 'iron-rich', 'leafy-green'],
        createdAt: now,
        updatedAt: now,
      ),

      ProductEntity(
        id: 'carrot-001',
        name: 'Fresh Carrots',
        description:
            'Crunchy orange carrots, perfect for cooking and snacking. Rich in beta-carotene.',
        price: 2800.0,
        unit: 'kg',
        categoryId: 'vegetables',
        farmerId: 'owner-001',
        farmerName: 'FreshCrops Store',
        imageUrls: const [
          'https://images.unsplash.com/photo-1445282768818-728615cc910a?w=400',
        ],
        quantity: 40.0,
        isAvailable: true,
        isOrganic: true,
        isFeatured: false,
        harvestDate: harvestDate,
        expiryDate: now.add(const Duration(days: 14)),
        location: 'Available in Store',
        rating: 4.5,
        reviewCount: 21,
        nutritionalInfo: const {
          'calories': 41,
          'beta_carotene': '8285mcg',
          'fiber': '2.8g',
          'vitamin_k': '13.2mcg',
        },
        tags: const ['crunchy', 'beta-carotene', 'healthy', 'versatile'],
        createdAt: now,
        updatedAt: now,
      ),

      ProductEntity(
        id: 'onion-001',
        name: 'Red Onions',
        description:
            'Fresh red onions with a mild flavor. Essential for cooking and adds great taste to dishes.',
        price: 2200.0,
        unit: 'kg',
        categoryId: 'vegetables',
        farmerId: 'owner-001',
        farmerName: 'FreshCrops Store',
        imageUrls: const [
          'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=400',
        ],
        quantity: 60.0,
        isAvailable: true,
        isOrganic: false,
        isFeatured: false,
        harvestDate: harvestDate,
        expiryDate: now.add(const Duration(days: 30)),
        location: 'Available in Store',
        rating: 4.3,
        reviewCount: 15,
        nutritionalInfo: const {
          'calories': 40,
          'vitamin_c': '7.4mg',
          'fiber': '1.7g',
          'quercetin': 'high',
        },
        tags: const ['cooking', 'flavor', 'essential', 'storage-friendly'],
        createdAt: now,
        updatedAt: now,
      ),
    ];

    // Seed first batch
    await _seedProductBatch(products, 'First batch');

    // Seed remaining products
    await _seedRemainingProducts(now, harvestDate);
  }

  /// Seed remaining products to complete 10 products
  Future<void> _seedRemainingProducts(
    DateTime now,
    DateTime harvestDate,
  ) async {
    final products = [
      // Fruits
      ProductEntity(
        id: 'banana-001',
        name: 'Sweet Bananas',
        description:
            'Naturally sweet bananas, perfect for snacking or baking. Rich in potassium and energy.',
        price: 1500.0,
        unit: 'bunch',
        categoryId: 'fruits',
        farmerId: 'owner-001',
        farmerName: 'FreshCrops Store',
        imageUrls: const [
          'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400',
        ],
        quantity: 100.0,
        isAvailable: true,
        isOrganic: false,
        isFeatured: true,
        harvestDate: harvestDate,
        expiryDate: now.add(const Duration(days: 5)),
        location: 'Available in Store',
        rating: 4.7,
        reviewCount: 32,
        nutritionalInfo: const {
          'calories': 89,
          'potassium': '358mg',
          'vitamin_b6': '0.4mg',
          'fiber': '2.6g',
        },
        tags: const ['sweet', 'energy', 'potassium', 'natural'],
        createdAt: now,
        updatedAt: now,
      ),

      ProductEntity(
        id: 'mango-001',
        name: 'Ripe Mangoes',
        description:
            'Sweet and juicy mangoes, bursting with tropical flavor. High in vitamin C and antioxidants.',
        price: 4000.0,
        unit: 'piece',
        categoryId: 'fruits',
        farmerId: 'owner-001',
        farmerName: 'FreshCrops Store',
        imageUrls: const [
          'https://images.unsplash.com/photo-1553279768-865429fa0078?w=400',
        ],
        quantity: 75.0,
        discountPrice: 3500.0,
        isAvailable: true,
        isOrganic: true,
        isFeatured: true,
        harvestDate: harvestDate,
        expiryDate: now.add(const Duration(days: 4)),
        location: 'Available in Store',
        rating: 4.9,
        reviewCount: 45,
        nutritionalInfo: const {
          'calories': 60,
          'vitamin_c': '36mg',
          'vitamin_a': '1082IU',
          'fiber': '1.6g',
        },
        tags: const ['tropical', 'sweet', 'vitamin-c', 'antioxidants'],
        createdAt: now,
        updatedAt: now,
      ),
    ];

    await _seedProductBatch(products, 'Second batch');
    await _seedFinalProducts(now, harvestDate);
  }

  /// Seed final products
  Future<void> _seedFinalProducts(DateTime now, DateTime harvestDate) async {
    final products = [
      // Grains
      ProductEntity(
        id: 'rice-001',
        name: 'Organic Brown Rice',
        description:
            'Nutritious brown rice with a nutty flavor. High in fiber and essential nutrients.',
        price: 3200.0,
        unit: 'kg',
        categoryId: 'grains',
        farmerId: 'owner-001',
        farmerName: 'FreshCrops Store',
        imageUrls: const [
          'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400',
        ],
        quantity: 200.0,
        isAvailable: true,
        isOrganic: true,
        isFeatured: true,
        harvestDate: harvestDate.subtract(const Duration(days: 30)),
        expiryDate: now.add(const Duration(days: 365)),
        location: 'Available in Store',
        rating: 4.7,
        reviewCount: 38,
        nutritionalInfo: const {
          'calories': 111,
          'fiber': '1.8g',
          'protein': '2.6g',
          'magnesium': '43mg',
        },
        tags: const ['whole-grain', 'fiber-rich', 'nutritious', 'staple'],
        createdAt: now,
        updatedAt: now,
      ),

      ProductEntity(
        id: 'maize-001',
        name: 'Sweet Corn',
        description:
            'Fresh sweet corn on the cob. Perfect for grilling or boiling. Naturally sweet and tender.',
        price: 1800.0,
        unit: 'piece',
        categoryId: 'grains',
        farmerId: 'owner-001',
        farmerName: 'FreshCrops Store',
        imageUrls: const [
          'https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=400',
        ],
        quantity: 80.0,
        isAvailable: true,
        isOrganic: false,
        isFeatured: false,
        harvestDate: harvestDate,
        expiryDate: now.add(const Duration(days: 5)),
        location: 'Available in Store',
        rating: 4.4,
        reviewCount: 27,
        nutritionalInfo: const {
          'calories': 86,
          'fiber': '2.4g',
          'vitamin_c': '6.8mg',
          'thiamine': '0.2mg',
        },
        tags: const ['sweet', 'tender', 'grilling', 'fresh'],
        createdAt: now,
        updatedAt: now,
      ),

      // Legumes
      ProductEntity(
        id: 'beans-001',
        name: 'Black Beans',
        description:
            'Protein-rich black beans, perfect for stews and salads. High in fiber and antioxidants.',
        price: 4500.0,
        unit: 'kg',
        categoryId: 'legumes',
        farmerId: 'owner-001',
        farmerName: 'FreshCrops Store',
        imageUrls: const [
          'https://images.unsplash.com/photo-1583258292688-d0213dc5a3a8?w=400',
        ],
        quantity: 25.0,
        isAvailable: true,
        isOrganic: true,
        isFeatured: false,
        harvestDate: harvestDate.subtract(const Duration(days: 60)),
        expiryDate: now.add(const Duration(days: 730)),
        location: 'Available in Store',
        rating: 4.6,
        reviewCount: 19,
        nutritionalInfo: const {
          'calories': 132,
          'protein': '8.9g',
          'fiber': '8.7g',
          'folate': '256mcg',
        },
        tags: const ['protein-rich', 'fiber', 'antioxidants', 'versatile'],
        createdAt: now,
        updatedAt: now,
      ),

      // More fruits
      ProductEntity(
        id: 'avocado-001',
        name: 'Hass Avocados',
        description:
            'Creamy Hass avocados, perfect for guacamole or toast. Rich in healthy fats and vitamins.',
        price: 5000.0,
        unit: 'piece',
        categoryId: 'fruits',
        farmerId: 'owner-001',
        farmerName: 'FreshCrops Store',
        imageUrls: const [
          'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=400',
        ],
        quantity: 35.0,
        discountPrice: 4500.0,
        isAvailable: true,
        isOrganic: true,
        isFeatured: true,
        harvestDate: harvestDate,
        expiryDate: now.add(const Duration(days: 6)),
        location: 'Available in Store',
        rating: 4.8,
        reviewCount: 42,
        nutritionalInfo: const {
          'calories': 160,
          'healthy_fats': '15g',
          'fiber': '7g',
          'potassium': '485mg',
        },
        tags: const ['healthy-fats', 'creamy', 'superfood', 'versatile'],
        createdAt: now,
        updatedAt: now,
      ),
    ];

    await _seedProductBatch(products, 'Final batch');
  }

  /// Helper method to seed a batch of products
  Future<void> _seedProductBatch(
    List<ProductEntity> products,
    String batchName,
  ) async {
    final batch = _firestore.batch();

    for (final product in products) {
      final docRef = _firestore
          .collection(FirebaseCollections.products)
          .doc(product.id);
      batch.set(docRef, product.toMap());
    }

    await batch.commit();
    print('✅ $batchName of products seeded');
  }
}
