# Database Seeding Scripts

This directory contains scripts to seed the Firestore database with sample data for the BFA (Crops E-commerce) app.

## Prerequisites

1. Make sure Firebase is properly configured in your project
2. Ensure you have the necessary Firebase permissions to write to Firestore
3. Make sure your Firebase project is set up and the `firebase_options.dart` file is properly configured

## Available Scripts

### `seed_products.dart`

Seeds the Firestore database with:

- 4 product categories (Vegetables, Fruits, Grains, Legumes)
- 10 various crop products with realistic data including:
  - Fresh Tomatoes (Vegetables)
  - Baby Spinach (Vegetables)
  - Sweet Bananas (Fruits)
  - Ripe Mangoes (Fruits)
  - Fresh Carrots (Vegetables)
  - Red Onions (Vegetables)
  - Organic Brown Rice (Grains)
  - Sweet Corn (Grains)
  - Black Beans (Legumes)
  - Hass Avocados (Fruits)

Each product includes:

- Realistic pricing in Tanzanian Shillings (TSH)
- Detailed descriptions
- Nutritional information
- High-quality image URLs from Unsplash
- Farmer information
- Location data
- Ratings and reviews
- Organic/featured flags
- Harvest and expiry dates

## How to Run

### Option 1: Using the Admin Panel (Recommended)

1. **Run the Flutter app:**

   ```bash
   flutter run
   ```

2. **Access the Admin Panel:**

   - Once the app is running, you'll see a floating action button (admin icon) on the home screen
   - Tap the admin button to open the Admin Panel
   - Tap "Seed Sample Products" to add the data to Firestore

3. **Verify the data:**
   - Go back to the home screen to see the products
   - Check the categories section to see the new categories

### Option 2: Manual Import via Firebase Console

1. **Open Firebase Console:**

   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select your project
   - Navigate to Firestore Database

2. **Import the JSON data:**

   - Use the provided `sample_data.json` file in the scripts folder
   - Create collections manually:
     - Create `categories` collection and add the 4 category documents
     - Create `products` collection and add the 10 product documents

3. **Copy document data:**
   - For each category/product in the JSON file, create a new document
   - Use the `id` field as the document ID
   - Copy the rest of the fields as document data

### Option 3: Using Dart Script (Advanced)

```bash
# Note: This requires Flutter environment setup
# Navigate to the project root
cd /path/to/your/bfa/project

# Run through Flutter (not pure Dart due to Flutter dependencies)
flutter packages get
# The script needs to be run within Flutter context
```

## Expected Output

When you run the script successfully, you should see output like:

```
🌱 Starting product seeding...
✅ Firebase initialized
📂 Seeding categories...
✅ Categories seeded
🥕 Seeding products...
✅ First batch of products seeded
✅ Second batch of products seeded
✅ Final batch of products seeded
🎉 Seeding completed successfully!
```

## Verification

After running the script, you can verify the data was seeded correctly by:

1. **Firebase Console**: Go to your Firebase project console and check the Firestore database
2. **App**: Run your Flutter app and navigate to the home screen to see the products
3. **Categories**: Check that the categories appear in your app's category section

## Data Structure

### Categories Collection (`categories`)

- `vegetables` - Fresh vegetables from local farms
- `fruits` - Seasonal fruits and berries
- `grains` - Cereals and grain products
- `legumes` - Beans, peas, and lentils

### Products Collection (`products`)

Each product document contains:

- Basic info (name, description, price, unit)
- Category and farmer information
- Images and availability status
- Nutritional information
- Tags and metadata
- Timestamps

## Troubleshooting

### Common Issues

1. **Firebase not initialized**: Make sure your `firebase_options.dart` file is properly configured
2. **Permission denied**: Ensure your Firebase security rules allow writes to the collections
3. **Network issues**: Check your internet connection and Firebase project status

### Error Messages

- `❌ Error during seeding: [error]` - Check the error message for specific details
- Firebase initialization errors - Verify your Firebase configuration
- Firestore permission errors - Check your security rules

## Customization

You can modify the `seed_products.dart` script to:

- Add more products
- Change pricing or descriptions
- Add different categories
- Modify farmer information
- Update image URLs

## Clean Up

To remove seeded data:

1. Go to Firebase Console
2. Navigate to Firestore Database
3. Delete the `products` and `categories` collections
4. Or delete individual documents as needed

## Notes

- The script uses batch operations for efficient writes
- Image URLs are from Unsplash and should work reliably
- Prices are in Tanzanian Shillings (TSH)
- All dates are relative to the current time when the script runs
- The script will overwrite existing documents with the same IDs
