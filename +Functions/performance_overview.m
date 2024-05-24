function next_figure_number = performance_overview(Results, current_figure_number, save_figures, path)
    max_nti = 0 ;
    filtered_results = Functions.remove_NaN_results(Results) ;
    Algorithms = fieldnames(Results) ;
    success_percentage = zeros(length(Algorithms), 1) ;
    minimum_convergence_time = zeros(length(Algorithms), 1) ;
    minimum_residuals = zeros(length(Algorithms), 1) ;
    median_convergence_time = zeros(length(Algorithms), 1) ;
    median_residuals = zeros(length(Algorithms), 1) ;
    for ai = 1:length(Algorithms)
        Algorithm = Algorithms{ai} ;
        Algorithm_name = Functions.render_name(Algorithm) ;
        Noise_types = fieldnames(Results.(Algorithm)) ;
        for nti = 1:length(Noise_types)
            Noise = Noise_types{nti} ;
            Noise_name = Functions.render_name(Noise) ;

            % Number of total simulations for a given
            % algorithm and a given noise type
            sz = size(Results.(Algorithm).(Noise)) ;
            reference_number_of_simulations = sz(1) ;
            
            % Number of successful simulations for a given
            % algorithm and a given noise type
            sz = size(filtered_results.(Algorithm).(Noise)) ;
            number_of_successful_simulations = sz(1) ;

            success_percentage(ai) = round(number_of_successful_simulations / reference_number_of_simulations * 100) ;
            minimum_convergence_time(ai) = min(filtered_results.(Algorithm).(Noise).convergence) ;
            median_convergence_time(ai) = round(median(filtered_results.(Algorithm).(Noise).convergence)) ;
            minimum_residuals(ai) = min(filtered_results.(Algorithm).(Noise).residuals) ;
            median_residuals(ai) = median(filtered_results.(Algorithm).(Noise).residuals) ;
            
            recap = table(Algorithms, success_percentage, minimum_convergence_time, median_convergence_time, minimum_residuals, median_residuals) ;
            disp(Noise_name)
            disp(recap)

            figure(current_figure_number + nti)

            max_nti = max(max_nti, nti) ;
        end
    end
    next_figure_number = current_figure_number + max_nti ;
end