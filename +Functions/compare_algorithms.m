function next_figure_number = compare_algorithms(Results, algorithms_to_compare, current_figure_number, save_figures, path)
    next_figure_number = current_figure_number + 2 ;

    Noise_types = fieldnames(Results) ;
    number_of_rows = length(Noise_types) ;
    number_of_columns = length(algorithms_to_compare) ;
    
    %% Layout parameters
    scale_factor = 1.6 ;

    % Global title
    global_title_x = 0.25 ;  % 0
    y_gap_between_global_title_and_fig_border = 0 ;  % 0
    global_title_height = 0.05 ;  % 0.05
    
    % Colorbar
    colorbar_x = 0.025 ;  % 0.05
    colorbar_y = 0.05 ;  % 0.05
    colorbar_height = 0.025 ;  % 0.025

    % Columns
    x_gap_between_columns = 0 ;  % 0
    x_gap_between_column_and_fig_border = 0 ;  % 0
    y_gap_between_global_title_and_column = 0 ;  % 0
    y_gap_between_column_and_colorbar = 0.0005 ;  % 0
    
    % Column titles
    x_gap_between_column_title_and_column_left_border = 0.1 ;  % 0.0075
    y_gap_between_column_title_and_column_top_border = 0 ;  % 0
    column_title_height = 0.04 ;  % 0.04

    % Rows
    y_gap_between_row_top_border_and_column_top_border = 0 ;  % 0
    y_gap_between_row_bottum_border_and_column_bottum_border = 0 ;  % 0
    y_gap_between_rows = 0 ;  % 0.005
    
    % Row titles
    x_gap_between_row_title_and_column_left_border = 0.025 ;  % 0.025
    x_gap_between_row_title_and_column_right_border = 0.025 ;
    y_gap_between_row_title_and_row_top_border = 0 ;  % 0
    row_title_height = 0.03 ;  % 0.03

    % Graphs
    x_gap_between_graph_and_column_left_border = 0.05 ;  % 0.05
    x_gap_between_graph_and_column_right_border = 0.025 ;  % 0.025
    y_gap_between_graph_and_row_title = 0.0112 ;  % 0.0112
    y_gap_between_graph_and_row_bottom_border = 0.05 ;  % 0.05
    
    % Graph numbers
    x_gap_between_graph_number_and_column_right_border = 0.025 ;
    graph_number_width = 0.025 ;
    graph_number_height = 0.025 ;
    
    %% Layout processing
    % Global title
    global_title_y = 1 - y_gap_between_global_title_and_fig_border - global_title_height ;
    global_title_width = 1 - 2*global_title_x ;
    % Colorbar
    colorbar_width = 1 - 2*colorbar_x ;
    % Columns
    column_y = colorbar_y + colorbar_height + y_gap_between_column_and_colorbar ;
    column_outer_height = global_title_y - column_y - y_gap_between_global_title_and_column ;
    column_inner_height = column_outer_height - column_title_height - y_gap_between_column_title_and_column_top_border ;
    column_outer_width = (1-2*x_gap_between_column_and_fig_border)/number_of_columns ;
    column_inner_width = column_outer_width - (number_of_columns-1)*x_gap_between_columns ;
    % Column titles
    column_title_y = column_y + column_inner_height ;
    column_title_width = column_inner_width - 2*x_gap_between_column_title_and_column_left_border ;
    % Rows
    row_x = x_gap_between_column_and_fig_border ;
    row_outer_height = (column_inner_height - y_gap_between_row_top_border_and_column_top_border - ...
        y_gap_between_row_bottum_border_and_column_bottum_border) / number_of_rows  ;
    row_inner_height = row_outer_height - row_title_height - y_gap_between_graph_and_row_title - ...
        y_gap_between_row_title_and_row_top_border - (number_of_rows-1)*y_gap_between_rows ;
    % Row titles
    row_title_x = row_x + x_gap_between_row_title_and_column_left_border ;
    row_title_width = 1 - row_title_x - x_gap_between_row_title_and_column_right_border ;
    % Graphs
    graph_height = row_inner_height - y_gap_between_graph_and_row_bottom_border ;
    graph_width = column_inner_width - x_gap_between_graph_and_column_left_border - x_gap_between_graph_and_column_right_border ;
    
    %%
    for nti = 1:length(Noise_types)
        Noise = Noise_types{nti} ;
        Noise_name = Functions.render_name(Noise) ;
        for ai = 1:length(algorithms_to_compare)
            Algorithm = algorithms_to_compare{ai} ;
            Algorithm_name = Functions.render_name(Algorithm) ;
            Variables = Functions.find_variable_name(Results, Noise, Algorithm) ;
            if length(Variables) == 2
                Variable_names = {Functions.render_name(Variables{1}), ...
                    Functions.render_name(Variables{2})} ;
                
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
                
                %% Layout processing
                column_x = x_gap_between_column_and_fig_border + ...
                    (ai-1) * column_outer_width ;
                row_y = column_y + y_gap_between_row_bottum_border_and_column_bottum_border + ...
                    (number_of_rows-nti) * row_outer_height ;
                graph_x = column_x + x_gap_between_graph_and_column_left_border + x_gap_between_columns/2 ;
                graph_y = row_y + y_gap_between_graph_and_row_bottom_border ; 
                graph_number_x = column_x + column_inner_width - graph_number_width - x_gap_between_graph_number_and_column_right_border ;
                graph_number_y = row_y ;
                graph_number = (nti-1) * number_of_columns + ai ;
                graph_number_text = char(graph_number + 'a' - 1) ;  % num2str(graph_number)
                
                %% Figure layout (Global title, borders between columns)
                if nti == 1 && ai == 1
                    figure(current_figure_number + 1)
                    annotation('textbox', [global_title_x, global_title_y, ...
                                           global_title_width, global_title_height], ...
                            'String', '\textbf{Convergence time (iterations)}', ...
                            'Interpreter','latex', ...
                            'FontSize', 16,  ...
                            'HorizontalAlignment','center', ...
                            'VerticalAlignment','middle', ...
                            'BackgroundColor','w', ...
                            'LineStyle', 'none')
                    number_of_vertical_borders = number_of_columns - 1 ;
                    for li = 1:number_of_vertical_borders
                        x_border = li * 1/number_of_columns ;
                        y1_border = column_y ;
                        y2_border = column_y + column_inner_height ;
                        annotation('line', [x_border, x_border], [y1_border, y2_border])
                    end

                    figure(current_figure_number + 2)
                    annotation('textbox', [global_title_x, global_title_y, ...
                                           global_title_width, global_title_height], ...
                            'String', '\textbf{Residual error (RMSE)}', ...
                            'Interpreter','latex', ...
                            'FontSize', 16,  ...
                            'HorizontalAlignment','center', ...
                            'VerticalAlignment','middle', ...
                            'BackgroundColor','w', ...
                            'LineStyle', 'none')
                    for li = 1:number_of_vertical_borders
                        x_border = li * 1/number_of_columns ;
                        y1_border = column_y ;
                        y2_border = column_y + column_inner_height ;
                        annotation('line', [x_border, x_border], [y1_border, y2_border])
                    end
                end

                %% Column layout (Algorithm name title)
                if nti == 1
                    for fi = 1:2
                        figure(current_figure_number + fi)
                        column_title_x = column_x + x_gap_between_column_title_and_column_left_border + x_gap_between_columns/2 ;
                        annotation('textbox', [column_title_x, column_title_y, column_title_width, column_title_height], ...
                            'String', ['\textbf{', Algorithm_name, '}'], ...
                            'Interpreter','latex', ...
                            'FontSize', 14, ...
                            'HorizontalAlignment','center', ...
                            'VerticalAlignment','middle', ...
                            'BackgroundColor','w', ...
                            'LineStyle', 'none')
                    end
                end

                %% Row layout (Noise type title)
                for fi = 1:2
                    figure(current_figure_number + fi)
                    row_title_y = row_y + row_inner_height + y_gap_between_graph_and_row_title ;
                    annotation('textbox', [row_title_x, row_title_y, row_title_width, row_title_height],...
                        'String', ['\textbf{', Noise_name, ' input signal}'],...*
                        'Interpreter','latex', ...
                        'FontSize', 12, ...
                        'HorizontalAlignment','center', ...
                        'VerticalAlignment','middle', ...
                        'BackgroundColor','w')
                end
                
                %% First figure: Convergence time comparison
                figure(current_figure_number + 1)
                axes('PositionConstraint','innerposition', ...
                     'InnerPosition', [graph_x, graph_y, graph_width, graph_height])
                contourf(x_grid, y_grid, z_grid_conv, 10, 'ShowText', 'off')
                colormap(jet)
                xlim([0, 1])
                ylim([0, 2])
                clim([0, 20000])
                xlabel(Variable_names{1}, 'Interpreter','latex', 'FontSize', 14) ;
                ylabel(Variable_names{2}, 'Interpreter','latex', 'FontSize', 14, 'Rotation', 0) ;
                % clim([0 35250])
                grid on
                box off
                annotation('textbox', [graph_number_x, graph_number_y, graph_number_width, graph_number_height], ...
                    'String', graph_number_text, ...
                    'Interpreter','latex', ...
                    'FontSize', 12, ...
                    'HorizontalAlignment','center', ...
                    'VerticalAlignment','middle', ...
                    'BackgroundColor','w')
                if nti == length(Noise_types)
                    c1 = colorbar ;
                    c1.Location = "southoutside" ;
                    c1.Label.Interpreter = 'latex' ;
                    c1.Position = [colorbar_x, colorbar_y, colorbar_width, colorbar_height] ;
                    c1.FontSize = 10;
                end

                % Formatting
                set(gcf, 'PaperUnits', 'centimeters', ...
                    'PaperSize', scale_factor*[15, 17], ...
                    'Units', 'centimeters', ...
                    'Position', [1, -5, scale_factor*15, scale_factor*17])
                
                %% Second figure: Residual error comparison
                figure(current_figure_number + 2)
                axes('PositionConstraint','innerposition', ...
                     'InnerPosition', [graph_x, graph_y, graph_width, graph_height])
                hold on
                contourf(x_grid, y_grid, z_grid_res, 10, 'ShowText', 'off')
                colormap(jet)
                xlim([0, 1])
                ylim([0, 2])
                clim([0 residuals_sup_threshold])
                xlabel(Variable_names{1}, 'Interpreter','latex', 'FontSize', 14)
                ylabel(Variable_names{2}, 'Interpreter','latex', 'FontSize', 14, 'Rotation', 0)
                grid on
                box off
                annotation('textbox', [graph_number_x, graph_number_y, graph_number_width, graph_number_height], ...
                    'String', graph_number_text, ...
                    'Interpreter','latex', ...
                    'FontSize', 12, ...
                    'HorizontalAlignment','center', ...
                    'VerticalAlignment','middle', ...
                    'BackgroundColor','w')
                if nti == length(Noise_types)
                    c2 = colorbar ;
                    c2.Location = "southoutside" ;
                    c2.Position = [colorbar_x, colorbar_y, colorbar_width, colorbar_height] ;
                    c2.FontSize = 10 ;
                end

                % Formatting
                set(gcf, 'PaperUnits', 'centimeters', ...
                    'PaperSize', scale_factor*[15, 17], ...
                    'Units', 'centimeters', ...
                    'Position', [1, -5, scale_factor*15, scale_factor*17])

            else
                disp('Error: Invalid number of variables, cannot perform a visual rendering of the results for more than 2 variables')
                exception = MException('ResultsDisplay:InvalidVariablesNumber', ...
                    [Noise, ', ', Algorithm, ': ', num2str(length(Variables)),...
                    ' variables found. Number of variables must be 2']) ;
                throw(exception)
            end
        end
    end
    if save_figures
        % Export and save figures as pdf file
        figure_names = {'Convergence', 'Residuals'} ;
        for fi = 1:length(figure_names)
            figure(current_figure_number + fi)
            filename = algorithms_to_compare{1} ;
            if length(algorithms_to_compare) > 1
                for ai = 2:length(algorithms_to_compare)
                    filename = strcat(filename, '_vs_', algorithms_to_compare{ai}) ;
                end
            end
            filename = strcat(filename, '_',  figure_names{fi}) ;
            file = strcat(path, '\', filename) ;
            print(gcf, '-dpdf', '-bestfit', file)
            try
                savefig(gcf, file)
            catch
                disp(strcat('/!\ An error occurred while attempting to save Figure n°', num2str(current_figure_number + figure_index)))
            end
        end
    end
end