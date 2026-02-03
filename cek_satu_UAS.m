% =========================================================================
% ALAT CEK PREPROCESSING (SPESIAL BACKGROUND GELAP) 🌑
% Gunakan ini jika foto diambil di atas kain hitam/meja gelap.
% =========================================================================
clc; clear; close all;
disp('--- MODE DEBUGGING: BACKGROUND GELAP ---');

%% 1. PILIH GAMBAR 📂
disp('Silakan pilih satu gambar telur...');
if exist('train', 'dir'), DefaultPath = 'train\'; else, DefaultPath = pwd; end

[NamaFile, PathFile] = uigetfile({'*.jpg;*.png;*.jpeg;*.bmp'}, 'Pilih Gambar', DefaultPath);

if isequal(NamaFile, 0), disp('❌ Batal.'); return; end
Fullpath = fullfile(PathFile, NamaFile);

try
    Img = imread(Fullpath);
    disp(['✅ Memproses file: ', NamaFile]);
catch
    errordlg('Gagal baca file gambar!', 'Error'); return;
end

%% 2. TAHAP PRE-PROCESSING (STEP-BY-STEP) 🛠️
figure('Name', 'Analisis Background Gelap', 'NumberTitle', 'off');

% --- STEP A: ASLI ---
subplot(2,3,1); imshow(Img); 
title('1. Citra Asli');

% --- STEP B: GRAYSCALE + KONTRAS ---
Agray = rgb2gray(Img);

% PENTING: Tingkatkan kontras! (Biar telur makin terang, background makin gelap)
Agray = imadjust(Agray); 

subplot(2,3,2); imshow(Agray); 
title('2. Grayscale (Kontras Tinggi)');

% --- STEP C: THRESHOLDING (OTSU) ---
Level = graythresh(Agray);       
BinaryMask = im2bw(Agray, Level); 

% --- STEP D: LOGIKA LATAR BELAKANG (SANGAT PENTING) ---
% Cek pojok kiri atas (1,1). Harusnya HITAM (0) karena itu background.
% Kalau pojok warnanya PUTIH (1), berarti logikanya kebalik.
Status = 'Normal';
if BinaryMask(1,1) == 1
    BinaryMask = ~BinaryMask; % Balik (Invert) biar background jadi Hitam
    Status = 'AUTO-FIX (Dibalik)';
end

subplot(2,3,3); imshow(BinaryMask); 
title(['3. Biner Mentah (', Status, ')']);

% --- STEP E: PEMBERSIHAN (SUPER CLEAN) ---
% 1. Tambal Telur (Biar padat)
BinaryMask = imfill(BinaryMask, 'holes');

% 2. Haluskan Pinggir (Dilasi/Closing)
se = strel('disk', 15); % Angka 15 biar telur makin bulat penuh
BinaryMask = imclose(BinaryMask, se); 

% 3. Buang Sampah (Debu/Pantulan Cahaya Kecil)
BinaryMask = bwareaopen(BinaryMask, 2000); 

% 4. JURUS TERAKHIR: Ambil Cuma 1 Objek Terbesar
CC = bwconncomp(BinaryMask);
if CC.NumObjects > 1
    numPixels = cellfun(@numel, CC.PixelIdxList); 
    [~, idx] = max(numPixels); % Cari Pemenang (Telur)
    
    % Reset masker, cuma isi si Pemenang
    MaskerBaru = false(size(BinaryMask));
    MaskerBaru(CC.PixelIdxList{idx}) = true;
    BinaryMask = MaskerBaru;
    disp('✨ Info: Objek-objek kecil lain berhasil dibuang.');
end

subplot(2,3,4); imshow(BinaryMask); 
title('4. Masker Final (Telur Putih)');

% --- STEP F: HASIL POTONG ---
HasilPotong = Img;
R = HasilPotong(:,:,1); R(~BinaryMask) = 0; HasilPotong(:,:,1) = R;
G = HasilPotong(:,:,2); G(~BinaryMask) = 0; HasilPotong(:,:,2) = G;
B = HasilPotong(:,:,3); B(~BinaryMask) = 0; HasilPotong(:,:,3) = B;

subplot(2,3,[5 6]); imshow(HasilPotong); 
title('5. Hasil Segmentasi Akhir');

%% 3. LAPORAN ANGKA 📊
disp(' ');
disp('----------------------------------');
disp('      LAPORAN EKSTRAKSI CIRI      ');
disp('----------------------------------');

JumlahPiksel = sum(BinaryMask(:));

if JumlahPiksel == 0
    msgbox('⚠️ GAGAL! Gambar Hitam Semua. Coba foto ulang dengan cahaya lebih terang ke telur.', 'Gagal');
    disp('❌ Hasil: GAGAL SEGMENTASI.');
else
    % Ambil layer warna
    R_layer = double(Img(:,:,1));
    G_layer = double(Img(:,:,2));
    B_layer = double(Img(:,:,3));
    
    % Hitung Mean cuma di area masker
    Mean_R = mean(R_layer(BinaryMask));
    Mean_G = mean(G_layer(BinaryMask));
    Mean_B = mean(B_layer(BinaryMask));
    
    fprintf('🔹 Luas Area Telur   : %d piksel\n', JumlahPiksel);
    fprintf('🔴 Rata-rata MERAH   : %.2f\n', Mean_R);
    fprintf('🟢 Rata-rata HIJAU   : %.2f\n', Mean_G);
    fprintf('🔵 Rata-rata BIRU    : %.2f\n', Mean_B);
    disp('----------------------------------');
    disp('✅ STATUS: BERHASIL! Background Gelap teratasi.');
end