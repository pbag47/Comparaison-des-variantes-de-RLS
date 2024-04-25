function next_figure_number = plot_individual_results(Results, current_figure_number, save_figures, path)
    list_of_all_algorithms = {} ;
    list_of_legend_text = {} ;
    colors = [0 0 1; 1 0 0; 0 1 0] ;
    line_styles = {'-', '--', '-.', ':'} ;
    RLS_figure_number = NaN ;

    Noise_types = fieldnames(Results) ;
    for nti = 1:length(Noise_types)
        Noise = Noise_types{nti} ;
        Noise_name = Functions.render_name(Noise) ;
        Algorithms = fieldnames(Results.(Noise)) ;
        for ai = 1:length(Algorithms)
            Algorithm = Algorithms{ai} ;
            Algorithm_name = Functions.render_name(Algorithm) ;

            Variables = Functions.find_variable_name(Results, Noise, Algorithm) ;
            if length(Variables) == 1
                Variable = Variables{1} ;
                Variable_name = Functions.render_name(Variable) ;
                % Search the algorithm in the list of already encountered
                % algorithms to merge the results in the same figure
                % Update the legend text to keep track of noise types
                figure_index = find(strcmp(list_of_all_algorithms, Algorithm)) ;
                if isempty(figure_index)
                    figure_index = length(list_of_all_algorithms) + 1 ;
                    list_of_all_algorithms{figure_index} = Algorithm ;
                    list_of_legend_text{figure_index} = {Noise_name} ;
                else
                    napnt = length(list_of_legend_text{figure_index}) ; % napnt: Number of Already Processed Noise Types
                    list_of_legend_text{figure_index}{napnt+1} = Noise_name ;
                end

                % Select figure according to current algorithm
                figure(current_figure_number + figure_index) ;

                if strcmp(Algorithm, 'RLS')
                    RLS_figure_number = current_figure_number + figure_index ;
                    beta_R = Results.(Noise).(Algorithm).(Variable) ;
                end

                % Convergence time series
                subplot(2,1,1)
                hold on
                plot(Results.(Noise).(Algorithm).(Variable), ...
                     Results.(Noise).(Algorithm).convergence,...
                     'LineStyle', line_styles{1+mod(nti-1, length(line_styles))},...
                     'Color', colors(1+mod(nti-1, length(colors)), :), ...
                     'Marker', '.', ...
                     'MarkerSize', 7) ;
                hold on
                ylim([0, Inf])
                title(['\textbf{', Algorithm_name, ' convergence time vs ', Variable_name, '}'], 'Interpreter','latex')
                xlabel(Variable_name, 'Interpreter','latex')
                ylabel('Convergence time (iterations)', 'Interpreter','latex')
                legend(list_of_legend_text{figure_index}) ;
                grid on
                box off

                % Residuals series
                subplot(2,1,2)
                plot(Results.(Noise).(Algorithm).(Variable), ...
                     Results.(Noise).(Algorithm).residuals,...
                     'LineStyle', line_styles{1+mod(nti-1, length(line_styles))},...
                     'Color', colors(1+mod(nti-1, length(colors)), :), ...
                     'Marker', '.', ...
                     'MarkerSize', 7) ;
                hold on
                ylim([0, Inf])
                title(['\textbf{', Algorithm_name, ' residuals vs ', Variable_name, '}'], 'Interpreter','latex')
                xlabel(Variable_name, 'Interpreter','latex')
                ylabel('Residuals (RMSE)', 'Interpreter','latex')
                legend(list_of_legend_text{figure_index}) ;
                grid on
                box off

                % Formatting
                set(gcf, 'PaperUnits', 'centimeters', ...
                    'PaperSize', [20, 15], ...
                    'Units', 'centimeters', ...
                    'Position', [5, 2, 20, 15])

                if save_figures
                    % Export and save figure as pdf file
                    file = strcat(path, '\', Algorithm, '_', Noise) ;
                    print(gcf, '-dpdf', '-bestfit', file)
                    savefig(gcf, file)
                end
                
            elseif length(Variables) == 2
                Variable_names = {Functions.render_name(Variables{1}), ...
                    Functions.render_name(Variables{2})} ;
                % Search the algorithm in the list of already encountered
                % algorithms to merge the results in the same figure
                % Update the legend text to keep track of noise types
                figure_index = find(strcmp(list_of_all_algorithms, Algorithm)) ;
                if isempty(figure_index)
                    figure_index = length(list_of_all_algorithms) + 1 ;
                    list_of_all_algorithms{figure_index} = Algorithm ;
                end
                
                % Select figure according to current algorithm
                figure(current_figure_number + figure_index) ;
                
                % Convergence time series
                x_data = Results.(Noise).(Algorithm).(Variables{1}) ;
                y_data = Results.(Noise).(Algorithm).(Variables{2}) ;
                z_data_conv = Results.(Noise).(Algorithm).convergence ;
                z_data_res = Results.(Noise).(Algorithm).residuals ;
                
                % Transform 1D-result vectors into 2D-grids
                residuals_sup_threshold = 1.5e-15 ; % Inf ;
                x_vector = unique(x_data) ;
                y_vector = unique(y_data) ;
                [x_grid, y_grid] = meshgrid(x_vector,...
                    y_vector) ;
                z_grid_conv = NaN * ones(length(y_vector), length(x_vector)) ;
                z_grid_res = NaN * ones(length(y_vector), length(x_vector)) ;
                for i = 1:length(z_data_conv)
                    if z_data_res(i) < residuals_sup_threshold || strcmp(Noise, 'Tonal_input')
                        grid_row_indexes = find(x_grid == x_data(i)) ;
                        grid_column_indexes = find(y_grid == y_data(i)) ;
                        [~, x_index] = intersect(grid_row_indexes, grid_column_indexes) ;
                        [~, y_index] = intersect(grid_column_indexes, grid_row_indexes) ;
                        z_grid_conv(x_index, y_index) = z_data_conv(i) ;
                        z_grid_res(x_index, y_index) = z_data_res(i) ;
                    end
                end
                
                % Display
                subplot(2, length(Noise_types), nti)
                hold on
                contourf(x_grid, y_grid, z_grid_conv, 'ShowText', 'off') ;
                colormap(jet)
                xlim([0, 1])
                ylim([0, 2])
                clim([0, 20000])
                % clim([0 35250])
                colorbar
                hold on
                title(['\textbf{', Noise_name, ' | ', Algorithm_name, ' convergence time vs ',...
                    Variable_names{1}, ' and ', Variable_names{2}, '}'], 'Interpreter','latex')
                xlabel(Variable_names{1}, 'Interpreter','latex')
                ylabel(Variable_names{2}, 'Interpreter','latex')
                grid on
                box off
                
                subplot(2, length(Noise_types), length(Noise_types) + nti)
                hold on
                contourf(x_grid, y_grid, z_grid_res, 'ShowText', 'off') ;
                colormap(jet)
                xlim([0, 1])
                ylim([0, 2])
                % clim([0 2e-15])
                colorbar
                hold on
                title(['\textbf{', Noise_name, ' | ', Algorithm_name, ' residuals vs ',...
                    Variable_names{1}, ' and ', Variable_names{2}, '}'], 'Interpreter','latex')
                xlabel(Variable_names{1}, 'Interpreter','latex')
                ylabel(Variable_names{2}, 'Interpreter','latex')
                grid on
                box off

                 % Formatting
                set(gcf, 'PaperUnits', 'centimeters', ...
                    'PaperSize', [20, 15], ...
                    'Units', 'centimeters', ...
                    'Position', [5, 2, 20, 15])
        
                if save_figures
                    % Export and save figure as pdf file
                    file = strcat(path, '\', Algorithm, '_', Noise) ;
                    print(gcf, '-dpdf', '-bestfit', file)
                    try
                        savefig(gcf, file)
                    catch
                        disp(strcat('/!\ An error occurred while attempting to save Figure n°', num2str(current_figure_number + figure_index)))
                    end                        
                end
            else
                disp('Error: Invalid number of variables, cannot perform a visual rendering of the results for more than 2 variables')
                exception = MException('ResultsDisplay:InvalidVariablesNumber', ...
                    [Noise, ', ', Algorithm, ': ', num2str(length(Variables)),...
                    ' variables found. Number of variables should be 1 or 2']) ;
                throw(exception)
            end
        end
    end

    % Theoretical trend-lines for RLS algorithm performance
    next_figure_number = current_figure_number + length(list_of_all_algorithms) ;
    if ~isnan(RLS_figure_number)
        Input_signal_power = 1 ;
        Initial_value_of_R = 0 ;
        filter_length = 32 ;
        
        theoretical_convergence_curve = - (filter_length * abs(Input_signal_power - Initial_value_of_R) ./ log(beta_R)) ;
        theoretical_error_curve = sqrt(Input_signal_power * filter_length * (1 - beta_R) ./ (1 + beta_R) * eps(1)^2) ;
        
        figure(RLS_figure_number)
        subplot(2, 1, 1)
        plot(beta_R, theoretical_convergence_curve, ...
            'LineStyle', '-.', 'Color', 'k', 'Marker', 'none')
        L = legend() ;
        L.String{1, end} = 'Theoretical curve' ;
        legend(L.String)
    
        subplot(2, 1, 2)
        plot(beta_R, theoretical_error_curve, ...
            'LineStyle', '-.', 'Color', 'k', 'Marker', 'none')
        L = legend() ;
        L.String{1, end} = 'Theoretical curve' ;
        legend(L.String)
        
        if save_figures
            % Export and save figure as pdf file
            file = strcat(path, '\', 'Theoretical_RLS_curves') ;
            print(gcf, '-dpdf', '-bestfit', file)
            savefig(gcf, file)
        end
    end
end

