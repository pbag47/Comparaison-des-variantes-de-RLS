close all
clear variables
clear global

Parameters = struct() ;

%% Simulation mode selection
filter_length = 32 ;  % Default: 32

% Choose to either store simulation results in an external file, or to
% discard the results at the end of the program
% /!\ Work in progress, save_mode should be kept to true
save_mode = true ; % Boolean, default: true
% If save_mode is true, state the .mat file in which the results will be
% stored
data_file = 'Alg5_final.mat' ;

% Save the figures of results as .pdf files
save_figures = false ; % Boolean, default: true

% Chosse to plot the curve of error vs sample for every simulation or to
% hide it
% (Only available if save_mode is false)
plot_all_error_curves = false ; % Boolean, default: false

%% Noise type selection
% noise_types = {'White_noise', 'Pink_noise', 'Brownian_noise',...
%     'Tonal_input', 'UAV_noise'} ;
% noise_types = {'White_noise', 'Pink_noise'} ;
noise_types = {'White_noise'} ;

%% Algorithm settings
sweep_sim_number = 4 ;
for i = 1:length(noise_types)
%     Parameters.(noise_types{i}).Alg_1.beta_R = linspace(0.9, 1, sweep_sim_number) ;
%     Parameters.(noise_types{i}).Alg_1.beta_C = linspace(0.9, 1, sweep_sim_number) ;
%     Parameters.(noise_types{i}).Alg_2.lambda = linspace(0, 1, sweep_sim_number) ;
%     Parameters.(noise_types{i}).RLS.lambda = linspace(0, 1, sweep_sim_number) ;
%     Parameters.(noise_types{i}).Alg_3.lambda = linspace(0, 1, sweep_sim_number) ;
%     Parameters.(noise_types{i}).Alg_3.phi = linspace(0.8, 1, sweep_sim_number) ;
%     Parameters.(noise_types{i}).Alg_3.theta = 60 ;
%     Parameters.(noise_types{i}).Alg_5.lambda = linspace(0.6, 0.97, sweep_sim_number) ; % Simpl min 0.7 | max 0.998
% %     Parameters.(noise_types{i}).Alg_6.lambda = linspace(0.31, 0.89, sweep_sim_number) ; % Simpl min 0.35 | max 0.85 
%     Parameters.(noise_types{i}).Alg_7.lambda = linspace(0.75, 0.95, sweep_sim_number) ; % Simpl min 0.35 | max 0.85 
%     Parameters.(noise_types{i}).Alg_7.delta = linspace(0.85, 0.9, 2) ;  % linspace(0.8, 1, sweep_sim_number) ; % Simpl min 0.35 | max 0.85 
% %     Parameters.(noise_types{i}).Alg_8.lambda = linspace(0.52, 0.89, sweep_sim_number) ;  % Simpl min 0.53 | max 0.8 
%     Parameters.(noise_types{i}).Alg_9.lambda = linspace(-0.5, 1, sweep_sim_number) ; % linspace(-0.74, 0.89, sweep_sim_number) ;  % Simpl min 0.53 | max 0.8 
%     Parameters.(noise_types{i}).Alg_9.phi = linspace(0, 1, sweep_sim_number) ;
end

%% Parsing existing results (save_mode)
if save_mode
    % Parsing existing results to avoid running the same simulation twice
    [Parameters, tests_added] = Parse_existing_results(data_file, Parameters) ;
    % tests_added is true if some simulations remain after parsing the
    % existing results, false otherwise
end

%% Impulse response of the unknown system
rng(1) ;
Sh = randn(filter_length, 1) ;
Sh = Sh/(3*sum(Sh)) ;  % Arbitrary scaling

%% Algorithm testing procedure
if save_mode && tests_added
    Results = Algorithm_test(Sh, Parameters, plot_all_error_curves) ;
    Save_results(data_file, Results)
    Print_results(data_file, save_figures)
    return
end
if save_mode && ~tests_added
    Print_results(data_file, save_figures)
    return
end
disp('--- Unavailable feature, work in progress... ----')
return
Print_specific_case_results(Input, Expected_output, ANC_start_sample, Parameters, plot_all_error_curves) ;