function Results = Algorithm_test(Sh, Parameters, plot_all_error_curves)
    Results = struct() ;
    filter_length = length(Sh) ;
    ANC_start_sample = length(Sh) ;
    Average_length = 10 ;
    
    % Input signal file load
    load('Noise_samples.mat', 'Noise_samples')
    
    Noise_types = fieldnames(Parameters) ;
    for nti = 1:length(Noise_types)
        Noise = Noise_types{nti} ;
        Noise_header = strrep(Noise, '_', ' ') ;
        
        Input = Noise_samples.(Noise) ;
        Expected_output = get_expected_output(Input, Sh) ;
        desired_signal_RMS = rms(Expected_output) ;
        
        if plot_all_error_curves
            % Displaying the RMS value of the expected output
            % (consistent base to detect algorithm divergence) 
            figure(2000+nti)
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
        
        Algorithms = fieldnames(Parameters.(Noise)) ;
        curve_number = 0 ;
        header = {} ;
        for ai = 1:length(Algorithms)  % ai: Algorithm Index
            Algorithm = Algorithms{ai} ;
            Variables = fieldnames(Parameters.(Noise).(Algorithm)) ;
            
            % Initialization of the results storage variable
            for vi= 1:length(Variables)  % vi: Variable Index
                Results.(Noise).(Algorithm).(Variables{vi}) = zeros(1, length(Parameters.(Noise).(Algorithm).(Variables{vi}))) ;
            end
            
            number_of_simulations = length(Parameters.(Noise).(Algorithm).(Variables{1})) ;
            Results.(Noise).(Algorithm).convergence = zeros(1, number_of_simulations) ;
            Results.(Noise).(Algorithm).residuals = zeros(1, number_of_simulations) ;
            Results.(Noise).(Algorithm).computing_time = zeros(1, number_of_simulations) ;
            for si = 1:number_of_simulations  % si: Simulation Index
                curve_number = curve_number + 1 ;
                
                % Console display
                header{curve_number} = [Noise_header, ' | ', Algorithm] ;
                var_values = zeros(length(Variables), 1) ;
                for vi = 1:length(Variables)  % vi: Variable Index
                    var_values(vi) = Parameters.(Noise).(Algorithm).(Variables{vi})(si) ;
                    header{curve_number} = [header{curve_number}, ' | [', Variables{vi}, '=', num2str(var_values(vi)), ']'] ;
                end
                disp(header{curve_number})
                
                %% Algorithm
                % Searching for the appropriate algorithm .m function in
                % the current folder, based on the algorithm name
                function_name = strcat(Algorithm, '_algorithm') ;
                algorithm_function = str2func(function_name) ;
                
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
                % (default : 35249)
                maximum_allowed_convergence_time = length(Error_RMS) - ...
                    round(number_of_active_ANC_samples/5) - ANC_start_sample ;
                
                divergence_threshold = 1e-10 ;  % 2e-15
                [Has_converged, convergence] = detect_convergence(Error_RMS, ... 
                    residuals, divergence_threshold, maximum_allowed_convergence_time) ;
                
                if ~Has_converged
                    convergence = NaN ;
                    residuals = NaN ;
                    computing_time = NaN ;
                else
                    convergence = convergence - ANC_start_sample ;
                end
                
                %% Results processing
                % Storage 
                for vi = 1:length(Variables)
                    Results.(Noise).(Algorithm).(Variables{vi})(si) = Parameters.(Noise).(Algorithm).(Variables{vi})(si) ;
                end
                Results.(Noise).(Algorithm).convergence(si) = convergence ;
                Results.(Noise).(Algorithm).residuals(si) = residuals ;
                Results.(Noise).(Algorithm).computing_time(si) = computing_time ;
                
                % Console display
                disp(['    convergence : ', num2str(convergence), ' iterations'])
                disp(['    residuals : ', num2str(residuals), ' (RMSE)'])
                
                % RMSE curve display
                if plot_all_error_curves
                    figure(2000+nti)
                    hold on
                    plot(Error_RMS, 'DisplayName', strcat(Algorithm, ' | ',...
                        Variables, ' = ', num2str(var_values)))
                end
            end
        end
    end
end