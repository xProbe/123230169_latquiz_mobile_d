# 📚 Quiz App - Deep Technical & Architecture Documentation

Aplikasi **lat_quiz** merupakan simulasi Game Catalog App berbasis **Flutter** yang dibangun untuk mendemonstrasikan pemahaman mendalam mengenai arsitektur UI/UX modern, *State Management* tingkat lanjut pada `StatefulWidget`, sistem navigasi kustom (*Custom Routing*), dan komposisi *Sliver* untuk efek *parallax scrolling*.

Dokumentasi ini ditulis **sangat detail (Comprehensive Deep-Dive)** secara teknikal untuk membantu *developer* memahami setiap aspek baris kode, *design pattern*, dan cara kerjanya di belakang layar.

---

## 🏗️ 1. Arsitektur Proyek (Project Architecture)

Aplikasi ini menggunakan pola arsitektur **Feature-Based / Screen-Based Directory Structure**, di mana *business logic* dan UI dipisahkan secara modular:

```text
lat_quiz/
┣ 📂 lib/
┃ ┣ 📂 models/
┃ ┃ ┗ 📜 game.dart          (Data layer: PODO Immutable Model)
┃ ┣ 📂 screens/
┃ ┃ ┣ 📜 login_page.dart    (Presentation layer: Auth UI & Form Validation Logic)
┃ ┃ ┣ 📜 home_page.dart     (Presentation layer: List Rendering & Search State)
┃ ┃ ┗ 📜 detail_page.dart   (Presentation layer: Detail UI & Micro-interactions State)
┃ ┗ 📜 main.dart            (Application Entry Point & Theming Provider)
```

---

## 🛠️ 2. Penjelasan Detail Per-Komponen (File-by-File Analysis)

### A. `lib/main.dart` - Entry Point & Theming Engine
File ini dieksekusi pertama kali oleh Flutter Engine melalui fungsi `main()`.

**Teknikal Detail:**
*   **`runApp(const MyApp())`**: Menginstruksikan framework untuk melampirkan widget `MyApp` (sebuah `StatelessWidget`) ke akar pohon widget (Widget Tree). Penggunaan `const` di sini sangat penting untuk performa (*memory optimization*) karena Flutter tidak perlu me-_rebuild_ *instance* object saat *hot reload* jika atributnya statis.
*   **`MaterialApp`**: Root widget yang meng-_inject_ routing, navigasi (Navigator 1.0), dan *Theming* ke seluruh aplikasi.
*   **`ThemeData(useMaterial3: true)`**: Mengaktifkan versi terbaru dari pedoman desain Google (Material Design 3). Parameter krusial yang digunakan:
    *   `colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)`: Flutter akan menggunakan algoritma internal untuk men-_generate_ secara dinamis palet warna tonal (Primary, Secondary, Surface, Error) berdasarkan *seed color* warna dasar `deepPurple`. Ini memastikan harmoni warna di seluruh aplikasi otomatis kohesif.
    *   `textTheme: GoogleFonts.poppinsTextTheme()`: Meng- *override* konfigurasi _font family_ bawaan (Roboto) di seluruh aplikasi menjadi **Poppins**. Package `google_fonts` me- *load* font secara _HTTP cache_ saat runtime sehingga tidak memperbesar ukuran `.apk/ipa`.
*   **`home: const LoginPage()`**: Mengatur rute default pertama kali yang dirender (Entry Route/Index).

---

### B. `lib/models/game.dart` - Data Layer (PODO Object)
Bertindak sebagai *Data Blueprint* (Cetak Biru Data).

**Teknikal Detail:**
*   **Immutable Class**: Deklarasi properti dengan keyword `final String`. Hal ini menunjukkan *Data Integrity* (keutuhan data) bahwa nilai tidak dapat dimutasi setelah objek dibuat. Ini selaras dengan asas *Functional Programming* pada Dart.
*   **Named Constructor `required`**: Parameter konstruktor menggunakan _named arguments_ berbasis `required`. Jika developer lupa memasukkan `title` atau `description` saat inisialisasi class, Dart _analyzer_ akan langsung menangkap error saat _compile-time_, meminimalkan *Null-Pointer Exception* (NPE) saat runtime.
*   **`dummyGames`**: Sebuah global variable bertipe `List<Game>` yang berperan sebagai *mock repository* statis (menyimulasikan API Server).
    *   *Kustomisasi untuk backend nyata:* Di masa mendatang, file ini dapat dimodifikasi untuk menambahkan fungsi factory _de-serialization_ JSON seperti `factory Game.fromJson(Map<String, dynamic> json)`.

---

### C. `lib/screens/login_page.dart` - Authentication & Validation
Halaman ini adalah `StatefulWidget` karena memegang status input form yang dapat berubah-ubah (*mutable state*).

**Teknikal Detail & State Management:**
*   **`TextEditingController`**: Ini adalah obyek *ValueNotifier* yang mengikat data inputan fisik keyboard ke variabell di dalam kode. Ada dua controller: `_usernameController` dan `_passwordController`.
*   **Memory Management (`dispose`)**:
    ```dart
    @override
    void dispose() {
      _usernameController.dispose();
      ...
    }
    ```
    *Kenapa ini penting?* Controller memegang *_listeners_* native OS (Platform Channel bindings). Terlewat dari siklus `dispose()` akan mengakibatkan **Memory Leak** yang membuat memori RAM penuh karena objek lama tidak dihapus oleh *Garbage Collector*.
*   **Reactive State (`_isPasswordVisible`)**: Properti tipe *boolean* yang dikontrol melalui callback tombol *eye icon*. Pemanggilan mekanisme re-render `setState(() { _isPasswordVisible = !_isPasswordVisible; })` memicu fungsi `build()` untuk dieksekusi ulang, yang dengan reaktif mengubah properti TextField `obscureText:` dari `true` ke `false`.
*   **Validation Logic (`_login()`)**:
    *   Sistem membersihkan _whitespace_ menggunakan `.text.trim()`.
    *   Sistem validasi sinkron secara logika "Atau" (`||`) untuk kasus kosong dan logika "Dan" (`&&`) untuk mencocokkan kredensial.
    *   Notifikasi Error didorong secara imperatif melalui metode global `ScaffoldMessenger.of(context).showSnackBar()`.
*   **Custom Route Transitions (`PageRouteBuilder`)**:
    Saat kredensial terverifikasi, alih-alih menggunakan default _slide_ transisi iOS/Android (`MaterialPageRoute`), kode menggunakan instruksi *Custom Transition* yang membangun efek *Fade opacity* berlahan. Transisi `pushReplacement` digunakan agar history layar _Login_ dihapuskan dari _routing stack_, pengguna tidak bisa menekan "Back" kembali ke Login page.

---

### D. `lib/screens/home_page.dart` - Reactive Filtering & Collections
Komponen UI yang sangat reaktif (merespon *event* secara _realtime_).

**Teknikal Detail & State Management:**
*   **LifeCycle `initState()` & Controller Listener**:
    *   `_searchController` ditugaskan sebuah tugas asinkronus (Listener) segera pada saat konstruksi komponen dimulai: `_searchController.addListener(_filterGames);`. Event listener ini beraksi *tiap satu huruf (keystroke) yang diketik user*, yang kemudian men-_trigger_ fungsi `_filterGames`.
*   **Filtering Algorithm (`_filterGames`)**:
    *   Merupakan fungsi *pure filter* pada Collection API dart. Menggunakan `.where((game) { ... })` yang sifatnya me-_looping_ semua objek `Game` dan memfilter true/false.
    *   Kedua buah belah perbandingan teks dialihkan menjadi `.toLowerCase()` yang menyajikan fungsionalitas pencarian kata *Case-Insensitive* (huruf besar/kecil diabaikan).
    *   Nilai koleksi baru akan disematkan kembali ke lokal variabel `_filteredGames` lalu di-_refresh_ menggunakan `setState()`.
*   **`ListView.builder`**: Algoritma struktur rendering optimal untuk list yang panjang (*Lazy Instantiation*). *Widget* di dalam array tidak akan dirender dan digambar ke memori GPU jika _card_ game tersebut belum terbaca oleh layar (berada diluar _Scroll-Viewport_ bounds).
*   **`Hero` Animation**:
    ```dart
    Hero(
      tag: 'game_image_${game.title}',
      child: Image.network(...)
    )
    ```
    Ini adalah teknik "Shared Element Transition". Flutter akan menangkap pixel gambar *thumbnail* berukuran kecil (dalam tree Listview), membekukan piksel tersebut, membuat *overlay* layer bayangan *(flight shuttle)* hingga mendarat dan meregang sempurna menjadi ukuran raksasa di halaman navigasi baru (`DetailPage`). Syarat utamanya adalah prop attribute `tag:` string-nya **wajib unik & sama identik persis 1-to-1** di widget sumber maupun widget destinasi tujuan.

---

### E. `lib/screens/detail_page.dart` - Slivers Architecture & Micro-Interactions
Fokus layar ini menonjolkan Layouting tingkat lanjut. Ini tidak lagi menggunakan _Scaffold > AppBar_ biasa.

**Teknikal Detail (The Sliver Paradigm):**
*   **`CustomScrollView`**: Area parent yang menjadi tulang punggung layout bertipe Sliver (*Scrollable area* dengan perilaku matematis). Semua _children_-nya wajib diklasifikasikan dengan prefix 'Sliver-'.
*   **`SliverAppBar`**:
    *   Komponen ini memonitor rasio _offset scroll pointer_ pengguna.
    *   Mengandung atribut khusus `expandedHeight: 350.0`. Ini mendikte AppBar setinggi 350 piksel, namun bila layout didorong ke bawah (scroll atas), area tinggi AppBar ini dapat mengkerut (shrinkage) dan _collapse_ kembali ke tinggi standar *Status Bar*.
    *   `FlexibleSpaceBar`: Tempat disematkannya objek *Hero* (Gambar Game Poster destinasi akhir). *Property* `background:` yang mengcover gambar ditimpa _Gradient overlay_ linear (`Colors.black.withValues(alpha: 0.8)`) dengan parameter nilai heksadesimal opacity melalui iterasi standar dart terbaru `withValues(alpha:)` untuk mencegah presisi memori hilang (_deprecation patch_).
*   **`SliverToBoxAdapter`**: Sebuah _Adapter Interface Proxy_. Biasanya properti anak-anak Sliver tidak bisa merender Box sederhana seperti `Container/Column/Row`. *Class proxy* ini menjembatani box _RenderObject_ tradisional agar dibolehkan ikut masuk dan menjadi elemen berurutan di dalam sistem *matriks custom scrollivew* sliver di atasnya.
*   **Interaksi FAB (Floating Action Button)**:
    Status boolian *state* `_isLiked` secara independen disematkan di level memori Widget. Perubahan mutasi state dibarengi modifikasi tampilan *Iconography*, warna *Label Text*, serta injeksi imperatif UI log `SnackBar`.

---

## 🔧 Pengembangan Teknis Kedepan (Actionable Improvements)

Untuk scaling production-level, pertimbangkan merubah poin-poin arsitektural ini:
1.  **State Management Eksternal**: Pisahkan _presentation logic_ kotor (contoh fitur Searching) dari Widget UI dengan mengintegrasikan **GetX, Provider, BLoC, atau Riverpod**. Ini mengikuti standarisasi arsitektur MVVM (Model-View-ViewModel).
2.  **Network Repository**: Buat instance `http.Client` secara *Singleton pattern* dari *Service Locator (GetIt)*, terhubung dengan Server Backend via JSON serialization (`json_serializable` / `freezed`). Tambahkan penanganan error terpusat (Interceptors/Try-catch).
3.  **Route Generator**: Transisi dari _Navigator 1.0 explicit pushing_ menjadi tipe rutenama (*Named Routes Navigator 1.0*) atau sistem navigasi deklaratif seperti **GoRouter (Router 2.0 API)** untuk _Deep-linking URL_ (jika nanti diekspor jadi Web App).
4.  **Local Storage (Persistence)**: Status "Liked/Favorites" saat ini hanya melekat pada durasi _RAM lifecycle Runtime_ milik DetailPage. Saat pindah kembali ke home, memori di-bersihkan (flush). Solusinya pasangkan `SharedPreferences` (Key-value), `Hive` (NoSQL), atau `sqflite` (RDBMS lokal) untuk menyimpan id game favorit.
