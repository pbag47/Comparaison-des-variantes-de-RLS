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
data_file = 'test.mat' ;

% Save the figures of results as .pdf files
save_figures = true ; % Boolean, default: true

% Chosse to plot the curve of error vs sample for every simulation or to
% hide it
% (Only available if save_mode is false)
plot_all_error_curves = false ; % Boolean, default: false

%% Noise type selection
% noise_types = {'White_noise', 'Pink_noise', 'Brownian_noise',...
%     'Tonal_input', 'UAV_noise'} ;
noise_types = {'White_noise', 'Pink_noise'} ;
% noise_types = {'White_noise'} ;

%% Algorithm settings
sweep_sim_number = 3 ;
for i = 1:length(noise_types)
    Parameters.(noise_types{i}).Alg_1.beta_R = linspace(0.6, 1, sweep_sim_number) ;
    Parameters.(noise_types{i}).Alg_2.beta_R = linspace(0.6, 1, sweep_sim_number) ;
    Parameters.(noise_types{i}).Alg_2.beta_Lambda = linspace(0.6, 1, sweep_sim_number) ;
    Parameters.(noise_types{i}).Alg_3.beta_R = linspace(0.6, 1, sweep_sim_number) ;
    Parameters.(noise_types{i}).Alg_3.beta_E = linspace(0.6, 1, sweep_sim_number) ;
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
if tests_added
    Results = Algorithm_test(Sh, Parameters, plot_all_error_curves) ;
    Save_results(data_file, Results)
end

%% Results display
load(data_file, 'Results')
path = "Images" ;
current_figure_number = 1 ;
current_figure_number = plot_performance_comparison(Results, current_figure_number, save_figures, path) ;
current_figure_number = plot_individual_results(Results, current_figure_number, save_figures, path) ;