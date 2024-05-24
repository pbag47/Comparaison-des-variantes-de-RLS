function next_figure_number = performance_overview(Results, current_figure_number, save_figures, path)
    Noise_types = fieldnames(Results) ;
    number_of_figures = length(Noise_types) ;

    next_figure_number = current_figure_number + number_of_figures ;
    
    % Number of total simulations (successful or not) for a given
    % algorithm and a given noise type
    reference_number_of_simulations = 33*17 ;
    
    for fi = 1:number_of_figures
        figure(current_figure_number + fi)

        Noise = Noise_types{fi} ;
        Noise_name = Functions.render_name(Noise) ;
        Algorithms = fieldnames(Results.(Noise)) ;
        
        success_percentage = zeros(length(Algorithms), 1) ;
        minimum_convergence_time = zeros(length(Algorithms), 1) ;
        minimum_residuals = zeros(length(Algorithms), 1) ;
        median_convergence_time = zeros(length(Algorithms), 1) ;
        median_residuals = zeros(length(Algorithms), 1) ;
        for ai = 1:length(Algorithms)
            Algorithm = Algorithms{ai} ;
            Algorithm_name = Functions.render_name(Algorithm) ;

            number_of_successful_simulations = length(Results.(Noise).(Algorithm).convergence) ;
            success_percentage(ai) = round(number_of_successful_simulations / reference_number_of_simulations * 100) ;
            minimum_convergence_time(ai) = min(Results.(Noise).(Algorithm).convergence) ;
            minimum_residuals(ai) = min(Results.(Noise).(Algorithm).residuals) ;
            median_convergence_time(ai) = round(median(Results.(Noise).(Algorithm).convergence)) ;
            median_residuals(ai) = median(Results.(Noise).(Algorithm).residuals) ;
        end
        recap = table(Algorithms, success_percentage, minimum_convergence_time, median_convergence_time, minimum_residuals, median_residuals) ;
        disp(Noise_name)
        disp(recap)
    end
end