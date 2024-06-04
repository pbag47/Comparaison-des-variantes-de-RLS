
close all

% Prerequisites :
%   Import https://www.youtube.com/watch?v=lsCu03bnWJ0 audio data via
%   Matlab Import Data tool
%   Audio data should be saved as "data" variable ((N x 2) array of
%   doubles)
%   Sample rate should be saved as "fs" variable (integer)

time_scale = 1/fs:1/fs:length(data)/fs ;

UAV_names = {'Mini_2', 'Mini', 'Mavic_2_pro', 'Mavic_air_2', 'Fimi_X8SE'} ;

time_intervals = [3*60 + 23, 209.1 ;...
    3*60 + 29, 3*60 + 37 ;...
    3*60 + 38, 3*60 + 44 ;...
    3*60 + 44, 3*60 + 50 ;...
    3*60 + 51, 3*60 + 58] ;

sample_intervals = fs * time_intervals ;

UAV_number = 5 ;
for i = 1:UAV_number
    UAV_noise.(UAV_names{i}).time_interval = time_intervals(i, :) ;
    UAV_noise.(UAV_names{i}).sample_interval = sample_intervals(i, :) ;
    UAV_noise.(UAV_names{i}).time_scale = time_scale(sample_intervals(i, 1) : sample_intervals(i, 2)) ;
    UAV_noise.(UAV_names{i}).left = data(sample_intervals(i, 1) : sample_intervals(i, 2), 1) ;
    UAV_noise.(UAV_names{i}).right = data(sample_intervals(i, 1) : sample_intervals(i, 2), 2) ;
    UAV_noise.(UAV_names{i}).mono = (data(sample_intervals(i, 1) : sample_intervals(i, 2), 1) + data(sample_intervals(i, 1) : sample_intervals(i, 2), 2)) / 2 ;
    
    figure(i)
    subplot(3,1,1)
    plot(UAV_noise.(UAV_names{i}).time_scale, UAV_noise.(UAV_names{i}).left)
    title('Left')
    subplot(3,1,2)
    plot(UAV_noise.(UAV_names{i}).time_scale, UAV_noise.(UAV_names{i}).right)
    title('Right')
    subplot(3,1,3)
    plot(UAV_noise.(UAV_names{i}).time_scale, UAV_noise.(UAV_names{i}).mono)
    title('Mono')
end

save('audio_data.mat', 'UAV_noise', 'fs')