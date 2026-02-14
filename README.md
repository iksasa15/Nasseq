# Nesseq - نسِّق
## AR Home Decor & Tableware Arrangement App

### 📋 Setup Instructions

#### 1. Adding 3D Models (USDZ Files)

Your app is configured to load USDZ models for tableware items. Follow these steps to add models:

**Option A: Find Free USDZ Models**
- **Apple AR Quick Look Gallery**: https://developer.apple.com/augmented-reality/quick-look/
- **Sketchfab**: Search for "plate", "cup", "bowl" and download with USDZ format
- **Polyhaven**: Download 3D models and convert using Reality Converter

**Option B: Convert Existing 3D Models**
1. Download Apple's **Reality Converter** (free from Mac App Store)
2. Drag your OBJ, FBX, or GLTF files into Reality Converter
3. Adjust scale and materials
4. Export as USDZ

**Adding Models to Xcode:**
1. Open your Xcode project
2. Drag USDZ files into the project navigator
3. Make sure "Copy items if needed" is checked
4. Ensure files are added to the Nasseq target
5. Update `Resources/products.json` with the correct filenames

**Model Naming Convention:**
The app expects models to match the `modelFilename` in `products.json`:
- `plate_ceramic_white.usdz`
- `cup_glass.usdz`
- `bowl_ceramic.usdz`
- etc.

---

#### 2. Adding Cairo Font (Optional)

The app uses Cairo font for Arabic text with automatic fallback to SF Arabic.

**To add Cairo font:**

1. **Download Cairo Font**
   - Visit Google Fonts: https://fonts.google.com/specimen/Cairo
   - Download the font family (Regular, Medium, SemiBold, Bold)

2. **Add to Xcode**
   - Drag `.ttf` or `.otf` files into your Xcode project
   - Check "Copy items if needed"
   - Add to Nasseq target

3. **Register in Info.plist**
   - Open `Info.plist`
   - Add a new key: `Fonts provided by application` (Array)
   - Add items for each font file:
     - `Cairo-Regular.ttf`
     - `Cairo-Medium.ttf`
     - `Cairo-SemiBold.ttf`
     - `Cairo-Bold.ttf`

**If you skip this step:** The app will automatically use SF Arabic (system font) as a fallback.

---

#### 3. Camera Permission

The app requires camera access for AR functionality. The permission is already configured in code, but ensure your `Info.plist` has:

```xml
<key>NSCameraUsageDescription</key>
<string>نحتاج للكاميرا لعرض المنتجات في بيئتك باستخدام الواقع المعزز</string>
```

---

### 🎨 Features Implemented

✅ **Product Catalog**
- 12 sample products across 5 categories
- Search functionality
- Category filtering
- Arabic localization

✅ **AR Experience**
- Table-specific plane detection
- Real-world scale for models
- Tap to place objects
- Gesture controls (rotate, scale, move)

✅ **Favorites System**
- Save favorite products
- Persistent storage using UserDefaults
- Quick access to favorites

✅ **Save Formations**
- Capture AR scenes
- Save table arrangements
- View saved formations gallery
- Delete formations

✅ **Elegant UI**
- Cairo font support (with fallback)
- RTL (Right-to-Left) layout for Arabic
- Teal color theme
- Tab-based navigation

---

### 📁 Project Structure

```
Nasseq/
├── Models/
│   ├── Product.swift              # Product data model
│   └── FormationSnapshot.swift    # Saved formation model
├── Services/
│   ├── ProductCatalog.swift       # Product management
│   ├── FavoritesManager.swift     # Favorites storage
│   └── FormationManager.swift     # Formation save/load
├── Views/
│   ├── ProductGalleryView.swift   # Browse products
│   ├── ProductCardView.swift      # Product card component
│   ├── FavoritesView.swift        # Favorites list
│   └── SavedFormationsView.swift  # Formations gallery
├── Resources/
│   └── products.json              # Product catalog data
├── ARScreen.swift                 # AR view controller
├── ARManager.swift                # AR session manager
├── ARViewContainer.swift          # AR view wrapper
├── Theme.swift                    # Colors, fonts, spacing
└── ContentView.swift              # Main tab navigation
```

---

### 🚀 Next Steps

1. **Add Real USDZ Models**
   - Replace placeholder model references with actual USDZ files
   - Test model loading and scaling

2. **Test AR Features**
   - Test on physical device (AR doesn't work in simulator)
   - Verify plane detection on tables
   - Check model scales are realistic

3. **Customize Products**
   - Edit `Resources/products.json` to add your products
   - Update categories as needed
   - Add product descriptions

4. **Optional Enhancements**
   - Add product thumbnails (images)
   - Implement formation loading (restore AR scene)
   - Add sharing functionality for formations
   - Integrate with e-commerce API

---

### 🐛 Troubleshooting

**Models not loading?**
- Check that USDZ files are in the project
- Verify filenames match `products.json`
- Check Xcode build phases > Copy Bundle Resources

**AR not starting?**
- Ensure camera permission is granted
- Test on physical device (not simulator)
- Check console for AR session errors

**Arabic text not showing correctly?**
- Verify RTL layout is enabled
- Check font installation if using Cairo
- System font (SF Arabic) should work as fallback

**App crashes on launch?**
- Check Info.plist has camera usage description
- Verify all Swift files are added to target
- Check for missing imports

---

### 📱 Testing Checklist

- [ ] Browse products by category
- [ ] Search for products
- [ ] Add/remove favorites
- [ ] Open AR view from product
- [ ] Place objects on table surface
- [ ] Rotate, scale, move objects
- [ ] Save formation with name
- [ ] View saved formations
- [ ] Delete formation
- [ ] Test on different table surfaces

---

### 📄 License

This project is for educational and personal use.
