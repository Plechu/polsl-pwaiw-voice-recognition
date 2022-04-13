clear;clc;
load voice_models.mat

MIKROFONEM = 0.02; % in seconds
OVERLAP = 0;
TEST_LENGTH = 'short\';
%TEST_LENGTH = 'long\';
PATH = strcat('test_data\',TEST_LENGTH);
NUMBER_OF_VOICE_MODELS = size(voice_models, 2);
VOICE_MODELS_SPEAKERS_ARRAY = cell(NUMBER_OF_VOICE_MODELS, 1);
for speaker = 1:NUMBER_OF_VOICE_MODELS
    VOICE_MODELS_SPEAKERS_ARRAY{speaker} = voice_models{speaker}{1};
end

test_data_files = dir(fullfile(PATH, '*.wav'));
TEST_FILES_NAME = cell(size(test_data_files, 1), 1);

result_cell = cell(size(test_data_files, 1), 3);

for test_number = 1:size(test_data_files, 1)
    [audio, fs] = audioread(strcat(PATH, test_data_files(test_number).name));
    mfcc_coeffs = mfcc(audio,...
                       fs,...
                       Window=hamming(fs * MIKROFONEM, "periodic"),...
                       NumCoeffs=(size(voice_models{1}{2}, 2) - 1),...
                       OverlapLength=OVERLAP);

    result = zeros(size(mfcc_coeffs, 1), 2);

    for i = 1:NUMBER_OF_VOICE_MODELS
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
    
    TEST_FILES_NAME{test_number} = test_data_files(test_number).name;
    result_cell{test_number, 1} = find(strcmp(VOICE_MODELS_SPEAKERS_ARRAY, speaker_name));
    result_cell{test_number, 2} = speaker_index;

end

accuracy_vector = zeros(NUMBER_OF_VOICE_MODELS, 1);
current_speaker = result_cell{1,1};
speaker = 1;
accuracy = 0;
divider = 0;

match_array = zeros(NUMBER_OF_VOICE_MODELS, size(test_data_files, 1));

for row = 1:size(test_data_files, 1)
    if speaker == result_cell{row,1}
        if result_cell{row,1} == result_cell{row,2} 
            accuracy = accuracy + 1;
            match_array(speaker, row) = 1;
        else
            match_array(result_cell{row,2}, row) = 1;
        end
        divider = divider + 1;
    else
        accuracy_vector(speaker) = (accuracy / divider) * 100;
        speaker = speaker + 1;
        current_speaker = result_cell{row,1};
        accuracy = 0;
        divider = 0;
        
        if result_cell{row,1} == result_cell{row,2} 
            accuracy = accuracy + 1;
            match_array(speaker, row) = 1;
        else
            match_array(result_cell{row,2}, row) = 1;
        end
        divider = divider + 1;
    end
end
accuracy_vector(i) = (accuracy / divider) * 100; % saving last model
accuracy_table = array2table(accuracy_vector, 'RowNames', VOICE_MODELS_SPEAKERS_ARRAY, 'VariableNames', {'Accuracy [%]'})
match_table = array2table(match_array, 'RowNames', VOICE_MODELS_SPEAKERS_ARRAY, 'VariableNames', TEST_FILES_NAME)
