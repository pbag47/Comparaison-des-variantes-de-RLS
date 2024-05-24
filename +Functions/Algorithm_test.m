function [Results, next_figure_number] = Algorithm_test(Sh, Parameters, plot_all_error_curves, current_figure_number)
    Results = struct() ;
    filter_length = length(Sh) ;
    ANC_start_sample = length(Sh) ;
    Average_length = 10 ;
    max_nti = 0 ;
    
    % Input signal file load
    load('Noise_samples.mat', 'Noise_samples')
    import Algorithms.*

    Algorithms = fieldnames(Parameters) ;
    for ai = 1:length(Algorithms)
        Algorithm = Algorithms{ai} ;
        Algorithm_header = strrep(Algorithm, '_', ' ') ;
        Noise_types = fieldnames(Parameters.(Algorithm)) ;
        for nti = 1:length(Noise_types)
            Noise = Noise_types{nti} ;
            Noise_header = strrep(Noise, '_', ' ') ;

            Input = Noise_samples.(Noise) ;
            Expected_output = Functions.get_expected_output(Input, Sh) ;
            desired_signal_RMS = rms(Expected_output) ;

            if plot_all_error_curves && ai == 1
                % Displaying the RMS value of the expected output
                % (consistent base to detect algorithm divergence)
                figure(current_figure_number + nti)
                hold on
                plot([1, length(Expected_output)], [desired_signal_RMS, desired_signal_RMS],...
                    'LineStyle', '--', 'Color', 'black',...
                    'DisplayName', 'RMS of the desired signal')
                hold on
                % Displaying the starting sample
                plot([ANC_start_sample, ANC_start_sample], [0, desired_signal_RMS],...
                    'LineStyle', ':', 'Color', 'black',...
                    'DisplayName', 'ANC algorithm start')
                title(strcat(Noise_header, ' Error RMS curves'))
            end
            
            % Initialization of the results storage variable
            sz = size(Parameters.(Algorithm).(Noise)) ;
            number_of_simulations = sz(1) ;
            Variables = Parameters.(Algorithm).(Noise).Properties.VariableNames ;
            Results.(Algorithm).(Noise) = table('Size', [number_of_simulations, length(Variables)+3], ...
                'VariableTypes', [repmat({'double'}, 1, length(Variables)), 'int16', 'double', 'double'], ...
                'VariableNames', [Variables, 'convergence', 'residuals', 'computing_time']) ;
            
            for si = 1:number_of_simulations  % si: Simulation Index
                % Console display
                header = [Algorithm_header, ' | ', Noise_header] ;
                var_values = zeros(length(Variables), 1) ;
                for vi = 1:length(Variables)  % vi: Variable Index
                    Variable = Variables{vi} ;
                    var_values(vi) = Parameters.(Algorithm).(Noise).(Variable)(si) ;
                    header = strcat(header, ' | [', Variable, '=', num2str(var_values(vi)), ']') ;
                end
                disp(header)

                %% Algorithm
                % Searching for the appropriate algorithm .m function in
                % the current folder, based on the algorithm name
                algorithm_function = str2func(Algorithm) ;
                
                % Executing the algorithm function to get the error signal
                [Error, computing_time] = algorithm_function(Input,...
                    Expected_output, ANC_start_sample, filter_length, var_values) ;
                
                % Since the algorithms are turned off durign the first 
                % ANC_start_sample iterations, then the error signal is 
                % undefined in the algorithm function for this interval.
                Error(1:ANC_start_sample-1) = desired_signal_RMS ;
                
                %% RMSE curve
                % The RMSE is based on a sliding-average of the squared 
                % error signal composed of Average_length samples.
                % As a consequence, the total number of samples obtained 
                % for the RMSE curve is slightly less than the number of
                % samples of the error signal.
                RMSE_number_of_samples = length(Error)-round(Average_length/2) ;
                Error_RMS = desired_signal_RMS *...
                    ones(RMSE_number_of_samples, 1) ;
                
                for k = max(ANC_start_sample, round(Average_length/2)):RMSE_number_of_samples
                    Error_RMS(k) = mean(rms(Error(k-round(Average_length/2):k+round(Average_length/2)))) ;
                    if isnan(Error_RMS(k))
                        % Replaces NaN values by a dummy value that will be
                        % interpreted as a divergence to avoid exceptions
                        % in the following steps
                        Error_RMS(k) = 10e50 ;
                    end
                end

                %% Convergence/Divergence detection
                number_of_active_ANC_samples = length(Input) - ANC_start_sample ;
                
                % The residuals are the average of the last 1/5th of RMSE
                % samples. 
                % (If a divergence is detected, they are switched to NaN 
                % value)
                residuals = mean(Error_RMS(end-round(number_of_active_ANC_samples/5):end)) ;
                
                % The finite number of samples of the Error_RMS brings a limit
                % to the maximum convergence time that can be measured
                % (default: 35249)
                maximum_allowed_convergence_time = length(Error_RMS) - ...
                    round(number_of_active_ANC_samples/5) - ANC_start_sample ;
                
                divergence_threshold = 1e-10 ;  % 2e-15
                [Has_converged, convergence] = Functions.detect_convergence(Error_RMS, ... 
                    residuals, divergence_threshold, maximum_allowed_convergence_time) ;
                
                if Has_converged
                    convergence = convergence - ANC_start_sample ;
                else
                    convergence = NaN ;
                    residuals = NaN ;
                    computing_time = NaN ;
                end

                %% Results processing
                % Storage of current simulation results
                for vi = 1:length(Variables)
                    Variable = Variables{vi} ;
                    Results.(Algorithm).(Noise).(Variable)(si) = Parameters.(Algorithm).(Noise).(Variable)(si) ;
                end
                Results.(Algorithm).(Noise).convergence(si) = convergence ;
                Results.(Algorithm).(Noise).residuals(si) = residuals ;
                Results.(Algorithm).(Noise).computing_time(si) = computing_time ;
                
                % Console display
                disp(['    Convergence: ', num2str(convergence), ' iterations'])
                disp(['    Residuals (RMSE): ', num2str(residuals)])
                
                % RMSE curve display
                if plot_all_error_curves
                    figure(current_figure_number + nti)
                    hold on
                    plot(Error_RMS, 'DisplayName', strcat(Algorithm, ' | ',...
                        Variables, ' = ', num2str(var_values)))
                end
                max_nti = max(max_nti, nti) ;
            end
        end
    end
    next_figure_number = current_figure_number + max_nti ;
end