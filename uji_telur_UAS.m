% =========================================================================
% KLASIFIKASI TELUR - KNN (k=3)
% =========================================================================
clc; clear; close all;

%% 1. LOAD DATA LATIH
if exist('training_data.txt', 'file')
    Database = load('training_data.txt');
    X_Train = Database(:, 1:5); 
    Y_Train = Database(:, 6);
else
    errordlg('Training data belum ada!', 'Error'); return;
end

%% 2. LOAD GAMBAR
if exist('train', 'dir'), DefaultPath = 'train\'; else, DefaultPath = pwd; end
[NamaFile, PathFile] = uigetfile({'*.jpg;*.png'}, 'Pilih Gambar', DefaultPath);
if isequal(NamaFile, 0), return; end

GambarAsli = imread(fullfile(PathFile, NamaFile));
figure(1); subplot(2,2,1); imshow(GambarAsli); title('Citra Uji');

%% 3. PRE-PROCESSING (GAYA UBI)
Agray = rgb2gray(GambarAsli);
[m, n] = size(Agray);
BW = zeros(m, n);

% SETTING MANUAL (Harus sama dengan Latih)
BatasAmbang = 120; 

for x = 1:m
    for y = 1:n
        % Logika Background Gelap
        if Agray(x,y) <= BatasAmbang
            BW(x,y) = 0; 
        else
            BW(x,y) = 1; 
        end
    end
end

e_dilate = ones(10); 
BW2 = imdilate(BW, e_dilate);
e_erode = ones(17); 
BW3 = imerode(BW2, e_erode);

Masker = logical(BW3);
subplot(2,2,2); imshow(Masker); title('Segmentasi');

%% 4. EKSTRAKSI FITUR
if sum(Masker(:)) > 0
    R = double(GambarAsli(:,:,1)); G = double(GambarAsli(:,:,2)); B = double(GambarAsli(:,:,3));
    
    Test_R = mean(R(Masker)) / 255;
    Test_G = mean(G(Masker)) / 255;
    Test_B = mean(B(Masker)) / 255;
    
    stats = regionprops(Masker, 'Area', 'Perimeter', 'Eccentricity');
    Areas = [stats.Area]; [~, idxMax] = max(Areas);
    
    Area = stats(idxMax).Area;
    Perimeter = stats(idxMax).Perimeter;
    Test_Eccent = stats(idxMax).Eccentricity;
    Test_Metric = (4 * pi * Area) / (Perimeter^2);
    
    Data_Uji = [Test_R, Test_G, Test_B, Test_Metric, Test_Eccent];
    
    fprintf('\nData Uji: [R:%.2f, G:%.2f, B:%.2f, M:%.2f, E:%.2f]\n', Test_R, Test_G, Test_B, Test_Metric, Test_Eccent);

    %% 5. ALGORITMA KNN (k=3)
    JumlahData = size(X_Train, 1);
    DaftarJarak = zeros(JumlahData, 2);
    
    for i = 1:JumlahData
        Selisih = Data_Uji - X_Train(i, :);
        Jarak   = sqrt(sum(Selisih.^2));
        DaftarJarak(i, :) = [Jarak, Y_Train(i)];
    end
    
    [~, Urutan] = sort(DaftarJarak(:, 1));
    Tetangga = DaftarJarak(Urutan(1:3), :);
    
    Vote_Ayam  = sum(Tetangga(:,2) == 1);
    Vote_Bebek = sum(Tetangga(:,2) == 2);
    
    if Vote_Ayam > Vote_Bebek, Hasil = 'AYAM'; Warna='r'; else, Hasil = 'BEBEK'; Warna='b'; end
    
    subplot(2,2,3); 
    text(0.5, 0.5, Hasil, 'Color', Warna, 'FontSize', 24, 'Horiz', 'center', 'FontWeight', 'bold');
    axis off; title('Hasil Klasifikasi');
    msgbox(['Hasil: ', Hasil]);
    
else
    errordlg('Segmentasi Gagal! Gambar Hitam Semua. Cek BatasAmbang.', 'Error');
end