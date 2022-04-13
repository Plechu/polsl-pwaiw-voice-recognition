clc;clear;

CLUSTERS_NUMBER = 64;
COEFFS_NUMBER = 18;
MIKROFONEM = 0.02; % in seconds
OVERLAP = 0;
TEST_LENGTH = 'short\';
%TEST_LENGTH = 'long\';
PATH = strcat('train_data\',TEST_LENGTH);

train_data_files = dir(fullfile(PATH, '*.wav'));

voice_models = cell(size(train_data_files, 2), size(train_data_files, 1));

for i = 1:size(train_data_files, 1)
    [audio, fs] = audioread(strcat(PATH, train_data_files(i).name));
    mfcc_coeffs = mfcc(audio,...
                   fs,...
                   Window=hamming(fs * MIKROFONEM, "periodic"),...
                   NumCoeffs=COEFFS_NUMBER,...
                   OverlapLength=OVERLAP);
    [~, voice_model] = kmeans(mfcc_coeffs, CLUSTERS_NUMBER);
    
    file_name = split(train_data_files(i).name, '.');
    voice_models{i} = {file_name{1}, voice_model};
    
    fprintf("Added voice model of %s from file: %s\n", file_name{1}, train_data_files(i).name);
end

save('voice_models.mat', 'voice_models');

fprintf("Successfuly saved %d voice models in voice_models.mat\n", size(train_data_files, 1));