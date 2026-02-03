# Klasifikasi Telur Ayam & Bebek (Metode KNN) 🥚

Proyek ini adalah sistem klasifikasi citra digital untuk membedakan antara **Telur Ayam** dan **Telur Bebek** menggunakan metode pengolahan citra dan algoritma **K-Nearest Neighbor (KNN)** pada MATLAB.

## 📋 Deskripsi

Sistem ini melakukan segmentasi citra untuk memisahkan objek telur dari latar belakang, kemudian mengekstrak riri warna (RGB) dan ciri bentuk (Metric, Eccentricity). Data ciri tersebut digunakan untuk melatih model KNN (k=3) agar dapat mengklasifikasikan citra telur baru secara otomatis.

## 🚀 Fitur Utama

-   **Pelatihan Data (Training)**: Ekstraksi ciri otomatis dari dataset latih dan pembentukan database pengetahuan (`training_data.txt`).
-   **Pengujian Tunggal (Single Test)**: Uji klasifikasi pada satu gambar telur yang dipilih pengguna.
-   **Pengujian Batch (Batch Test)**: Uji akurasi sistem pada sekumpulan data uji (folder) secara otomatis.
-   **Debugging Tool**: Script khusus (`cek_satu_UAS.m`) untuk mengecek kualitas segmentasi, terutama untuk mengatasi masalah pencahayaan atau background gelap.

## 📂 Struktur File

| Nama File | Fungsi |
| :--- | :--- |
| `latih_telur_UAS.m` | Script untuk melatih sistem, menghasilkan file training data. |
| `uji_telur_UAS.m` | Script untuk menguji satu gambar telur. |
| `uji_telur_banyak_UAS.m` | Script untuk menguji banyak gambar dalam folder dan menghitung akurasi. |
| `cek_satu_UAS.m` | Script diagnostik untuk mengecek langkah-langkah preprocessing. |
| `data.xlsx` | File excel yang berisi rekapitulasi data (opsional/pendukung). |
| `training_data.txt` | Database ciri hasil pelatihan yang digunakan untuk klasifikasi. |

## 🛠️ Cara Penggunaan

### 1. Pelatihan (Training)
Jalankan script `latih_telur_UAS.m` terlebih dahulu untuk membangun model.
1.  Pastikan folder `train/ayam` dan `train/bebek` sudah berisi gambar latih.
2.  Run `latih_telur_UAS.m`.
3.  Hasil ekstraksi ciri akan disimpan ke `training_data.txt`.

### 2. Pengujian Satu Gambar
Gunakan `uji_telur_UAS.m` untuk mendeteksi jenis telur dari satu file gambar.
1.  Run `uji_telur_UAS.m`.
2.  Pilih file gambar (JPG/PNG).
3.  Sistem akan menampilkan hasil klasifikasi (Ayam/Bebek).

### 3. Pengujian Akurasi (Batch)
Gunakan `uji_telur_banyak_UAS.m` untuk melihat performa sistem.
1.  Pastikan folder `test/ayam` dan `test/bebek` sudah berisi gambar uji.
2.  Run `uji_telur_banyak_UAS.m`.
3.  Sistem akan menampilkan akurasi total di Command Window.

### 4. Troubleshooting Segmentasi
Jika hasil klasifikasi salah atau segmentasi gagal (gambar hitam), gunakan `cek_satu_UAS.m`.
1.  Run `cek_satu_UAS.m`.
2.  Pilih gambar yang bermasalah.
3.  Analisis tahapan preprocessing yang ditampilkan step-by-step untuk mengetahui penyebab kegagalan.

## ⚙️ Persyaratan Sistem

-   **MATLAB** (dengan Image Processing Toolbox).
-   Dataset gambar telur ayam dan bebek (Background kontras disarankan).

## 👨‍💻 Author
- **Nama**: Rizal Rio Andrian
