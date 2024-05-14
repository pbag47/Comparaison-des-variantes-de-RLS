function next_figure_number = plot_performance_comparison(Results, current_figure_number, save_figures, path)
    Noise_types = fieldnames(Results) ;
    number_of_added_figures = length(Noise_types) ;
    next_figure_number = current_figure_number + number_of_added_figures ;
    
    for nti = 1:length(Noise_types)
        Noise = Noise_types{nti} ; 
        Noise_name = Functions.render_name(Noise) ;
        Algorithms = fieldnames(Results.(Noise)) ;
        
        %% Formatting the simulation results into 5 variables for boxplots:
        %   -   "full_cv" concatenates the convergence results series of every 
        %       algorithm into a single series
        %   -   "full_res" concatenates the residuals results series of every 
        %       algorithm into a single series
        %   -   "full_names" concatenates the algorithm name series of every 
        %       algorithm into a single series
        %   -   "full_x_label_coordinates" is used to scatter-plot every 
        %       simulation result as a cross on the boxplot. To do so, an 
        %       equivalence is made between each algorithm name and its 
        %       respective x-axis coordinate on the boxplot graph.
        full_cv = [] ;
        full_res = [] ;
        full_mean_cv = [] ;
        full_mean_res = [] ;
        mean_series_x_coords = [] ;
        full_names = [] ;
        full_x_label_coordinates = [] ;
        for ai = 1:length(Algorithms)
            Algorithm = Algorithms{ai} ;
            Algorithm_name = Functions.render_name(Algorithm) ;
            
            cv = (Results.(Noise).(Algorithm).convergence)' ;
            res = (Results.(Noise).(Algorithm).residuals)' ;

            mean_cv = [NaN ; mean(cv) ; mean(cv) ; NaN] ;
            mean_res = [NaN ; mean(res) ; mean(res) ; NaN] ;
            
            names = repmat({Algorithm_name}, [length(cv), 1]) ;
            x_label_coordinates = repmat(ai, [length(cv), 1]) ;
            
            full_cv = [full_cv ; cv] ;
            full_res = [full_res ; res] ;
            full_mean_cv = [full_mean_cv ; mean_cv] ;
            full_mean_res = [full_mean_res ; mean_res] ;
            mean_series_x_coords = [mean_series_x_coords ; ai-0.9 ; ai - 0.50 ; ai + 0.50 ; ai + 0.9] ;
            full_names = [full_names ; names] ;
            full_x_label_coordinates = [full_x_label_coordinates ; x_label_coordinates] ;
        end

        %% Results comparison boxplot
        figure(current_figure_number)
        subplot(2,1,1)
        boxplot(full_cv, full_names, 'Whisker', Inf)
        hold on
        scatter(full_x_label_coordinates, full_cv, 20, 'x', 'jitter', 'on', 'jitterAmount', 0.05)
        % plot(mean_series_x_coords, full_mean_cv, '--k')
        % ylim([0, Inf])
        ylim([0 35250])
        title({Noise_name, 'Convergence time comparison'})
        ylabel('Convergence time (iterations)')
        box off
        set(gca, 'YGrid', 'on')

        figure(current_figure_number)
        subplot(2,1,2)
        boxplot(full_res, full_names, 'Whisker', Inf)
        hold on
        scatter(full_x_label_coordinates, full_res, 20, 'x', 'jitter', 'on', 'jitterAmount', 0.05)
        % plot(mean_series_x_coords, full_mean_res, '--k')
        % ylim([0, 5e-15])
        ylim([0, 1.5e-15])
        title('Residuals comparison')
        ylabel('Residuals (RMSE)')
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
            savefig(gcf, file)
        end
        
        current_figure_number = current_figure_number + 1 ;
    end
end

