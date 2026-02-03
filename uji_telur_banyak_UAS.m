clc; clear; close all;

disp('--- MEMULAI PENGUJIAN SISTEM (KNN k=3) ---');

%% 1. LOAD DATA LATIH (DATABASE)
if exist('training_data.txt', 'file')
    Database = load('training_data.txt');
    X_Train = Database(:, 1:5); % Fitur Latih
    Y_Train = Database(:, 6);   % Label Latih
    disp(' Database Training berhasil dimuat.');
else
    errordlg('File training_data.txt belum ada! Jalankan training dulu.', 'Error');
    return;
end

%% 2. PERSIAPAN VARIABEL
Label_Ayam  = 1;
Label_Bebek = 2;
Total_Benar = 0;
Total_Data  = 0;
Hasil_Testing_Txt = [];

FolderSegTest = 'hasil_segmentasi_test/';
if ~exist(FolderSegTest, 'dir'), mkdir(FolderSegTest); end

%% 3. PROSES PENGUJIAN (LOOPING FOLDER)

disp('--------------------------------------------------');
disp('Sedang menguji folder: test/ayam/ ...');
[Benar_A, Total_A, Data_A] = ProsesUjiFolder('test/ayam/', Label_Ayam, X_Train, Y_Train, FolderSegTest);

disp('--------------------------------------------------');
disp('Sedang menguji folder: test/bebek/ ...');
[Benar_B, Total_B, Data_B] = ProsesUjiFolder('test/bebek/', Label_Bebek, X_Train, Y_Train, FolderSegTest);

%% 4. HITUNG KINERJA (AKURASI) 📊
Total_Data  = Total_A + Total_B;
Total_Benar = Benar_A + Benar_B;
Akurasi     = (Total_Benar / Total_Data) * 100;

Hasil_Testing_Txt = [Data_A; Data_B];

fprintf('\n==================================================\n');
fprintf('           LAPORAN KINERJA KLASIFIKASI            \n');
fprintf('==================================================\n');
fprintf('Total Data Uji  : %d citra\n', Total_Data);
fprintf('Jumlah Benar    : %d citra\n', Total_Benar);
fprintf('Jumlah Salah    : %d citra\n', Total_Data - Total_Benar);
fprintf('AKURASI SISTEM  : %.2f %%\n', Akurasi);
fprintf('==================================================\n');

%% 5. SIMPAN DATA CIRI PENGUJIAN (.TXT) 💾
if ~isempty(Hasil_Testing_Txt)
    save('testing_data.txt', 'Hasil_Testing_Txt', '-ascii');
    disp(' File "testing_data.txt" berhasil disimpan.');
    disp('(Gunakan file ini untuk Tabel Data Uji di Laporan)');
else
    disp(' Tidak ada data pengujian yang tersimpan.');
end

function [JumlahBenar, JumlahFile, MatriksFitur] = ProsesUjiFolder(NamaFolder, LabelAsli, X_Train, Y_Train, FolderOut)
    Files = [dir(fullfile(NamaFolder, '*.jpg')); dir(fullfile(NamaFolder, '*.png'))];
    JumlahFile = length(Files);
    JumlahBenar = 0;
    MatriksFitur = [];

    if LabelAsli == 1, SubF = 'ayam/'; else, SubF = 'bebek/'; end
    FullOutDir = fullfile(FolderOut, SubF);
    if ~exist(FullOutDir, 'dir'), mkdir(FullOutDir); end
    
    if JumlahFile == 0
        disp(['  Folder kosong: ', NamaFolder]); 
        return; 
    end
    
    for k = 1:JumlahFile
        try
            Fullpath = fullfile(NamaFolder, Files(k).name);
            Img = imread(Fullpath);
            
            Agray = rgb2gray(Img);
            [m, n] = size(Agray);
            BW = zeros(m, n);
            
            BatasAmbang = 80;
            
            for x = 1:m
                for y = 1:n
                    if Agray(x,y) <= BatasAmbang
                        BW(x,y) = 0; 
                    else
                        BW(x,y) = 1; 
                    end
                end
            end
            
            BW = imdilate(BW, ones(10));
            BW = imerode(BW, ones(17));
            Masker = logical(BW);
            
            if sum(Masker(:)) > 0
                imwrite(Masker, fullfile(FullOutDir, ['Seg_', Files(k).name]));
                
                R = double(Img(:,:,1)); G = double(Img(:,:,2)); B = double(Img(:,:,3));
                
                Uji_R = mean(R(Masker)) / 255;
                Uji_G = mean(G(Masker)) / 255;
                Uji_B = mean(B(Masker)) / 255;
                
                stats = regionprops(Masker, 'Area', 'Perimeter', 'Eccentricity');
                Areas = [stats.Area]; [~, idxMax] = max(Areas);
                
                Area = stats(idxMax).Area;
                Perimeter = stats(idxMax).Perimeter;
                Uji_Eccent = stats(idxMax).Eccentricity;
                Uji_Metric = (4 * pi * Area) / (Perimeter^2);
                
                Data_Uji = [Uji_R, Uji_G, Uji_B, Uji_Metric, Uji_Eccent];
                
                MatriksFitur = [MatriksFitur; [Data_Uji, LabelAsli]];
                
                JumlahLatih = size(X_Train, 1);
                DaftarJarak = zeros(JumlahLatih, 2);
                
                for i = 1:JumlahLatih
                    Selisih = Data_Uji - X_Train(i, :);
                    Jarak   = sqrt(sum(Selisih.^2));
                    DaftarJarak(i, :) = [Jarak, Y_Train(i)];
                end
                
                [~, Urutan] = sort(DaftarJarak(:, 1));
                Tetangga = DaftarJarak(Urutan(1:3), :);
                
                Vote_Ayam  = sum(Tetangga(:,2) == 1);
                Vote_Bebek = sum(Tetangga(:,2) == 2);
                
                if Vote_Ayam > Vote_Bebek, Prediksi = 1; Teks='AYAM';
                else, Prediksi = 2; Teks='BEBEK'; end
                
                Status = '  SALAH';
                if Prediksi == LabelAsli
                    JumlahBenar = JumlahBenar + 1;
                    Status = '  BENAR';
                end
                
                fprintf('   %s -> Prediksi: %s | %s\n', Files(k).name, Teks, Status);
                
            else
                disp(['    Gagal Segmentasi: ', Files(k).name]);
            end
            
        catch
            disp(['    Error: ', Files(k).name]);
        end
    end
end