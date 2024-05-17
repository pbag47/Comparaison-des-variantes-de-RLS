function next_figure_number = compare_algorithms(Results, algorithms_to_compare, current_figure_number, save_figures, path)
    next_figure_number = current_figure_number + 2 ;

    Noise_types = fieldnames(Results) ;
    number_of_rows = length(Noise_types) ;
    number_of_columns = length(algorithms_to_compare) ;
    
    scale_factor = 1.6 ;
    x_margin = 0.05 ; % 0.1 ; % 0.125

    colorbar_x = x_margin ;
    colorbar_y = 0.05 ;
    colorbar_width = 1 - 2*x_margin ;
    colorbar_height = 0.025 ;

    rectangle_x_margin = 0.15 * x_margin ;
    rectangle_y_margin = 0.0 ;
    
    column_title_height = 0.04 ;
    global_title_height = 0.05 ;
    block_y_gap = 0.005 ;

    graph_area_height = 1 - colorbar_y - colorbar_height - column_title_height - global_title_height - block_y_gap ;
    block_height = graph_area_height / number_of_rows ;

    graph_height = 0.675 * block_height ;
    graph_width = 0.5 - 2*x_margin ;
    block_title_height = 0.1 * block_height ;
    title_graph_y_gap = 1.5*0.0075 ;

    block_y_margin = block_height - block_title_height - graph_height - title_graph_y_gap - 2*block_y_gap ;
    
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
                
                %% Figure layout
                if nti == 1 && ai == 1
                    figure(current_figure_number + 1)
                    annotation('textbox', [0, 1-global_title_height + block_y_gap, 1, global_title_height - block_y_gap - rectangle_y_margin], ...
                            'String', '\textbf{Convergence time (iterations)}', ...
                            'Interpreter','latex', ...
                            'FontSize', 16,  ...
                            'HorizontalAlignment','center', ...
                            'VerticalAlignment','middle', ...
                            'BackgroundColor','w', ...
                            'LineStyle', 'none')
                    hold on
                    number_of_vertical_lines = number_of_columns - 1 ;
                    for li = 1:number_of_vertical_lines
                        x_line = li * 1/number_of_columns ;
                        annotation('line', [x_line, x_line], [colorbar_y + colorbar_height, 1-global_title_height + block_y_gap])
                    end

                    figure(current_figure_number + 2)
                    annotation('textbox', [0, 1-global_title_height + block_y_gap, 1, global_title_height - block_y_gap - rectangle_y_margin], ...
                            'String', '\textbf{Residual error (RMSE)}', ...
                            'Interpreter','latex', ...
                            'FontSize', 16,  ...
                            'HorizontalAlignment','center', ...
                            'VerticalAlignment','middle', ...
                            'BackgroundColor','w', ...
                            'LineStyle', 'none')
                    hold on
                    for li = 1:number_of_vertical_lines
                        x_line = li * 1/number_of_columns ;
                        annotation('line', [x_line, x_line], [colorbar_y + colorbar_height, 1-global_title_height + block_y_gap])
                    end
                end
                if nti == 1
                    for fi = 1:2
                        figure(current_figure_number + fi)

                        column_title_x = (ai-1)*0.5 + rectangle_x_margin ;
                        column_title_y = 1-rectangle_y_margin-column_title_height-rectangle_y_margin - global_title_height ;
                        column_title_width = 0.5 - 2*rectangle_x_margin ;
                        
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

                
                %% Block layout
                for fi = 1:2
                    figure(current_figure_number + fi)

                    noise_block_x = 2 * rectangle_x_margin ; % block_x_margin ;
                    noise_block_y = colorbar_y + colorbar_height + (number_of_rows-nti) * block_height ;
                    noise_block_width = 1 - 2*noise_block_x ;
    
                    noise_name_text_x = x_margin ; %  block_x ;
                    noise_name_text_y = noise_block_y + block_height - block_title_height ;
                    % text_width = block_width ;
                    noise_name_text_width = 1 - 2*x_margin ;
                    noise_name_text_height = block_title_height ;
                    annotation('textbox', [noise_name_text_x, noise_name_text_y, noise_name_text_width, noise_name_text_height],...
                        'String', ['\textbf{', Noise_name, ' input signal}'],...*
                        'Interpreter','latex', ...
                        'FontSize', 12, ...
                        'HorizontalAlignment','center', ...
                        'VerticalAlignment','middle', ...
                        'BackgroundColor','w')
                end
                
                %% First figure: Convergence time comparison
                figure(current_figure_number + 1)

                s1 = subplot(number_of_rows, number_of_columns, ai + number_of_columns*(nti-1)) ;
                hold on
                contourf(x_grid, y_grid, z_grid_conv, 'ShowText', 'off')
                colormap(jet)
                xlim([0, 1])
                ylim([0, 2])
                clim([0, 20000])
                xlabel(Variable_names{1}, 'Interpreter','latex', 'FontSize', 14) ;
                ylabel(Variable_names{2}, 'Interpreter','latex', 'FontSize', 14, 'Rotation', 0) ;
                % clim([0 35250])
                grid on
                box off
                
                x_graph = x_margin + (ai-1) * 1/number_of_columns ;
                y_graph = colorbar_y + colorbar_height + (number_of_rows-nti) * block_height + block_y_gap + block_y_margin ;
                set(s1, 'PositionConstraint', 'innerposition',...
                    'InnerPosition', [x_graph, y_graph, graph_width, graph_height])
                
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
                s2 = subplot(number_of_rows, number_of_columns, ai + number_of_columns*(nti-1)) ;
                hold on
                contourf(x_grid, y_grid, z_grid_res, 'ShowText', 'off')
                colormap(jet)
                xlim([0, 1])
                ylim([0, 2])
                clim([0 residuals_sup_threshold])
                xlabel(Variable_names{1}, 'Interpreter','latex', 'FontSize', 14)
                ylabel(Variable_names{2}, 'Interpreter','latex', 'FontSize', 14, 'Rotation', 0)
                grid on
                box off

                set(s2, 'PositionConstraint', 'innerposition',...
                    'InnerPosition', [x_graph, y_graph, graph_width, graph_height])

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