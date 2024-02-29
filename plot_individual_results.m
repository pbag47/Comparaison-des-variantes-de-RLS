function next_figure_number = plot_individual_results(Results, current_figure_number, save_figures, path)
    global graph_objects
    
    list_of_all_algorithms = {} ;
    list_of_legend_text = {} ;
    graph_objects = struct() ;
    colors = [0 0 1; 0 0 1; 1 0 0] ;
    line_style = {'-', '--', '-.', ':'} ;
    
    figure_with_2_variables = [] ;
    
    Noise_types = fieldnames(Results) ;
    for nti = 1:length(Noise_types)
        Noise = Noise_types{nti} ;
        Algorithms = fieldnames(Results.(Noise)) ;
        for ai = 1:length(Algorithms)
            Algorithm = Algorithms{ai} ;
            Variables = find_variable_name(Results, Noise, Algorithm) ;
            
            % Process the names of noise type, algorithm and variable for 
            % figure title, labels and legend renderings
            Noise_header = strrep(Noise, '_', ' ') ;
            Algorithm_header = strrep(Algorithm, '_', ' ') ;
            Variable_header = cell(1, length(Variables)) ;
            for vi = 1:length(Variables)
                Variable = Variables{vi} ;
                if strcmp(Variable, 'lambda')
                    Variable_header{vi} = '\lambda' ;
                elseif strcmp(Variable, 'mu')
                    Variable_header{vi} = '\mu' ;
                elseif strcmp(Variable, 'delta')
                    Variable_header{vi} = '\delta' ;
                elseif strcmp(Variable, 'phi')
                    Variable_header{vi} = '\phi' ;
                else
                    Variable_header{vi} =  Variable ;
                end
            end
            
            if length(Variables) == 1
                % Search the algorithm in the list of already encountered
                % algorithms to merge the results in the same figure
                % Update the legend text to keep track of noise types
                figure_index = find(strcmp(list_of_all_algorithms, Algorithm)) ;
                if isempty(figure_index)
                    figure_index = length(list_of_all_algorithms) + 1 ;
                    list_of_all_algorithms{figure_index} = Algorithm ;
                    list_of_legend_text{figure_index} = {Noise_header} ;
                else
                    napnt = length(list_of_legend_text{figure_index}) ; % napnt: Number of Already Processed Noise Types
                    list_of_legend_text{figure_index}{napnt+1} = Noise_header ;
                end

                % Select figure according to current algorithm
                h = figure(current_figure_number + figure_index) ;

                if ~isfield(graph_objects, Algorithm)
                    graph_objects.(Algorithm).figure = h ;
                end

                % Find settings for lowest convergence time and lowest residual
                % error
                [~, cv_min_index] = min(Results.(Noise).(Algorithm).convergence) ;
                [~, r_min_index] = min(Results.(Noise).(Algorithm).residuals) ;

                % Convergence time series
                subplot(2,1,1)
                hold on
                graph_objects.(Algorithm).(Noise).convergence.line = ...
                    plot(Results.(Noise).(Algorithm).(Variable), ...
                         Results.(Noise).(Algorithm).convergence,...
                         'LineStyle', line_style{1+mod(nti-1, length(line_style))},...
                         'Marker', '.') ;
                set(gca, 'ColorOrder', colors)
                hold on
                graph_objects.(Algorithm).(Noise).convergence.scatter = ...
                    scatter(Results.(Noise).(Algorithm).(Variable)(cv_min_index), ...
                            Results.(Noise).(Algorithm).convergence(cv_min_index), ...
                            'HandleVisibility','off') ;
                ylim([0, Inf])
                title([Algorithm_header, ' convergence time vs ', Variable_header])
                xlabel(Variable_header)
                ylabel('Convergence time (iterations)')
                legend(list_of_legend_text{figure_index}, 'ItemHitFcn', @legend_item_click_callback) ;
                grid on
                box off

                % Residuals series
                subplot(2,1,2)
                graph_objects.(Algorithm).(Noise).residuals.line = ...
                    plot(Results.(Noise).(Algorithm).(Variable), ...
                         Results.(Noise).(Algorithm).residuals,...
                         'LineStyle', line_style{1+mod(nti-1, length(line_style))},...
                         'Marker', '.') ;
                set(gca, 'ColorOrder', colors)
                hold on
                graph_objects.(Algorithm).(Noise).residuals.scatter = ...
                    scatter(Results.(Noise).(Algorithm).(Variable)(r_min_index), ...
                            Results.(Noise).(Algorithm).residuals(r_min_index), ...
                            'HandleVisibility','off') ;
                ylim([0, Inf])
                title([Algorithm_header, ' residuals vs ', Variable_header])
                xlabel(Variable_header)
                ylabel('Residuals (RMSE)')
                legend(list_of_legend_text{figure_index}, 'ItemHitFcn', @legend_item_click_callback) ;
                grid on
                box off

                % Formatting
                set(gcf, 'PaperUnits', 'centimeters', ...
                    'PaperSize', [20, 15], ...
                    'Units', 'centimeters', ...
                    'Position', [5, 2, 20, 15])

                if save_figures
                    % Export and save figure as pdf file
                    file = strcat(path, '\', Algorithm) ;
                    print(gcf, '-dpdf', '-bestfit', file)
                    savefig(gcf, file)
                end
            elseif length(Variables) == 2
                % Search the algorithm in the list of already encountered
                % algorithms to merge the results in the same figure
                % Update the legend text to keep track of noise types
                figure_index = find(strcmp(list_of_all_algorithms, Algorithm)) ;
                if isempty(figure_index)
                    figure_index = length(list_of_all_algorithms) + 1 ;
                    figure_with_2_variables = [figure_with_2_variables current_figure_number + figure_index] ;
                    list_of_all_algorithms{figure_index} = Algorithm ;
                end
                
                % Select figure according to current algorithm
                f = figure(current_figure_number + figure_index) ;
                
                % Find settings for lowest convergence time and lowest residual
                % error
                [~, cv_min_index] = min(Results.(Noise).(Algorithm).convergence) ;
                [~, r_min_index] = min(Results.(Noise).(Algorithm).residuals) ;
                
                % Convergence time series
                x_data = Results.(Noise).(Algorithm).(Variables{1}) ;
                y_data = Results.(Noise).(Algorithm).(Variables{2}) ;
                z_data_conv = Results.(Noise).(Algorithm).convergence ;
                z_data_res = Results.(Noise).(Algorithm).residuals ;
                
                [x_grid, y_grid] = meshgrid(linspace(min(x_data), max(x_data), 2*length(x_data)),...
                    linspace(min(y_data), max(y_data), 2*length(y_data))) ;
                z_grid_conv = griddata(x_data, y_data, z_data_conv, x_grid, y_grid) ;
                z_grid_res = griddata(x_data, y_data, z_data_res, x_grid, y_grid) ;
                
                % Set the convergence outside the measured area to NaN
                k = boundary(x_data', y_data', 1) ;
                pgon = polyshape(x_data(k), y_data(k), 'Simplify', false) ;
                idx = isinterior(pgon, x_grid(:), y_grid(:)) ;
                idx = reshape(idx, size(x_grid)) ;
                z_grid_conv(~idx) = nan ; 
                z_grid_res(~idx) = nan ;
                
%                 subplot(2, length(Noise_types) + 1, nti)
                subplot(2, length(Noise_types), nti)
                hold on
                contourf(x_grid, y_grid, z_grid_conv, 'ShowText', 'on') ;
                colormap(jet)
                caxis([0 35250])
                colorbar
                hold on
%                 scatter(Results.(Noise).(Algorithm).(Variables{1})(cv_min_index), ...
%                         Results.(Noise).(Algorithm).(Variables{2})(cv_min_index), ...
%                         'HandleVisibility', 'off', 'MarkerEdgeColor', 'w') ;
                title([Noise_header, ' | ', Algorithm_header, ' convergence time vs ',...
                    Variable_header{1}, ' and ', Variable_header{2}])
                xlabel(Variable_header{1})
                ylabel(Variable_header{2})
                grid on
                box off
                
%                 subplot(2, length(Noise_types) + 1, length(Noise_types) + 1 + nti)
                subplot(2, length(Noise_types), length(Noise_types) + nti)
                hold on
                contourf(x_grid, y_grid, z_grid_res, 'ShowText', 'on') ;
%                 contourf(x_grid, y_grid, log10(z_grid_res)) ;
                colormap(jet)
                caxis([0 2e-15])
                colorbar
%                 c.Ticks = c.Ticks ;
%                 ax = gca ;
%                 exp = -16 ;
%                 ax.ZAxis.Exponent = exp ;
%                 c.TickLabels = compose('%.0f', 10.^(c.Ticks-exp)) ;
                hold on
%                 scatter(Results.(Noise).(Algorithm).(Variables{1})(r_min_index), ...
%                         Results.(Noise).(Algorithm).(Variables{2})(r_min_index), ...
%                         'HandleVisibility', 'off', 'MarkerEdgeColor', 'w') ;
                title([Noise_header, ' | ', Algorithm_header, ' residuals vs ',...
                    Variable_header{1}, ' and ', Variable_header{2}])
                xlabel(Variable_header{1})
                ylabel(Variable_header{2})
                grid on
                box off

                 % Formatting
                set(gcf, 'PaperUnits', 'centimeters', ...
                    'PaperSize', [20, 15], ...
                    'Units', 'centimeters', ...
                    'Position', [5, 2, 20, 15])
        
                if save_figures
                    % Export and save figure as pdf file
                    file = strcat(path, '\', Algorithm) ;
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
    next_figure_number = current_figure_number + length(list_of_all_algorithms) ;
end

