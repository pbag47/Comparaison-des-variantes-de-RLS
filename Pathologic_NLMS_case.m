clear variables
close all

filter_length = 2 ;

Sim_setup.Real_filter_sample_rate = 22050 ; % Hz
Sim_setup.ANC_sample_rate = 3000 ; % Hz

Parameters = struct() ;

sweep_sim_number = 3 ;
Parameters.Alg_8.lambda = linspace(0.5, 0.8, sweep_sim_number) ;
% Parameters.Alg_6.lambda = linspace(0.5, 0.8, sweep_sim_number) ;

plot_all_error_curves = true ;

t = 1:10000 ;
Input = sin(0.1*t) ;
% Input = (-1).^t ;
figure(1096)
plot(Input)

figure(1097)
for i=2:100
    plot([0, Input(i)], [0, Input(i-1)])
    hold on 
    drawnow
end

% Impulse response of the unknown system
rng(1) ;
% Sh = [1; 1] ;
Sh = randn(3, 1) ;
figure(1098)
plot(Sh)

% figure(1099)
% for i=1:length(Input)-1
%     plot([0, Input(i+1)], [0, Input(i)])
%     hold on
% end
% figure(1100)
% scatter(Sh(1), Sh(2))

% Desired signal acquisition
Expected_output = zeros(length(Input), 1) ;
Buffer = zeros(1, length(Sh)) ;
for i = 1:length(Input)
    Buffer = [Input(i) Buffer(1:length(Buffer)-1)] ;
    Expected_output(i) = Buffer * Sh ;
end

ANC_start_sample = length(Sh) ;
Print_specific_case_results(Input, Expected_output, ANC_start_sample, Parameters, Sim_setup, plot_all_error_curves) ;

