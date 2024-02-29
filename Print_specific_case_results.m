function Print_specific_case_results(Input, Expected_output, ANC_start_sample, Parameters, plot_all_error_curves)
    filter_length = 64 ; % 64
    Average_length = 10 ; % Length of the sliding-window RMS value (empirically-chosen)
    
    %% Variables initialization
    Algorithm_names = fieldnames(Parameters) ;
    Results = struct() ;
    curve_number = 0 ;
    header = {} ;
    
    %% Algorithm tests
    for i=1:length(Algorithm_names)
        % Extracts the name of the variables of the currently-tested
        % algorithm and initializes the Results structure
        alg_name = Algorithm_names{i} ;
        Variable_names = fieldnames(Parameters.(alg_name)) ;
        for j=1:length(Variable_names)
            Results.(alg_name).(Variable_names{j}) = zeros(1, length(Parameters.(alg_name).(Variable_names{j}))) ;
        end
        Results.(alg_name).convergence = zeros(1, length(Parameters.(alg_name).(Variable_names{1}))) ;
        Results.(alg_name).residuals = zeros(1, length(Parameters.(alg_name).(Variable_names{1}))) ;
        Results.(alg_name).computing_time = zeros(1, length(Parameters.(alg_name).(Variable_names{1}))) ;
        
        % Runs simulation for each case (each value of the variables)
        for j=1:length(Parameters.(alg_name).(Variable_names{1}))
            curve_number = curve_number + 1 ;
            header{curve_number} = strrep(alg_name, '_', ' ') ;
            var_values = zeros(1, length(Variable_names)) ;
            for k=1:length(Variable_names)
                var_name = Variable_names{k} ;
                if strcmp(var_name, 'lambda')
                    v = '\lambda' ;
                elseif strcmp(var_name, 'mu')
                    v = '\mu' ;
                else
                    v = var_name ;
                end
                header{curve_number} = [header{curve_number}, ', ', v, ' = ', num2str(Parameters.(alg_name).(var_name)(j))] ;
                var_values(k) = Parameters.(alg_name).(var_name)(j) ;
            end
            disp(header{curve_number})
            
            % Calls the appropriate function for each algorithm
            function_name = strcat(alg_name, '_algorithm') ;
            algorithm_function = str2func(function_name) ;
            [Error, computing_time] = algorithm_function(Input,...
                Expected_output, ANC_start_sample, filter_length, var_values) ;

            % Results interpretation from the obtained error curve
            Error_RMS = zeros(length(Error)-round(Average_length/2), 1) ;
            for k = 1:length(Error)-round(Average_length/2)
                if k <= ANC_start_sample || k <= round(Average_length/2)
                    Error_RMS(k) = mean(rms(Error(1:ANC_start_sample))) ;
                else
                    Error_RMS(k) = mean(rms(Error(k-round(Average_length/2):k+round(Average_length/2)))) ;
                    % Makes sure that the Error_RMS does not contain any 
                    % NaN to avoid exceptions in the next parts of 
                    % the program
                    if isnan(Error_RMS(k))
                        Error_RMS(k) = 10e50 ;
                    end
                end
            end
            convergence = NaN ;
            number_of_active_ANC_samples = length(Error_RMS) - ANC_start_sample ;
            residuals = mean(Error_RMS(end-round(number_of_active_ANC_samples/5):end)) ;
            if residuals > Error_RMS(1) / 10 || residuals == 0
                disp('    Divergence or too slow convergence detected')
                residuals = NaN ;
                computing_time = NaN ;
            else
                for k = 1:length(Error_RMS)
                    if Error_RMS(k) < residuals && isnan(convergence)
                        convergence = k - ANC_start_sample ;
                        if convergence > length(Error_RMS) - round(number_of_active_ANC_samples/5) - ANC_start_sample
                            disp('    Too slow convergence detected')
                            convergence = NaN ;
                            residuals = NaN ;
                            computing_time = NaN ;
                        end
                    end
                    if Error_RMS(k) > 4 * max(Error_RMS(1:ANC_start_sample))
                        disp('    Divergence detected')
                        convergence = NaN ;
                        residuals = NaN ;
                        computing_time = NaN ;
                        break
                    end
                end
            end
            
            % Save performance indicators of each simulation in the 
            % Results structure
            for k=1:length(Variable_names)
                Results.(alg_name).(Variable_names{k})(j) = Parameters.(alg_name).(Variable_names{k})(j) ;
            end
            Results.(alg_name).convergence(j) = convergence ;
            Results.(alg_name).residuals(j) = residuals ;
            Results.(alg_name).computing_time(j) = computing_time ;
            
            %% Displays run-specific results
            
            disp(['    convergence : ', num2str(convergence), 'pts'])
            disp(['    residuals : ', num2str(residuals)])
            
            if plot_all_error_curves
                % Displays error curves
                figure(1000)
                hold on
                plot(Error)

                figure(1001)
                hold on
                plot(Error_RMS(ANC_start_sample:end))
            end
        end
    end
    
    if plot_all_error_curves
        figure(1000)
        legend(header)
        title('Error vs sample number')
        xlabel('Sample number')
        ylabel('Error (V)')
        set(gcf, 'PaperUnits', 'centimeters', 'PaperSize', [20, 20])
        
        figure(1001)
        hold on
        curve_number = curve_number + 1 ;
        header{curve_number} = 'Residuals measurement area' ;
        x1 = round(4/5 * number_of_active_ANC_samples) ;
        x2 = number_of_active_ANC_samples ;
        y1 = 1e-17 ;
        y2 = max(Error_RMS) ;
        fill([x1, x1, x2, x2], [y1, y2, y2, y1], ...
            'g', 'FaceAlpha', 0.2)
        
        hold on
        curve_number = curve_number + 1 ;
        header{curve_number} = 'Convergence detection threshold' ;
        plot([0, number_of_active_ANC_samples], [residuals, residuals], ...
            '--k', 'LineWidth', 1)
        
        hold on
        curve_number = curve_number + 1 ;
        header{curve_number} = 'Detected convergence area' ;
        x1 = 0 ;
        x2 = convergence ;
        y1 = 1e-17 ;
        y2 = max(Error_RMS) ;
        fill([x1, x1, x2, x2], [y1, y2, y2, y1], ...
            'b', 'FaceAlpha', 0.15)
        
        legend(header)
        title('Error RMS vs sample number')
        xlabel('Sample number')
        ylabel('Error RMS (V_R_M_S)')
        grid on
        ylim([1e-17, Error_RMS(1)])
        set(gca, 'yscale', 'log')
        set(gcf, 'PaperUnits', 'centimeters', ...
                'PaperSize', [20, 10], ...
                'Units', 'centimeters', ...
                'Position', [5, 2, 20, 10])
            
%         filename = 'Evaluation_method' ;
%         path = "C:\Users\P_Bagnara\Desktop\BAGNARA Pierre\Rédaction d'article\Wiener Filter estimation algorithms using successive approximations\Article\Images" ;
%         file = strcat(path, '\', filename) ;
%         print(gcf, '-dpdf', '-bestfit', file)
    end
    
    
    %% Display results summary
    
    % Extracts the names of tested algorithms from the results structure
    Results_fieldnames = fieldnames(Results) ;
    Algorithm_names = {} ;
    Alg_header = {} ;
    for i=1:length(Results_fieldnames)
        if ~strcmp(Results_fieldnames{i}, 'Parameters')
            Algorithm_names{length(Algorithm_names)+1, 1} = Results_fieldnames{i} ;
            Alg_header{length(Alg_header)+1, 1} = strrep(Results_fieldnames{i}, '_', ' ') ;
        end
    end
    
    % Formats the simulation results into 5 variables for boxplots:
    %   -   "full_cv" concatenates the convergence results series of every 
    %       algorithm into a single series
    %   -   "full_res" concatenates the residuals results series of every 
    %       algorithm into a single series
    %   -   "full_ct" concatenates the computing time results series of every 
    %       algorithm into a single series
    %   -   "full_names" concatenates the algorithm name series of every 
    %       algorithm into a single series
    %   -   "full_x_label_coordinates" is used to scatter-plot every 
    %       simulation result as a cross on the boxplot. To do so, an 
    %       equivalence is made between each algorithm name and its 
    %       respective x-axis coordinate on the boxplot graph.
    convergence = zeros(1, length(Algorithm_names)) ;
    residuals = zeros(1, length(Algorithm_names)) ;
    computing_time = zeros(1, length(Algorithm_names)) ;
    full_cv = [] ;
    full_res = [] ;
    full_ct = [] ;
    full_names = [] ;
    full_x_label_coordinates = [] ;
    for i=1:length(Algorithm_names)
        cv = (Results.(Algorithm_names{i}).convergence)' ;
        res = (Results.(Algorithm_names{i}).residuals)' ;
        ct = (Results.(Algorithm_names{i}).computing_time)' ;
        names = repmat({Alg_header{i}}, [length(cv), 1]) ;
        x_label_coordinates = repmat(i, [length(cv), 1]) ;
        convergence(i) = min(Results.(Algorithm_names{i}).convergence) ;
        residuals(i) = min(Results.(Algorithm_names{i}).residuals) ;
        computing_time(i) = min(Results.(Algorithm_names{i}).computing_time) ;
        full_cv = [full_cv ; cv] ;
        full_res = [full_res ; res] ;
        full_ct = [full_ct ; ct] ;
        full_names = [full_names ; names] ;
        full_x_label_coordinates = [full_x_label_coordinates ; x_label_coordinates] ;
    end
    
    figure(1)
    subplot(3,1,1)
    boxplot(full_cv, full_names, 'Whisker', Inf)
    hold on
    scatter(full_x_label_coordinates, full_cv, 20, 'x', 'jitter', 'on', 'jitterAmount', 0.05)
    ylim([0, Inf])
    title('Convergence time comparison')
    ylabel('Convergence time (number of samples)')
    box off
    set(gca, 'YGrid', 'on')
    
    figure(1)
    subplot(3,1,2)
    boxplot(full_res, full_names, 'Whisker', Inf)
    hold on
    scatter(full_x_label_coordinates, full_res, 20, 'x', 'jitter', 'on', 'jitterAmount', 0.05)
    ylim([0, Inf])
    title('Residuals comparison')
    ylabel('Residuals (V_R_M_S)')
    box off
    set(gca, 'yscale', 'log', 'YGrid', 'on')
    
    figure(1)
    subplot(3,1,3)
    boxplot(full_ct, full_names, 'Whisker', Inf)
    hold on
    scatter(full_x_label_coordinates, full_ct, 20, 'x', 'jitter', 'on', 'jitterAmount', 0.05)
    ylim([0, Inf])
    title('Computing time comparison')
    ylabel('Computing time (s)')
    box off
    set(gca, 'YGrid', 'on')
    
    set(gcf, 'PaperUnits', 'centimeters', ...
        'PaperSize', [20, 20], ...
        'Units', 'centimeters', ...
        'Position', [5, 2, 20, 20])
    
    % For each algorithm, plots the convergence, residuals and computing
    % time results vs a tested parameter (depends on the algorithm)
    for i=1:length(Algorithm_names)
        % Extracts the tested parameters names from the results structure
        Variable_names = {} ;
        Var_header = {} ;
        algorithm_fieldnames = fieldnames(Results.(Algorithm_names{i})) ;
        for j=1:length(algorithm_fieldnames)
            if ~strcmp(algorithm_fieldnames{j}, 'convergence') && ...
                    ~strcmp(algorithm_fieldnames{j}, 'residuals') && ...
                    ~strcmp(algorithm_fieldnames{j}, 'computing_time')
                Variable_names{length(Variable_names)+1, 1} = algorithm_fieldnames{j} ;
                if strcmp(algorithm_fieldnames{j}, 'lambda')
                    Var_header{length(Var_header)+1, 1} = '\lambda' ;
                elseif strcmp(algorithm_fieldnames{j}, 'mu')
                    Var_header{length(Var_header)+1, 1} = '\mu' ;
                else
                    Var_header{length(Var_header)+1, 1} =  algorithm_fieldnames{j} ;
                end
            end
        end
        
        figure(i+1)
        % This program only works for a single-variable sweep
        
        % Finds the minimum value of each series to highlight its
        % position with a marker
        [~, cv_min_index] = min(Results.(Algorithm_names{i}).convergence) ;
        [~, r_min_index] = min(Results.(Algorithm_names{i}).residuals) ;
        [~, ct_min_index] = min(Results.(Algorithm_names{i}).computing_time) ;
        
        % Convergence time series
        subplot(3,1,1)
        plot(Results.(Algorithm_names{i}).(Variable_names{1}), ...
            (Results.(Algorithm_names{i}).convergence),...
            'LineStyle', '-', 'Marker', '.')
        hold on
        scatter(Results.(Algorithm_names{i}).(Variable_names{1})(cv_min_index), ...
            Results.(Algorithm_names{i}).convergence(cv_min_index))
        
        if strcmp(Algorithm_names{i}, 'RLS')
            theoretical_conv = zeros(length(Results.(Algorithm_names{i}).(Variable_names{1})), 1) ;
            theoretical_res = zeros(length(Results.(Algorithm_names{i}).(Variable_names{1})), 1) ;
            lambda = Results.(Algorithm_names{i}).(Variable_names{1}) ;
            for j = 1:length(lambda)
                theoretical_conv(j) = log(Results.(Algorithm_names{i}).residuals(j)/rms(Expected_output)) / log(lambda(j)) ;
                %                     theoretical_res(j) = (1-lambda(j)) * (1-lambda(j))/(1+lambda(j)) * var(Input)^2 * condition_number ;
                %                     theoretical_res(j) = (1-lambda(j))/(1+lambda(j)) * (1 + (1-lambda(j))/(1+lambda(j))) * (var(Input.^2)/var(Input)^2) * filter_length * Wiener_error_rms ;
                c = 2*(1-lambda(j))*filter_length*var(Input) ;
                eta = 1 - 2*(1-lambda(j)) + (filter_length+2) / ((1/(1-lambda(j)))^2 + (filter_length/(1-lambda(j)^2))) ;
                theoretical_res(j) = c / (1-eta) ;
            end
            hold on
            plot(lambda, theoretical_conv)
        end
        
        ylim([0, Inf])
        title([Alg_header{i}, ' convergence time vs ', Var_header{1}])
        xlabel(Var_header{1})
        ylabel('Convergence time (number of samples)')
        grid on
        box off
        
        % Residuals series
        subplot(3,1,2)
        plot(Results.(Algorithm_names{i}).(Variable_names{1}), ...
            Results.(Algorithm_names{i}).residuals,...
            'LineStyle', '-', 'Marker', '.')
        hold on
        scatter(Results.(Algorithm_names{i}).(Variable_names{1})(r_min_index), ...
            Results.(Algorithm_names{i}).residuals(r_min_index))
        
        if strcmp(Algorithm_names{i}, 'RLS')
            hold on
            plot(lambda, sqrt(theoretical_res))
        end
        
        ylim([0, Inf])
        title([Alg_header{i}, ' residuals vs ', Var_header{1}])
        xlabel(Var_header{1})
        ylabel('Residuals (V_R_M_S)')
        set(gca, 'yscale', 'log')
        grid on
        box off
        
        % Computing time series
        subplot(3,1,3)
        plot(Results.(Algorithm_names{i}).(Variable_names{1}), ...
            Results.(Algorithm_names{i}).computing_time,...
            'LineStyle', '-', 'Marker', '.')
        hold on
        scatter(Results.(Algorithm_names{i}).(Variable_names{1})(ct_min_index), ...
            Results.(Algorithm_names{i}).computing_time(ct_min_index))
        ylim([0, Inf])
        title([Alg_header{i}, ' computing time vs ', Var_header{1}])
        xlabel(Var_header{1})
        ylabel('Computing time (s)')
        grid on
        box off
        
        set(gcf, 'PaperUnits', 'centimeters', ...
            'PaperSize', [20, 20], ...
            'Units', 'centimeters', ...
            'Position', [5, 2, 20, 20])
    end
end