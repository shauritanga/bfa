# Database Seeding Instructions

This document explains how to seed your Firestore database with sample crop products for the Best Farmers app.

## 🌱 Sample Data Overview

The seeding will add:

- **4 Categories**: Vegetables, Fruits, Grains, Legumes
- **10 Products**: Various crop products with realistic data
- **Single Owner**: All products belong to "Best Farmers Store" (no individual farmers)

### Products Included:

1. **Fresh Tomatoes** (Vegetables) - TSH 3,500/kg
2. **Baby Spinach** (Vegetables) - TSH 2,500/bunch
3. **Fresh Carrots** (Vegetables) - TSH 2,800/kg
4. **Red Onions** (Vegetables) - TSH 2,200/kg
5. **Sweet Bananas** (Fruits) - TSH 1,500/bunch
6. **Ripe Mangoes** (Fruits) - TSH 4,000/piece
7. **Hass Avocados** (Fruits) - TSH 5,000/piece
8. **Organic Brown Rice** (Grains) - TSH 3,200/kg
9. **Sweet Corn** (Grains) - TSH 1,800/piece
10. **Black Beans** (Legumes) - TSH 4,500/kg

## 🚀 How to Seed Data

### Option 1: Automatic Seeding (Recommended)

1. **Enable automatic seeding** in `lib/main.dart`:

   ```dart
   void _checkAuthAndNavigate() {
     Future.delayed(const Duration(milliseconds: 2500), () async {
       // Uncomment the line below to seed data
       await _seedSampleData();  // <-- Uncomment this line

       if (mounted) {
         Navigator.of(context).pushReplacement(
           MaterialPageRoute(builder: (context) => const MainNavigationPage()),
         );
       }
     });
   }
   ```

2. **Run the app**:

   ```bash
   flutter run
   ```

3. **Data will be seeded automatically** when the app starts

4. **Comment out the seeding line** after first run to avoid duplicate data:
   ```dart
   // await _seedSampleData();  // <-- Comment this back out
   ```

### Option 2: Manual Import via Firebase Console

1. **Open Firebase Console**:

   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select your project
   - Navigate to Firestore Database

2. **Import Categories**:

   - Create a collection named `categories`
   - Add 4 documents using the data from `scripts/sample_data.json`
   - Use the `id` field as the document ID

3. **Import Products**:
   - Create a collection named `products`
   - Add 10 documents using the data from `scripts/sample_data.json`
   - Use the `id` field as the document ID

## ✅ Verification

After seeding, you should see:

1. **Home Screen**: Products displayed in the grid layout
2. **Categories**: 4 categories available in the categories section
3. **Product Details**: Each product has complete information including:
   - Images from Unsplash
   - Nutritional information
   - Pricing in TSH
   - Ratings and reviews
   - Availability status

## 🔧 Customization

To modify the sample data:

1. **Edit the seeding service**: `lib/scripts/seed_data.dart`
2. **Update product information**: Change prices, descriptions, quantities
3. **Add more products**: Follow the existing pattern in the seeding methods
4. **Modify categories**: Update the categories in the `seedCategories()` method

## 📝 Data Structure

### Categories

- `id`: Unique identifier
- `name`: Display name
- `description`: Category description
- `iconName`: Icon identifier
- `isActive`: Availability status
- `sortOrder`: Display order

### Products

- `id`: Unique identifier
- `name`: Product name
- `description`: Detailed description
- `price`: Price in TSH
- `unit`: Measurement unit (kg, piece, bunch)
- `categoryId`: Reference to category
- `farmerId`: Owner identifier (always "owner-001")
- `farmerName`: Store name (always "FreshCrops Store")
- `imageUrls`: Array of image URLs
- `quantity`: Available stock
- `location`: Always "Available in Store"
- `nutritionalInfo`: Nutritional data object
- `tags`: Array of descriptive tags
- `rating`: Average rating (1-5)
- `reviewCount`: Number of reviews
- `isOrganic`: Organic certification status
- `isFeatured`: Featured product flag
- `isAvailable`: Availability status
- `harvestDate`: Harvest timestamp
- `expiryDate`: Expiration timestamp

## 🚨 Important Notes

1. **Run seeding only once** to avoid duplicate data
2. **Comment out the seeding call** after the first run
3. **Check Firebase security rules** to ensure write permissions
4. **Verify internet connection** for image URLs to load properly
5. **All products use the same owner** ("FreshCrops Store") since this is a single-owner app

## 🛠️ Troubleshooting

### Common Issues:

1. **Permission Denied**: Check Firebase security rules
2. **Images Not Loading**: Verify internet connection and Unsplash URLs
3. **Duplicate Data**: Make sure to run seeding only once
4. **Build Errors**: Ensure all dependencies are installed with `flutter pub get`

### Error Messages:

- `❌ Error seeding sample data`: Check Firebase configuration and permissions
- `Firebase not initialized`: Verify Firebase setup in `main.dart`
- `Collection not found`: Ensure Firestore is enabled in Firebase Console

## 📞 Support

If you encounter issues:

1. Check the console output for error messages
2. Verify Firebase project configuration
3. Ensure Firestore is enabled and properly configured
4. Check internet connectivity for external image URLs
