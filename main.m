close all
clear variables
clear global
clc

Parameters = struct() ;

%% Simulation mode
% Number of tap in the FIR filter
% Requirement for the DWTLMS: filter_length must be an integer power of 2
filter_length = 32 ;  % Default: 32

% .mat file in which the results are stored
data_file = '+Results/results_refactor.mat' ;

% Save the figures of results as .fig and .pdf files
save_figures = true ; % Boolean, default: true

% Choose to plot the curve of error vs sample for every simulation or to
% hide it
plot_all_error_curves = false ; % Boolean, default: false

%% Noise type selection
% Available noise types:
%   - 'White_noise'
%   - 'Pink_noise'
%   - 'Brownian_noise'
%   - 'Tonal_input'
%   - 'UAV_noise'
Noise_types = {'White_noise', 'Pink_noise', 'UAV_noise'} ; % Cell array of str elements

%% Algorithm selection
% Available algorithms:
%   - 'RLS'
%   - 'ARLS'
%   - 'OPTLMS'
%   - 'DFTLMS'
%   - 'DCTLMS'
%   - 'HTLMS'
%   - 'DWTLMS'
Algorithms = {'OPTLMS', 'DFTLMS', 'DCTLMS', 'HTLMS', 'DWTLMS'} ; % CEll array of str elements

%% Algorithm settings
sweep_sim_beta = 9 ;
sweep_sim_theta = 5 ;
beta = linspace(0, 0.995, sweep_sim_beta) ;
theta = linspace(0, 2, sweep_sim_theta) ;
for ai = 1:length(Algorithms)
    Algorithm = Algorithms{ai} ;
    for nti = 1:length(Noise_types)
        Noise = Noise_types{nti} ;
        Parameters.(Algorithm).(Noise) = table(beta, theta, 'VariableNames', {'beta', 'theta'}) ;
    end
end

%% Impulse response of the unknown system
rng(1) ;
Sh = randn(filter_length, 1) ;
Sh = Sh/(3*sum(Sh)) ;  % Arbitrary scaling

%% Parsing existing results
% Parsing existing results to avoid running the same simulation twice
[Parameters, tests_added] = Functions.Parse_existing_results(data_file, Parameters) ;
% tests_added is true if some simulations remain after parsing the
% existing results, false otherwise

%% Algorithm testing procedure
if tests_added
    Results = Functions.Algorithm_test(Sh, Parameters, plot_all_error_curves) ;
    filtered_results = Functions.remove_NaN_results(Results) ;
    Functions.Save_results(data_file, filtered_results)
end

%% Results display
load(data_file, 'Results')
path = "+Images" ;
current_figure_number = 1 ;
% current_figure_number = Functions.plot_performance_comparison(Results, current_figure_number, save_figures, path) ;
% current_figure_number = Functions.plot_individual_results(Results, current_figure_number, save_figures, path) ;
% current_figure_number = Functions.compare_algorithms(Results, {'OPTLMS', 'DFTLMS', 'DWTLMS'}, ...
%     current_figure_number, save_figures, path) ;
current_figure_number = Functions.performance_overview(Results, ...
    current_figure_number, save_figures, path) ;
