function next_figure_number = plot_individual_results(Results, current_figure_number, save_figures, path)
    list_of_all_algorithms = {} ;
    list_of_legend_text = {} ;
    colors = [0 0 1; 1 0 0; 0 1 0] ;
    line_style = {'-', '--', '-.', ':'} ;
    Noise_types = fieldnames(Results) ;
    for nti = 1:length(Noise_types)
        Noise = Noise_types{nti} ;
        Noise_name = render_name(Noise) ;
        Algorithms = fieldnames(Results.(Noise)) ;
        for ai = 1:length(Algorithms)
            Algorithm = Algorithms{ai} ;
            Algorithm_name = render_name(Algorithm) ;
            Variables = find_variable_name(Results, Noise, Algorithm) ;
            if length(Variables) == 1
                Variable = Variables{1} ;
                Variable_name = render_name(Variable) ;
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
                figure(current_figure_number - 1 + figure_index) ;

                % Convergence time
                subplot(2,1,1)
                hold on
                plot(Results.(Noise).(Algorithm).(Variable), ...
                     Results.(Noise).(Algorithm).convergence,...
                     'LineStyle', line_style{1+mod(nti-1, length(line_style))},...
                     'Color', colors(1+mod(nti-1, length(colors)), :), ...
                     'Marker', '.', ...
                     'MarkerSize', 7) ;
                hold on
                ylim([0, Inf])
                title({['\textbf{', Algorithm_name, '}'], ...
                    ['\textbf{Convergence time vs ', Variable_name, '}']}, ...
                    'Interpreter','latex')
                xlabel(Variable_name, ...
                    'Interpreter','latex')
                ylabel({'Convergence time', ...
                    '(iterations)'}, ...
                    'Interpreter','latex')
                l = legend(list_of_legend_text{figure_index}) ;
                title(l, 'Input noise type')
                grid on
                box off

                % Residual error
                subplot(2,1,2)
                plot(Results.(Noise).(Algorithm).(Variable), ...
                     Results.(Noise).(Algorithm).residuals.^2,...
                     'LineStyle', line_style{1+mod(nti-1, length(line_style))},...
                     'Color', colors(1+mod(nti-1, length(colors)), :), ...
                     'Marker', '.', ...
                     'MarkerSize', 7) ;
                hold on
                ylim([0, Inf])
                title({['\textbf{', Algorithm_name, '}'], ...
                    ['\textbf{Residual error vs ', Variable_name, '}']}, ...
                    'Interpreter','latex')
                xlabel(Variable_name, ...
                    'Interpreter','latex')
                ylabel({'Residual error',  ...
                    '(MSE)'}, ...
                    'Interpreter','latex')
                l = legend(list_of_legend_text{figure_index}) ;
                title(l, 'Input noise type')
                grid on
                box off

                % Figure format
                set(gcf, 'PaperUnits', 'centimeters', ...
                    'PaperSize', [20, 15], ...
                    'Units', 'centimeters', ...
                    'Position', [5, 2, 20, 15])

                if save_figures
                    % Export and save figure as pdf and fig files
                    file = strcat(path, '\', Algorithm) ;
                    print(gcf, '-dpdf', '-bestfit', file)
                    savefig(gcf, file)
                end
                
            elseif length(Variables) == 2
                Variable_names = {render_name(Variables{1}), render_name(Variables{2})} ;
                % Search the algorithm in the list of already encountered
                % algorithms to merge the results in the same figure
                % Update the legend text to keep track of noise types
                figure_index = find(strcmp(list_of_all_algorithms, Algorithm)) ;
                if isempty(figure_index)
                    figure_index = length(list_of_all_algorithms) + 1 ;
                    list_of_all_algorithms{figure_index} = Algorithm ;
                end
                
                % Select figure according to current algorithm
                figure(current_figure_number - 1 + figure_index) ;
                
                % Convergence time series
                x_data = Results.(Noise).(Algorithm).(Variables{1}) ;
                y_data = Results.(Noise).(Algorithm).(Variables{2}) ;
                z_data_conv = Results.(Noise).(Algorithm).convergence ;
                z_data_res = Results.(Noise).(Algorithm).residuals.^2 ;
                
                % Interpolation of data to form a grid of uniformly-spaced
                % 3D points
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
                
                subplot(2, length(Noise_types), nti)
                hold on
                contourf(x_grid, y_grid, z_grid_conv, ...
                    'ShowText', 'on') ;
                colormap(jet)
                clim([0 35250])
                colorbar
                hold on
                title({['\textbf{', Algorithm_name, ' | ', Noise_name, '}'], ...
                    ['\textbf{Convergence time vs ', Variable_names{1}, ' and ', Variable_names{2}, '}']}, ...
                    'Interpreter','latex')
                xlabel(Variable_names{1}, ...
                    'Interpreter','latex')
                ylabel(Variable_names{2}, ...
                    'Interpreter','latex', ...
                    'Rotation', 0)
                grid on
                box off
                
                subplot(2, length(Noise_types), length(Noise_types) + nti)
                hold on
                contourf(x_grid, y_grid, z_grid_res, ...
                    'ShowText', 'on') ;
                colormap(jet)
                % clim([0 2e-15])
                colorbar
                hold on
                title({['\textbf{', Algorithm_name, ' | ', Noise_name, '}'], ...
                    ['\textbf{Residual MSE vs ', Variable_names{1}, ' and ', Variable_names{2}, '}']}, ...
                    'Interpreter','latex')
                xlabel(Variable_names{1}, ...
                    'Interpreter','latex')
                ylabel(Variable_names{2}, ...
                    'Interpreter','latex', ...
                    'Rotation', 0)
                grid on
                box off

                 % Figure format
                set(gcf, 'PaperUnits', 'centimeters', ...
                    'PaperSize', [20, 15], ...
                    'Units', 'centimeters', ...
                    'Position', [5, 2, 20, 15])
        
                if save_figures
                    % Export and save figure as pdf and fig files
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
    next_figure_number = current_figure_number - 1 + length(list_of_all_algorithms) ;
end