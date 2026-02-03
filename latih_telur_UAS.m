% =========================================================================
% SCRIPT PELATIHAN (KNN 5 CIRI)
% Output: 'training_data.txt' & Folder 'hasil_segmentasi'
% =========================================================================
clc; clear; close all;

disp('--- TRAINING KNN & MENYIMPAN HASIL SEGMENTASI ---');

Label_Ayam  = 1;
Label_Bebek = 2;

disp('Sedang memproses folder AYAM');
[Data_Ayam, ~] = AmbilCiriFolder('train/ayam/', 'hasil_segmentasi/ayam/', Label_Ayam);

disp('Sedang memproses folder BEBEK');
[Data_Bebek, ~] = AmbilCiriFolder('train/bebek/', 'hasil_segmentasi/bebek/', Label_Bebek);

Dataset_Latih = [Data_Ayam; Data_Bebek];

if ~isempty(Dataset_Latih)
    save('training_data.txt', 'Dataset_Latih', '-ascii');
    fprintf('\n SUKSES! Data fitur tersimpan di training_data.txt\n');
    fprintf('SUKSES! Citra Segmentasi tersimpan di folder "hasil_segmentasi"\n');
else
    errordlg('Tidak ada data yang tersimpan. Cek logic threshold!', 'Error');
end

function [MatriksData, ListNama] = AmbilCiriFolder(NamaFolder, FolderOutput, LabelKelas)
    Files = [dir(fullfile(NamaFolder, '*.jpg')); dir(fullfile(NamaFolder, '*.png'))];
    Jumlah = length(Files);
    MatriksData = []; ListNama = {};
    
    if Jumlah == 0, return; end
    
    if ~exist(FolderOutput, 'dir')
        mkdir(FolderOutput);
    end
    
    for k = 1:Jumlah
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
                        BW(x,y) = 0; % Background
                    else
                        BW(x,y) = 1; % Telur
                    end
                end
            end
            
            % Morfologi
            BW2 = imdilate(BW, ones(10));
            BW3 = imerode(BW2, ones(17));
            
            Masker = logical(BW3);
            
            if sum(Masker(:)) > 0
                NamaFileSeg = ['Seg_', Files(k).name];
                PathSeg = fullfile(FolderOutput, NamaFileSeg);
                
                imwrite(Masker, PathSeg);
                
                R = double(Img(:,:,1)); G = double(Img(:,:,2)); B = double(Img(:,:,3));
                Ciri_R = mean(R(Masker)) / 255;
                Ciri_G = mean(G(Masker)) / 255;
                Ciri_B = mean(B(Masker)) / 255;
                
                % B. Bentuk
                stats = regionprops(Masker, 'Area', 'Perimeter', 'Eccentricity');
                Areas = [stats.Area]; [~, idxMax] = max(Areas);
                
                Area = stats(idxMax).Area;
                Perimeter = stats(idxMax).Perimeter;
                Eccent = stats(idxMax).Eccentricity;
                Metric = (4 * pi * Area) / (Perimeter^2);
                
                Baris = [Ciri_R, Ciri_G, Ciri_B, Metric, Eccent, LabelKelas];
                MatriksData = [MatriksData; Baris];
                ListNama{end+1} = Files(k).name;
                
                fprintf('  %s -> Saved to %s\n', Files(k).name, FolderOutput);
            else
                disp(['  Gagal Segmentasi: ', Files(k).name]);
            end
            
        catch
            disp(['  Error baca: ', Files(k).name]);
        end
    end
end