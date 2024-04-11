function next_figure_number = plot_performance_comparison(Results, current_figure_number, save_figures, path)
    Noise_types = fieldnames(Results) ;
    number_of_added_figures = length(Noise_types) ;
    next_figure_number = current_figure_number + number_of_added_figures ;
    
    for nti = 1:length(Noise_types)
        Noise = Noise_types{nti} ; 
        Noise_name = render_name(Noise) ;
        Algorithms = fieldnames(Results.(Noise)) ;
        
        %% Formatting the simulation results into 5 variables for boxplots:
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
        full_cv = [] ;
        full_res = [] ;
        full_ct = [] ;
        full_names = [] ;
        full_x_label_coordinates = [] ;
        for ai = 1:length(Algorithms)
            Algorithm = Algorithms{ai} ;
            Algorithm_name = render_name(Algorithm) ;
            
            cv = (Results.(Noise).(Algorithm).convergence)' ;
            res = (Results.(Noise).(Algorithm).residuals)' ;
            ct = (Results.(Noise).(Algorithm).computing_time)' ;
            
            names = repmat({Algorithm_name}, [length(cv), 1]) ;
            x_label_coordinates = repmat(ai, [length(cv), 1]) ;
            
            full_cv = [full_cv ; cv] ;
            full_res = [full_res ; res] ;
            full_ct = [full_ct ; ct] ;
            full_names = [full_names ; names] ;
            full_x_label_coordinates = [full_x_label_coordinates ; x_label_coordinates] ;
        end

        %% Results comparison boxplot
        figure(current_figure_number)

        % Convergence time
        subplot(3,1,1)
        boxplot(full_cv, full_names, ...
            'Whisker', Inf)
        set(gca, 'TickLabelInterpreter', 'latex')
        hold on
        scatter(full_x_label_coordinates, full_cv, ...
            'Marker', 'x', ...
            'SizeData', 20, ...
            'Jitter', 'on', ...
            'JitterAmount', 0.05)
        set(gca, 'YGrid', 'on')
        title({['\textbf{', Noise_name, '}'], ...
            '\textbf{Convergence time comparison}'}, ...
            'Interpreter', 'latex')
        ylim([0, Inf])
        ylabel({'Convergence time', ...
            '(iterations)'}, ...
            'Interpreter', 'latex')
        box off
        
        % Residual error
        subplot(3,1,2)
        boxplot(full_res.^2, full_names, ...
            'Whisker', Inf)
        set(gca, 'TickLabelInterpreter', 'latex')
        hold on
        scatter(full_x_label_coordinates, full_res.^2, ...
            'Marker', 'x', ...
            'SizeData', 20, ...
            'Jitter', 'on', ...
            'JitterAmount', 0.05)
        set(gca, 'YGrid', 'on')
        title({['\textbf{', Noise_name, '}'], ...
            '\textbf{Residual error comparison}'}, ...
            'Interpreter', 'latex')
        ylim([0, Inf])
        ylabel({'Residual error', ...
            '(MSE)'}, ...
            'Interpreter', 'latex')
        box off
        
        % Computing time
        subplot(3,1,3)
        boxplot(full_ct, full_names, ...
            'Whisker', Inf)
        set(gca, 'TickLabelInterpreter', 'latex')
        hold on
        scatter(full_x_label_coordinates, full_ct, ...
            'Marker', 'x', ...
            'SizeData', 20, ...
            'Jitter', 'on', ...
            'JitterAmount', 0.05)
        set(gca, 'YGrid', 'on')
        title({['\textbf{', Noise_name, '}'], ...
            '\textbf{Computing time comparison}'}, ...
            'Interpreter', 'latex')
        ylim([0, Inf])
        ylabel({'Computing time', ...
            '(s)'}, ...
            'Interpreter', 'latex')
        box off
        
        % Figure format
        set(gcf, 'PaperUnits', 'centimeters', ...
            'PaperSize', [20, 20], ...
            'Units', 'centimeters', ...
            'Position', [5, 2, 20, 20])
        
        if save_figures
            % Export and save figure as pdf and fig files
            filename = strcat('Comparison__', Noise) ;
            file = strcat(path, '\', filename) ;
            print(gcf, '-dpdf', '-bestfit', file)
            savefig(gcf, file)
        end
        
        current_figure_number = current_figure_number + 1 ;
    end
end

