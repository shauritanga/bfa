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
      print('🎉 Data seeding completed successfully in Firestore!');
    } catch (e) {
      print('⚠️ Firestore unavailable for remote seeding ($e), using local seeded catalog');
    }
  }

  /// Static sample categories list
  static List<CategoryEntity> get sampleCategories => [
      CategoryEntity(
        id: 'vegetables',
        name: 'Vegetables',
        description: 'Fresh vegetables from local farms',
        iconName: 'eco',
        subcategoryIds: const [],
        productCount: 4,
        isActive: true,
        sortOrder: 1,
        metadata: const {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryEntity(
        id: 'fruits',
        name: 'Fruits',
        description: 'Seasonal fruits and fresh harvest',
        iconName: 'apple',
        subcategoryIds: const [],
        productCount: 4,
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
        productCount: 3,
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
        iconName: 'circle',
        subcategoryIds: const [],
        productCount: 4,
        isActive: true,
        sortOrder: 4,
        metadata: const {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryEntity(
        id: 'herbs',
        name: 'Herbs',
        description: 'Fresh herbs and leafy seasonings',
        iconName: 'local_florist',
        subcategoryIds: const [],
        productCount: 3,
        isActive: true,
        sortOrder: 5,
        metadata: const {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryEntity(
        id: 'spices',
        name: 'Spices',
        description: 'Aromatic spices and seasonings',
        iconName: 'restaurant',
        subcategoryIds: const [],
        productCount: 4,
        isActive: true,
        sortOrder: 6,
        metadata: const {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryEntity(
        id: 'nuts',
        name: 'Nuts',
        description: 'Tree nuts and roasted snacks',
        iconName: 'nature',
        subcategoryIds: const [],
        productCount: 2,
        isActive: true,
        sortOrder: 7,
        metadata: const {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryEntity(
        id: 'seeds',
        name: 'Seeds',
        description: 'Nutritious edible seeds',
        iconName: 'scatter_plot',
        subcategoryIds: const [],
        productCount: 2,
        isActive: true,
        sortOrder: 8,
        metadata: const {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

  /// Seed categories to Firestore
  Future<void> seedCategories() async {
    print('📂 Seeding categories...');
    final categories = sampleCategories;
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

  /// Static sample products list
  static List<ProductEntity> get sampleProducts {
    final now = DateTime.now();
    final harvestDate = now.subtract(const Duration(days: 2));

    return [
      // ==========================================
      // 1. VEGETABLES
      // ==========================================
      ProductEntity(
        id: 'tomato-001',
        name: 'Fresh Organic Tomatoes',
        description:
            'Juicy red tomatoes, perfect for fresh salads, soups, and traditional stews. Grown organically with no chemical pesticides.',
        price: 3000.0,
        unit: 'kg',
        categoryId: 'vegetables',
        farmerId: 'owner-001',
        farmerName: 'FreshCrops Farm',
        imageUrls: const [
          'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500',
        ],
        quantity: 50.0,
        discountPrice: 2500.0,
        isAvailable: true,
        isOrganic: true,
        isFeatured: true,
        harvestDate: harvestDate,
        expiryDate: now.add(const Duration(days: 7)),
        location: 'Morogoro, Tanzania',
        rating: 4.8,
        reviewCount: 34,
        nutritionalInfo: const {
          'calories': '18 kcal',
          'vitamin_c': '28mg',
          'potassium': '237mg',
          'fiber': '1.2g',
        },
        tags: const ['fresh', 'organic', 'vegetables', 'salad'],
        createdAt: now,
        updatedAt: now,
      ),
      ProductEntity(
        id: 'spinach-001',
        name: 'Crisp Baby Spinach',
        description:
            'Tender baby spinach leaves, rich in iron and vitamins. Perfect for sautéing, smoothies, and fresh green salads.',
        price: 2000.0,
        unit: 'bunch',
        categoryId: 'vegetables',
        farmerId: 'owner-001',
        farmerName: 'FreshCrops Farm',
        imageUrls: const [
          'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=500',
        ],
        quantity: 40.0,
        isAvailable: true,
        isOrganic: true,
        isFeatured: false,
        harvestDate: harvestDate,
        expiryDate: now.add(const Duration(days: 4)),
        location: 'Arusha, Tanzania',
        rating: 4.6,
        reviewCount: 19,
        nutritionalInfo: const {
          'calories': '23 kcal',
          'iron': '2.7mg',
          'vitamin_k': '483mcg',
          'folate': '194mcg',
        },
        tags: const ['leafy', 'organic', 'vegetables', 'iron-rich'],
        createdAt: now,
        updatedAt: now,
      ),
      ProductEntity(
        id: 'onion-001',
        name: 'Farm Fresh Red Onions',
        description:
            'Aromatic, crunchy red onions essential for rich flavoring in everyday culinary dishes. Cured for long shelf life.',
        price: 2200.0,
        unit: 'kg',
        categoryId: 'vegetables',
        farmerId: 'owner-001',
        farmerName: 'FreshCrops Farm',
        imageUrls: const [
          'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=500',
        ],
        quantity: 80.0,
        isAvailable: true,
        isOrganic: false,
        isFeatured: false,
        harvestDate: harvestDate.subtract(const Duration(days: 5)),
        expiryDate: now.add(const Duration(days: 30)),
        location: 'Singida, Tanzania',
        rating: 4.5,
        reviewCount: 22,
        nutritionalInfo: const {
          'calories': '40 kcal',
          'vitamin_c': '7.4mg',
          'fiber': '1.7g',
        },
        tags: const ['cooking', 'vegetables', 'aromatic', 'staple'],
        createdAt: now,
        updatedAt: now,
      ),
      ProductEntity(
        id: 'carrot-001',
        name: 'Crunchy Farm Carrots',
        description:
            'Naturally sweet and crunchy orange carrots. Rich in beta-carotene and vitamin A, great for snacking and cooking.',
        price: 2500.0,
        unit: 'kg',
        categoryId: 'vegetables',
        farmerId: 'owner-001',
        farmerName: 'FreshCrops Farm',
        imageUrls: const [
          'https://images.unsplash.com/photo-1445282768818-728615cc910a?w=500',
        ],
        quantity: 60.0,
        isAvailable: true,
        isOrganic: true,
        isFeatured: true,
        harvestDate: harvestDate,
        expiryDate: now.add(const Duration(days: 14)),
        location: 'Lushoto, Tanzania',
        rating: 4.7,
        reviewCount: 28,
        nutritionalInfo: const {
          'calories': '41 kcal',
          'beta_carotene': '8285mcg',
          'fiber': '2.8g',
        },
        tags: const ['crunchy', 'beta-carotene', 'vegetables', 'healthy'],
        createdAt: now,
        updatedAt: now,
      ),

      // ==========================================
      // 2. FRUITS
      // ==========================================
      ProductEntity(
        id: 'banana-001',
        name: 'Sweet Cavendish Bananas',
        description:
            'Naturally ripened sweet bananas packed with energy and potassium. Ideal for breakfast, snacks, or smoothies.',
        price: 2000.0,
        unit: 'bunch',
        categoryId: 'fruits',
        farmerId: 'owner-001',
        farmerName: 'Kilimanjaro Orchards',
        imageUrls: const [
          'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=500',
        ],
        quantity: 70.0,
        isAvailable: true,
        isOrganic: true,
        isFeatured: true,
        harvestDate: harvestDate,
        expiryDate: now.add(const Duration(days: 6)),
        location: 'Moshi, Tanzania',
        rating: 4.8,
        reviewCount: 42,
        nutritionalInfo: const {
          'calories': '89 kcal',
          'potassium': '358mg',
          'vitamin_b6': '0.4mg',
        },
        tags: const ['fruits', 'sweet', 'potassium', 'energy'],
        createdAt: now,
        updatedAt: now,
      ),
      ProductEntity(
        id: 'mango-001',
        name: 'Ripe Juicy Mangoes (Dodo)',
        description:
            'Luscious, fragrant tropical mangoes with vibrant golden pulp. Handpicked at peak sweetness and ripeness.',
        price: 3500.0,
        unit: 'kg',
        categoryId: 'fruits',
        farmerId: 'owner-001',
        farmerName: 'Kilimanjaro Orchards',
        imageUrls: const [
          'https://images.unsplash.com/photo-1553279768-865429fa0078?w=500',
        ],
        quantity: 50.0,
        discountPrice: 3000.0,
        isAvailable: true,
        isOrganic: true,
        isFeatured: true,
        harvestDate: harvestDate,
        expiryDate: now.add(const Duration(days: 5)),
        location: 'Tanga, Tanzania',
        rating: 4.9,
        reviewCount: 51,
        nutritionalInfo: const {
          'calories': '60 kcal',
          'vitamin_c': '36mg',
          'vitamin_a': '1082IU',
        },
        tags: const ['tropical', 'fruits', 'sweet', 'vitamin-c'],
        createdAt: now,
        updatedAt: now,
      ),
      ProductEntity(
        id: 'avocado-001',
        name: 'Fresh Hass Avocados',
        description:
            'Buttery smooth Hass avocados rich in heart-healthy monounsaturated fats. Perfect for salads and toast.',
        price: 4000.0,
        unit: 'piece',
        categoryId: 'fruits',
        farmerId: 'owner-001',
        farmerName: 'Kilimanjaro Orchards',
        imageUrls: const [
          'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=500',
        ],
        quantity: 45.0,
        isAvailable: true,
        isOrganic: true,
        isFeatured: false,
        harvestDate: harvestDate,
        expiryDate: now.add(const Duration(days: 7)),
        location: 'Mbeya, Tanzania',
        rating: 4.7,
        reviewCount: 33,
        nutritionalInfo: const {
          'calories': '160 kcal',
          'healthy_fats': '15g',
          'fiber': '7g',
        },
        tags: const ['healthy-fats', 'creamy', 'fruits', 'superfood'],
        createdAt: now,
        updatedAt: now,
      ),
      ProductEntity(
        id: 'apple-001',
        name: 'Crisp Red Apples',
        description:
            'Crisp, sweet red apples bursting with refreshing flavor. High in dietary fiber and antioxidants.',
        price: 4500.0,
        unit: 'kg',
        categoryId: 'fruits',
        farmerId: 'owner-001',
        farmerName: 'Kilimanjaro Orchards',
        imageUrls: const [
          'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=500',
        ],
        quantity: 35.0,
        isAvailable: true,
        isOrganic: false,
        isFeatured: true,
        harvestDate: harvestDate.subtract(const Duration(days: 4)),
        expiryDate: now.add(const Duration(days: 20)),
        location: 'Iringa, Tanzania',
        rating: 4.6,
        reviewCount: 27,
        nutritionalInfo: const {
          'calories': '52 kcal',
          'fiber': '2.4g',
          'vitamin_c': '4.6mg',
        },
        tags: const ['crisp', 'sweet', 'fruits', 'antioxidants'],
        createdAt: now,
        updatedAt: now,
      ),

      // ==========================================
      // 3. GRAINS
      // ==========================================
      ProductEntity(
        id: 'rice-001',
        name: 'Organic Brown Rice (Mchele)',
        description:
            'Aromatic, unpolished brown rice preserving all natural bran and germ nutrients. Rich nutty flavor and high fiber.',
        price: 3200.0,
        unit: 'kg',
        categoryId: 'grains',
        farmerId: 'owner-001',
        farmerName: 'Ruvuma Grains Cooperative',
        imageUrls: const [
          'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500',
        ],
        quantity: 150.0,
        isAvailable: true,
        isOrganic: true,
        isFeatured: true,
        harvestDate: harvestDate.subtract(const Duration(days: 20)),
        expiryDate: now.add(const Duration(days: 365)),
        location: 'Morogoro, Tanzania',
        rating: 4.7,
        reviewCount: 39,
        nutritionalInfo: const {
          'calories': '111 kcal',
          'fiber': '1.8g',
          'protein': '2.6g',
        },
        tags: const ['grains', 'whole-grain', 'staple', 'fiber-rich'],
        createdAt: now,
        updatedAt: now,
      ),
      ProductEntity(
        id: 'corn-001',
        name: 'Fresh Sweet Corn (Mahindi)',
        description:
            'Tender, sweet golden corn cobs fresh from the stalk. Delicious boiled, roasted, or tossed into warm bowls.',
        price: 1500.0,
        unit: 'piece',
        categoryId: 'grains',
        farmerId: 'owner-001',
        farmerName: 'Ruvuma Grains Cooperative',
        imageUrls: const [
          'https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=500',
        ],
        quantity: 90.0,
        isAvailable: true,
        isOrganic: false,
        isFeatured: false,
        harvestDate: harvestDate,
        expiryDate: now.add(const Duration(days: 6)),
        location: 'Iringa, Tanzania',
        rating: 4.5,
        reviewCount: 18,
        nutritionalInfo: const {
          'calories': '86 kcal',
          'fiber': '2.4g',
          'vitamin_c': '6.8mg',
        },
        tags: const ['corn', 'grains', 'sweet', 'fresh'],
        createdAt: now,
        updatedAt: now,
      ),
      ProductEntity(
        id: 'wheat-001',
        name: 'Golden Whole Wheat (Ngano)',
        description:
            'Premium quality whole wheat berries, thoroughly cleaned and ready for milling into wholesome flour.',
        price: 2600.0,
        unit: 'kg',
        categoryId: 'grains',
        farmerId: 'owner-001',
        farmerName: 'Ruvuma Grains Cooperative',
        imageUrls: const [
          'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=500',
        ],
        quantity: 120.0,
        isAvailable: true,
        isOrganic: true,
        isFeatured: false,
        harvestDate: harvestDate.subtract(const Duration(days: 15)),
        expiryDate: now.add(const Duration(days: 300)),
        location: 'Arusha, Tanzania',
        rating: 4.4,
        reviewCount: 14,
        nutritionalInfo: const {
          'calories': '340 kcal',
          'protein': '13.2g',
          'fiber': '10.7g',
        },
        tags: const ['wheat', 'grains', 'baking', 'flour'],
        createdAt: now,
        updatedAt: now,
      ),

      // ==========================================
      // 4. LEGUMES
      // ==========================================
      ProductEntity(
        id: 'beans-001',
        name: 'Organic Black Beans (Maharage)',
        description:
            'Protein-packed black beans, ideal for traditional stews, bean soups, and rice pairings. Rich in fiber and antioxidants.',
        price: 4500.0,
        unit: 'kg',
        categoryId: 'legumes',
        farmerId: 'owner-001',
        farmerName: 'Highland Legumes Group',
        imageUrls: const [
          'https://images.unsplash.com/photo-1583258292688-d0213dc5a3a8?w=500',
        ],
        quantity: 65.0,
        isAvailable: true,
        isOrganic: true,
        isFeatured: true,
        harvestDate: harvestDate.subtract(const Duration(days: 30)),
        expiryDate: now.add(const Duration(days: 365)),
        location: 'Mbeya, Tanzania',
        rating: 4.6,
        reviewCount: 25,
        nutritionalInfo: const {
          'calories': '132 kcal',
          'protein': '8.9g',
          'fiber': '8.7g',
        },
        tags: const ['legumes', 'protein-rich', 'beans', 'fiber'],
        createdAt: now,
        updatedAt: now,
      ),
      ProductEntity(
        id: 'peas-001',
        name: 'Fresh Green Garden Peas (Njegere)',
        description:
            'Plump, sweet green garden peas shelled fresh from pods. Great in curries, stews, and vegetable pilau.',
        price: 3800.0,
        unit: 'kg',
        categoryId: 'legumes',
        farmerId: 'owner-001',
        farmerName: 'Highland Legumes Group',
        imageUrls: const [
          'https://images.unsplash.com/photo-1587735243615-c03f25aaff15?w=500',
        ],
        quantity: 40.0,
        isAvailable: true,
        isOrganic: true,
        isFeatured: false,
        harvestDate: harvestDate,
        expiryDate: now.add(const Duration(days: 5)),
        location: 'Lushoto, Tanzania',
        rating: 4.7,
        reviewCount: 31,
        nutritionalInfo: const {
          'calories': '81 kcal',
          'protein': '5.4g',
          'vitamin_c': '40mg',
        },
        tags: const ['peas', 'legumes', 'sweet', 'fresh'],
        createdAt: now,
        updatedAt: now,
      ),
      ProductEntity(
        id: 'chickpeas-001',
        name: 'Golden Chickpeas (Dengu)',
        description:
            'Nutrient-dense dried chickpeas, perfect for making velvety hummus, spicy curries, or nourishing soups.',
        price: 4000.0,
        unit: 'kg',
        categoryId: 'legumes',
        farmerId: 'owner-001',
        farmerName: 'Highland Legumes Group',
        imageUrls: const [
          'https://images.unsplash.com/photo-1515543237350-b3eea1ec8082?w=500',
        ],
        quantity: 55.0,
        isAvailable: true,
        isOrganic: false,
        isFeatured: true,
        harvestDate: harvestDate.subtract(const Duration(days: 40)),
        expiryDate: now.add(const Duration(days: 365)),
        location: 'Dodoma, Tanzania',
        rating: 4.5,
        reviewCount: 20,
        nutritionalInfo: const {
          'calories': '164 kcal',
          'protein': '8.9g',
          'fiber': '7.6g',
        },
        tags: const ['chickpeas', 'legumes', 'protein', 'staple'],
        createdAt: now,
        updatedAt: now,
      ),
      ProductEntity(
        id: 'lentils-001',
        name: 'Red Split Lentils',
        description:
            'Quick-cooking red lentils that break down into smooth, hearty dahls and comforting winter soups.',
        price: 4200.0,
        unit: 'kg',
        categoryId: 'legumes',
        farmerId: 'owner-001',
        farmerName: 'Highland Legumes Group',
        imageUrls: const [
          'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=500',
        ],
        quantity: 50.0,
        isAvailable: true,
        isOrganic: true,
        isFeatured: false,
        harvestDate: harvestDate.subtract(const Duration(days: 35)),
        expiryDate: now.add(const Duration(days: 365)),
        location: 'Babati, Tanzania',
        rating: 4.6,
        reviewCount: 17,
        nutritionalInfo: const {
          'calories': '116 kcal',
          'protein': '9.0g',
          'iron': '3.3mg',
        },
        tags: const ['lentils', 'legumes', 'quick-cook', 'dahl'],
        createdAt: now,
        updatedAt: now,
      ),

      // ==========================================
      // 5. HERBS
      // ==========================================
      ProductEntity(
        id: 'basil-001',
        name: 'Fresh Sweet Basil (Rihani)',
        description:
            'Fragrant sweet basil with vibrant aroma. Perfect for pesto, pasta sauces, teas, and Mediterranean seasoning.',
        price: 1500.0,
        unit: 'bunch',
        categoryId: 'herbs',
        farmerId: 'owner-001',
        farmerName: 'Zanzibar Spice & Herb Gardens',
        imageUrls: const [
          'https://images.unsplash.com/photo-1618164436241-4473940d1f5c?w=500',
        ],
        quantity: 30.0,
        isAvailable: true,
        isOrganic: true,
        isFeatured: true,
        harvestDate: harvestDate,
        expiryDate: now.add(const Duration(days: 5)),
        location: 'Zanzibar, Tanzania',
        rating: 4.8,
        reviewCount: 22,
        nutritionalInfo: const {
          'calories': '22 kcal',
          'vitamin_k': '414mcg',
          'vitamin_a': '5275IU',
        },
        tags: const ['herbs', 'fragrant', 'aromatic', 'pesto'],
        createdAt: now,
        updatedAt: now,
      ),
      ProductEntity(
        id: 'mint-001',
        name: 'Aromatic Spearmint (Nanaa)',
        description:
            'Crisp, refreshing spearmint leaves. Wonderful for brewed herbal teas, chilled mojitos, and dessert garnishes.',
        price: 1200.0,
        unit: 'bunch',
        categoryId: 'herbs',
        farmerId: 'owner-001',
        farmerName: 'Zanzibar Spice & Herb Gardens',
        imageUrls: const [
          'https://images.unsplash.com/photo-1628556270448-4d4e4148e1b1?w=500',
        ],
        quantity: 35.0,
        isAvailable: true,
        isOrganic: true,
        isFeatured: false,
        harvestDate: harvestDate,
        expiryDate: now.add(const Duration(days: 5)),
        location: 'Zanzibar, Tanzania',
        rating: 4.6,
        reviewCount: 16,
        nutritionalInfo: const {
          'calories': '44 kcal',
          'iron': '11.8mg',
          'vitamin_a': '4054IU',
        },
        tags: const ['mint', 'herbs', 'refreshing', 'tea'],
        createdAt: now,
        updatedAt: now,
      ),
      ProductEntity(
        id: 'rosemary-001',
        name: 'Fresh Rosemary Sprigs',
        description:
            'Piney, fragrant rosemary needles on sturdy stems. Enhances roasted vegetables, meats, and infused oils.',
        price: 1800.0,
        unit: 'bunch',
        categoryId: 'herbs',
        farmerId: 'owner-001',
        farmerName: 'Zanzibar Spice & Herb Gardens',
        imageUrls: const [
          'https://images.unsplash.com/photo-1515586000433-45406d8e6662?w=500',
        ],
        quantity: 25.0,
        isAvailable: true,
        isOrganic: true,
        isFeatured: false,
        harvestDate: harvestDate,
        expiryDate: now.add(const Duration(days: 8)),
        location: 'Arusha, Tanzania',
        rating: 4.7,
        reviewCount: 14,
        nutritionalInfo: const {
          'calories': '131 kcal',
          'calcium': '317mg',
          'fiber': '14.1g',
        },
        tags: const ['rosemary', 'herbs', 'roasting', 'aromatic'],
        createdAt: now,
        updatedAt: now,
      ),

      // ==========================================
      // 6. SPICES
      // ==========================================
      ProductEntity(
        id: 'ginger-001',
        name: 'Fresh Ginger Root (Tangawizi)',
        description:
            'Spicy, zesty ginger rhizomes fresh from the soil. Essential for teas, traditional marinades, and stir-fries.',
        price: 3000.0,
        unit: 'kg',
        categoryId: 'spices',
        farmerId: 'owner-001',
        farmerName: 'Zanzibar Spice & Herb Gardens',
        imageUrls: const [
          'https://images.unsplash.com/photo-1599940859674-a7fef05b94ae?w=500',
        ],
        quantity: 45.0,
        isAvailable: true,
        isOrganic: true,
        isFeatured: true,
        harvestDate: harvestDate.subtract(const Duration(days: 6)),
        expiryDate: now.add(const Duration(days: 25)),
        location: 'Rungwe, Tanzania',
        rating: 4.8,
        reviewCount: 35,
        nutritionalInfo: const {
          'calories': '80 kcal',
          'gingerol': 'high',
          'potassium': '415mg',
        },
        tags: const ['ginger', 'spices', 'zesty', 'immune-boost'],
        createdAt: now,
        updatedAt: now,
      ),
      ProductEntity(
        id: 'cloves-001',
        name: 'Zanzibar Whole Cloves (Karafuu)',
        description:
            'World-famous fragrant whole cloves from Zanzibar island. Powerful spice for pilau, biryani, and spiced teas.',
        price: 6500.0,
        unit: 'pack',
        categoryId: 'spices',
        farmerId: 'owner-001',
        farmerName: 'Zanzibar Spice & Herb Gardens',
        imageUrls: const [
          'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=500',
        ],
        quantity: 40.0,
        discountPrice: 5800.0,
        isAvailable: true,
        isOrganic: true,
        isFeatured: true,
        harvestDate: harvestDate.subtract(const Duration(days: 20)),
        expiryDate: now.add(const Duration(days: 365)),
        location: 'Pemba, Zanzibar',
        rating: 4.9,
        reviewCount: 46,
        nutritionalInfo: const {
          'calories': '274 kcal',
          'eugenol': 'very high',
          'fiber': '33.9g',
        },
        tags: const ['cloves', 'spices', 'zanzibar', 'aromatic'],
        createdAt: now,
        updatedAt: now,
      ),
      ProductEntity(
        id: 'cinnamon-001',
        name: 'Pure Cinnamon Sticks (Mdalasini)',
        description:
            'Naturally dried Ceylon cinnamon quills. Delivers warm, sweet fragrance and deep flavor to drinks and pastries.',
        price: 4000.0,
        unit: 'pack',
        categoryId: 'spices',
        farmerId: 'owner-001',
        farmerName: 'Zanzibar Spice & Herb Gardens',
        imageUrls: const [
          'https://images.unsplash.com/photo-1509358271058-acd22cc93898?w=500',
        ],
        quantity: 35.0,
        isAvailable: true,
        isOrganic: false,
        isFeatured: false,
        harvestDate: harvestDate.subtract(const Duration(days: 15)),
        expiryDate: now.add(const Duration(days: 365)),
        location: 'Tanga, Tanzania',
        rating: 4.7,
        reviewCount: 29,
        nutritionalInfo: const {
          'calories': '247 kcal',
          'calcium': '1002mg',
          'fiber': '53.1g',
        },
        tags: const ['cinnamon', 'spices', 'sweet', 'baking'],
        createdAt: now,
        updatedAt: now,
      ),
      ProductEntity(
        id: 'turmeric-001',
        name: 'Raw Turmeric Rhizomes (Manjano)',
        description:
            'Vibrant golden turmeric roots loaded with curcumin. Ideal for golden milk, seasoning curries, and natural remedies.',
        price: 3500.0,
        unit: 'kg',
        categoryId: 'spices',
        farmerId: 'owner-001',
        farmerName: 'Zanzibar Spice & Herb Gardens',
        imageUrls: const [
          'https://images.unsplash.com/photo-1615485500704-8e990f9900f7?w=500',
        ],
        quantity: 30.0,
        isAvailable: true,
        isOrganic: true,
        isFeatured: false,
        harvestDate: harvestDate.subtract(const Duration(days: 8)),
        expiryDate: now.add(const Duration(days: 30)),
        location: 'Morogoro, Tanzania',
        rating: 4.8,
        reviewCount: 21,
        nutritionalInfo: const {
          'calories': '354 kcal',
          'curcumin': 'active',
          'iron': '41.4mg',
        },
        tags: const ['turmeric', 'spices', 'golden', 'anti-inflammatory'],
        createdAt: now,
        updatedAt: now,
      ),

      // ==========================================
      // 7. NUTS
      // ==========================================
      ProductEntity(
        id: 'cashew-001',
        name: 'Roasted Cashew Nuts (Korosho)',
        description:
            'Premium jumbo cashew nuts from southern Tanzania, lightly salted and roasted to crunchy perfection.',
        price: 8500.0,
        unit: 'pack',
        categoryId: 'nuts',
        farmerId: 'owner-001',
        farmerName: 'Mtwara Cashew Processors',
        imageUrls: const [
          'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=500',
        ],
        quantity: 50.0,
        discountPrice: 7800.0,
        isAvailable: true,
        isOrganic: true,
        isFeatured: true,
        harvestDate: harvestDate.subtract(const Duration(days: 25)),
        expiryDate: now.add(const Duration(days: 180)),
        location: 'Mtwara, Tanzania',
        rating: 4.9,
        reviewCount: 58,
        nutritionalInfo: const {
          'calories': '553 kcal',
          'healthy_fats': '43.8g',
          'protein': '18.2g',
        },
        tags: const ['cashews', 'nuts', 'snack', 'roasted'],
        createdAt: now,
        updatedAt: now,
      ),
      ProductEntity(
        id: 'almond-001',
        name: 'Raw Organic Almonds',
        description:
            'Whole unroasted almonds rich in vitamin E, magnesium, and dietary fiber. Delicious in trail mixes and baking.',
        price: 9000.0,
        unit: 'pack',
        categoryId: 'nuts',
        farmerId: 'owner-001',
        farmerName: 'Mtwara Cashew Processors',
        imageUrls: const [
          'https://images.unsplash.com/photo-1508061253366-f7da158b6d46?w=500',
        ],
        quantity: 40.0,
        isAvailable: true,
        isOrganic: true,
        isFeatured: false,
        harvestDate: harvestDate.subtract(const Duration(days: 30)),
        expiryDate: now.add(const Duration(days: 200)),
        location: 'Arusha, Tanzania',
        rating: 4.8,
        reviewCount: 32,
        nutritionalInfo: const {
          'calories': '579 kcal',
          'vitamin_e': '25.6mg',
          'protein': '21.2g',
        },
        tags: const ['almonds', 'nuts', 'healthy', 'protein'],
        createdAt: now,
        updatedAt: now,
      ),

      // ==========================================
      // 8. SEEDS
      // ==========================================
      ProductEntity(
        id: 'sunflower-001',
        name: 'Roasted Sunflower Seeds (Alizeti)',
        description:
            'Crisp, lightly toasted sunflower seeds packed with zinc and essential fatty acids. Great for snacking or salad toppings.',
        price: 2500.0,
        unit: 'pack',
        categoryId: 'seeds',
        farmerId: 'owner-001',
        farmerName: 'Central Plains Seed Growers',
        imageUrls: const [
          'https://images.unsplash.com/photo-1597848212624-a19eb35e2651?w=500',
        ],
        quantity: 60.0,
        isAvailable: true,
        isOrganic: false,
        isFeatured: true,
        harvestDate: harvestDate.subtract(const Duration(days: 10)),
        expiryDate: now.add(const Duration(days: 180)),
        location: 'Singida, Tanzania',
        rating: 4.6,
        reviewCount: 24,
        nutritionalInfo: const {
          'calories': '584 kcal',
          'vitamin_e': '35.2mg',
          'protein': '20.8g',
        },
        tags: const ['seeds', 'sunflower', 'snack', 'healthy'],
        createdAt: now,
        updatedAt: now,
      ),
      ProductEntity(
        id: 'pumpkin-001',
        name: 'Raw Pumpkin Seeds (Mbegu za Maboga)',
        description:
            'Mineral-rich raw green pumpkin seeds (pepitas). Superb source of magnesium, zinc, and plant-based protein.',
        price: 4500.0,
        unit: 'pack',
        categoryId: 'seeds',
        farmerId: 'owner-001',
        farmerName: 'Central Plains Seed Growers',
        imageUrls: const [
          'https://images.unsplash.com/photo-1514733670139-4d87a1941d55?w=500',
        ],
        quantity: 45.0,
        isAvailable: true,
        isOrganic: true,
        isFeatured: true,
        harvestDate: harvestDate.subtract(const Duration(days: 12)),
        expiryDate: now.add(const Duration(days: 180)),
        location: 'Dodoma, Tanzania',
        rating: 4.7,
        reviewCount: 30,
        nutritionalInfo: const {
          'calories': '559 kcal',
          'zinc': '7.8mg',
          'magnesium': '592mg',
        },
        tags: const ['seeds', 'pumpkin', 'pepitas', 'zinc-rich'],
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  /// Seed products to Firestore
  Future<void> seedProducts() async {
    print('🥕 Seeding products...');
    await _seedProductBatch(sampleProducts, 'All products');
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
    print('✅ $batchName (${products.length} products) seeded');
  }
}
