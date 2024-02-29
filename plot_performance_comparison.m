function next_figure_number = plot_performance_comparison(Results, current_figure_number, save_figures, path)
    Noise_types = fieldnames(Results) ;
    number_of_added_figures = length(Noise_types) ;
    next_figure_number = current_figure_number + number_of_added_figures ;
    
    for nti = 1:length(Noise_types)
        Noise = Noise_types{nti} ;       
        Noise_header = strrep(Noise, '_', ' ') ;
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
        convergence = zeros(1, length(Algorithms)) ;
        residuals = zeros(1, length(Algorithms)) ;
        computing_time = zeros(1, length(Algorithms)) ;
        full_cv = [] ;
        full_res = [] ;
        full_ct = [] ;
        full_names = [] ;
        full_x_label_coordinates = [] ;
        for ai = 1:length(Algorithms)
            Algorithm = Algorithms{ai} ;
            header = strrep(Algorithm, '_', ' ') ;
            
            cv = (Results.(Noise).(Algorithm).convergence)' ;
            res = (Results.(Noise).(Algorithm).residuals)' ;
            ct = (Results.(Noise).(Algorithm).computing_time)' ;
            
            names = repmat({header}, [length(cv), 1]) ;
            x_label_coordinates = repmat(ai, [length(cv), 1]) ;
            
%             convergence(ai) = min(Results.(Noise).(Algorithm).convergence) ;
%             residuals(ai) = min(Results.(Noise).(Algorithm).residuals) ;
%             computing_time(ai) = min(Results.(Noise).(Algorithm).computing_time) ;
            
            full_cv = [full_cv ; cv] ;
            full_res = [full_res ; res] ;
            full_ct = [full_ct ; ct] ;
            full_names = [full_names ; names] ;
            full_x_label_coordinates = [full_x_label_coordinates ; x_label_coordinates] ;
        end

        %% Results comparison boxplot
        figure(current_figure_number)
        subplot(3,1,1)
        boxplot(full_cv, full_names, 'Whisker', Inf)
        hold on
        scatter(full_x_label_coordinates, full_cv, 20, 'x', 'jitter', 'on', 'jitterAmount', 0.05)
        ylim([0, Inf])
        title({Noise_header, 'Convergence time comparison'})
        ylabel('Convergence time (iterations)')
        box off
        set(gca, 'YGrid', 'on')

        figure(current_figure_number)
        subplot(3,1,2)
        boxplot(full_res, full_names, 'Whisker', Inf)
        hold on
        scatter(full_x_label_coordinates, full_res, 20, 'x', 'jitter', 'on', 'jitterAmount', 0.05)
        ylim([0, Inf])
        title('Residuals comparison')
        ylabel('Residuals (RMSE)')
        box off
        set(gca, 'YGrid', 'on')

        figure(current_figure_number)
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
        
        %% Export and save Figure as a pdf file
        if save_figures
            filename = strcat('Comparison__', Noise) ;
            file = strcat(path, '\', filename) ;
            print(gcf, '-dpdf', '-bestfit', file)
        end
        
        current_figure_number = current_figure_number + 1 ;
    end
end

