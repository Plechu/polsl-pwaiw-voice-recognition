clear;clc;
load voice_models.mat

MIKROFONEM = 0.02; % in seconds
OVERLAP = 0;

test_data_files = dir(fullfile('test_data', '*.wav'));

for test_number = 1:size(test_data_files, 1)
    [audio, fs] = audioread(strcat('test_data\', test_data_files(test_number).name));
    mfcc_coeffs = mfcc(audio,...
                       fs,...
                       Window=hamming(fs * MIKROFONEM, "periodic"),...
                       NumCoeffs=(size(voice_models{1}{2}, 2) - 1),...
                       OverlapLength=OVERLAP);

    result = zeros(size(mfcc_coeffs, 1), 2);

    for i = 1:size(voice_models, 2) % number of voice models
        for j = 1:size(mfcc_coeffs, 1)
           test_matrix = repmat(mfcc_coeffs(j,:), size(voice_models{i}{2}, 1), 1) ;
           minimum = inf;
           for k = 1:size(voice_models{1}{2}, 1) % number of clusters
               temp = norm(voice_models{i}{2}(k, :) - test_matrix(k,:));
               if temp < minimum
                   minimum = temp;
               end
           end
           result(j,i) = minimum;
        end
    end
    
    file_name = split(test_data_files(test_number).name, '.');
    speaker_name = extractBefore(file_name{1}, size(file_name{1},2));
    
    [~, speaker_index] = min(sum(result));
    
    fprintf("Test case: %d\n", test_number);
    fprintf("Test file: %s\n", test_data_files(test_number).name);
    fprintf("Expected speaker: %s\n", speaker_name);
    fprintf("Recognized speaker: %s\n", voice_models{speaker_index}{1});
    
    if strcmp(speaker_name, voice_models{speaker_index}{1})
        fprintf("Speaker recognition result: Positive\n");
    else
        fprintf("Speaker recognition result: Negative\n");
    end
    
    if size(test_data_files, 1) > 1 && size(test_data_files, 1) ~= test_number
        fprintf("\n");
    end
end

